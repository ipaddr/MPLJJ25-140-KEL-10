import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'models/admin_profile_model.dart';

/// Service untuk mengelola profil administrator
///
/// Menyediakan fungsi-fungsi untuk membaca dan memperbarui data profil admin,
/// mengelola gambar profil, dan mendapatkan statistik admin
class AdminProfileService {
  // Firebase services
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  // Collection name
  static const String _collectionName = 'admin_profiles';
  static const String _storagePath = 'admin_profiles';

  /// Konstruktor dengan dependency injection untuk memudahkan testing
  AdminProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance, 
    _storage = storage ?? FirebaseStorage.instance;

  /// Mendapatkan profil admin yang sedang login
  Future<AdminProfileModel?> getCurrentAdminProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection(_collectionName).doc(user.uid).get();
      
      if (doc.exists) {
        return AdminProfileModel.fromFirestore(doc);
      } else {
        // Buat profil default jika belum ada
        return await _createDefaultProfile(user);
      }
    } catch (e) {
      debugPrint('Error getting admin profile: $e');
      return null;
    }
  }

  /// Membuat profil default untuk admin baru
  Future<AdminProfileModel?> _createDefaultProfile(User user) async {
    try {
      final now = DateTime.now();
      final defaultProfile = AdminProfileModel(
        id: user.uid,
        fullName: user.displayName ?? 'Admin',
        email: user.email ?? '',
        phoneNumber: '',
        position: 'Administrator',
        role: 'admin',
        createdAt: now,
        updatedAt: now,
        lastLogin: now,
        permissions: _getDefaultPermissions(),
      );

      await _firestore.collection(_collectionName).doc(user.uid).set(defaultProfile.toFirestore());
      return defaultProfile;
    } catch (e) {
      debugPrint('Error creating default profile: $e');
      return null;
    }
  }

  /// Mendapatkan permission default untuk admin baru
  Map<String, dynamic> _getDefaultPermissions() {
    return {
      'manageUsers': true,
      'manageContent': true,
      'managePrograms': true,
      'viewReports': true,
    };
  }

  /// Memperbarui profil admin
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String position,
    File? profileImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Siapkan data update
      final Map<String, dynamic> updateData = await _prepareProfileUpdateData(
        userId: user.uid,
        fullName: fullName,
        phoneNumber: phoneNumber, 
        position: position,
        profileImage: profileImage,
      );

      // Update di Firestore
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .update(updateData);

      // Update display name di Firebase Auth
      await user.updateDisplayName(fullName.trim());

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  /// Menyiapkan data untuk update profil
  Future<Map<String, dynamic>> _prepareProfileUpdateData({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String position,
    File? profileImage,
  }) async {
    final Map<String, dynamic> updateData = {
      'fullName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'position': position.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Upload gambar profil jika ada
    if (profileImage != null) {
      final profilePictureUrl = await _uploadProfileImage(userId, profileImage);
      if (profilePictureUrl != null) {
        updateData['profilePictureUrl'] = profilePictureUrl;
      }
    }

    return updateData;
  }

  /// Memperbarui timestamp login terakhir
  Future<void> updateLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(_collectionName).doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  /// Mendapatkan daftar program yang dikelola admin
  Future<List<Map<String, dynamic>>> getManagedPrograms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final adminProfile = await getCurrentAdminProfile();
      if (adminProfile == null) return [];

      // Ambil program yang dikelola oleh admin ini
      final programsSnapshot = await _firestore
          .collection('programs')
          .where('managedBy', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return programsSnapshot.docs.map(_mapProgramDocToData).toList();
    } catch (e) {
      debugPrint('Error getting managed programs: $e');
      return [];
    }
  }

  /// Mengkonversi dokumen program Firestore menjadi Map data
  Map<String, dynamic> _mapProgramDocToData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      'name': data['name'] ?? '',
      'description': data['description'] ?? '',
      'status': data['status'] ?? 'active',
      'totalApplicants': data['totalApplicants'] ?? 0,
      'createdAt': data['createdAt'] as Timestamp?,
    };
  }

  /// Upload gambar profil
  Future<String?> _uploadProfileImage(String adminId, File imageFile) async {
    try {
      final fileName = '$_storagePath/$adminId/profile_picture.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Menghapus gambar profil
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }

  /// Mendapatkan statistik admin
  Future<Map<String, int>> getAdminStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final results = await Future.wait([
        _getCollectionCount('users'),
        _getFilteredCollectionCount('programs', 'managedBy', user.uid),
        _getFilteredCollectionCount('applications', 'reviewedBy', user.uid),
        _getFilteredCollectionCount('education_content', 'authorId', user.uid),
      ]);

      return {
        'totalUsers': results[0],
        'managedPrograms': results[1],
        'reviewedApplications': results[2],
        'publishedContent': results[3],
      };
    } catch (e) {
      debugPrint('Error getting admin statistics: $e');
      return {};
    }
  }

  /// Helper untuk mendapatkan jumlah dokumen dalam collection
  Future<int> _getCollectionCount(String collectionPath) async {
    final countSnapshot = await _firestore.collection(collectionPath).count().get();
    return countSnapshot.count ?? 0;
  }

  /// Helper untuk mendapatkan jumlah dokumen dalam collection dengan filter
  Future<int> _getFilteredCollectionCount(
    String collectionPath, 
    String fieldPath, 
    String fieldValue
  ) async {
    final countSnapshot = await _firestore
        .collection(collectionPath)
        .where(fieldPath, isEqualTo: fieldValue)
        .count()
        .get();
    return countSnapshot.count ?? 0;
  }

  /// Mengganti password admin
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  /// Memeriksa apakah admin memiliki permission
  bool hasPermission(AdminProfileModel? profile, String permission) {
    if (profile == null) return false;
    return profile.permissions[permission] == true;
  }

  /// Sign out admin
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}