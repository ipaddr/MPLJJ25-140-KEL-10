import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer' as developer;
import 'models/admin_profile_model.dart';

class AdminProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collectionName = 'admin_profiles';

  // Get current admin profile
  Future<AdminProfileModel?> getCurrentAdminProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection(_collectionName).doc(user.uid).get();
      
      if (doc.exists) {
        return AdminProfileModel.fromFirestore(doc);
      } else {
        // Create default profile if doesn't exist
        return await _createDefaultProfile(user);
      }
    } catch (e) {
      developer.log('Error getting admin profile: $e', name: 'AdminProfileService');
      return null;
    }
  }

  // Create default profile for new admin
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
        permissions: {
          'manageUsers': true,
          'manageContent': true,
          'managePrograms': true,
          'viewReports': true,
        },
      );

      await _firestore.collection(_collectionName).doc(user.uid).set(defaultProfile.toFirestore());
      return defaultProfile;
    } catch (e) {
      developer.log('Error creating default profile: $e', name: 'AdminProfileService');
      return null;
    }
  }

  // Update admin profile
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String position,
    File? profileImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      String? profilePictureUrl;
      
      // Upload profile image if provided
      if (profileImage != null) {
        profilePictureUrl = await _uploadProfileImage(user.uid, profileImage);
      }

      final updateData = {
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'position': position.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add profile picture URL if uploaded
      if (profilePictureUrl != null) {
        updateData['profilePictureUrl'] = profilePictureUrl;
      }

      await _firestore.collection(_collectionName).doc(user.uid).update(updateData);

      // Update Firebase Auth display name
      await user.updateDisplayName(fullName.trim());

      return true;
    } catch (e) {
      developer.log('Error updating profile: $e', name: 'AdminProfileService');
      return false;
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(_collectionName).doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error updating last login: $e', name: 'AdminProfileService');
    }
  }

  // Get managed programs
  Future<List<Map<String, dynamic>>> getManagedPrograms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final adminProfile = await getCurrentAdminProfile();
      if (adminProfile == null) return [];

      // Get programs that this admin manages
      final programsSnapshot = await _firestore
          .collection('programs')
          .where('managedBy', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return programsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'status': data['status'] ?? 'active',
          'totalApplicants': data['totalApplicants'] ?? 0,
          'createdAt': data['createdAt'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      developer.log('Error getting managed programs: $e', name: 'AdminProfileService');
      return [];
    }
  }

  // Upload profile image
  Future<String?> _uploadProfileImage(String adminId, File imageFile) async {
    try {
      final fileName = 'admin_profiles/$adminId/profile_picture.jpg';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log('Error uploading profile image: $e', name: 'AdminProfileService');
      return null;
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      developer.log('Error deleting profile image: $e', name: 'AdminProfileService');
    }
  }

  // Get admin statistics
  Future<Map<String, int>> getAdminStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final results = await Future.wait([
        _firestore.collection('users').count().get(),
        _firestore.collection('programs').where('managedBy', isEqualTo: user.uid).count().get(),
        _firestore.collection('applications').where('reviewedBy', isEqualTo: user.uid).count().get(),
        _firestore.collection('education_content').where('authorId', isEqualTo: user.uid).count().get(),
      ]);

      return {
        'totalUsers': results[0].count ?? 0,
        'managedPrograms': results[1].count ?? 0,
        'reviewedApplications': results[2].count ?? 0,
        'publishedContent': results[3].count ?? 0,
      };
    } catch (e) {
      developer.log('Error getting admin statistics: $e', name: 'AdminProfileService');
      return {};
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

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
      developer.log('Error changing password: $e', name: 'AdminProfileService');
      return false;
    }
  }

  // Check if admin has permission
  bool hasPermission(AdminProfileModel? profile, String permission) {
    if (profile == null) return false;
    return profile.permissions[permission] == true;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Error signing out: $e', name: 'AdminProfileService');
    }
  }
}