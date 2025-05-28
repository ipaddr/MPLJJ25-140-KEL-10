import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:logging/logging.dart';

/// Service untuk manajemen program oleh admin
/// 
/// Menyediakan fungsi-fungsi untuk CRUD program, upload gambar,
/// dan operasi terkait program
class AdminProgramService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Logger untuk pencatatan error
  final _log = Logger('AdminProgramService');

  /// Mengambil semua program yang tersedia
  Future<List<Map<String, dynamic>>> getAllPrograms() async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .orderBy('createdAt', descending: true)
          .get();

      return _mapProgramDocuments(querySnapshot.docs);
    } catch (e) {
      _log.severe('Error getting programs', e);
      return [];
    }
  }

  /// Mengambil program berdasarkan ID
  Future<Map<String, dynamic>?> getProgramById(String programId) async {
    try {
      final doc = await _firestore.collection('programs').doc(programId).get();
      
      if (doc.exists) {
        return _mapProgramDocument(doc);
      }
      return null;
    } catch (e) {
      _log.severe('Error getting program: $programId', e);
      return null;
    }
  }

  /// Mengambil daftar pengajuan berdasarkan ID program
  Future<List<Map<String, dynamic>>> getApplicationsByProgramId(String programId) async {
    try {
      final querySnapshot = await _firestore
          .collection('applications')
          .where('programId', isEqualTo: programId)
          .orderBy('submittedAt', descending: true)
          .get();

      return _mapApplicationDocuments(querySnapshot.docs);
    } catch (e) {
      _log.severe('Error getting applications by program ID: $programId', e);
      return [];
    }
  }

  /// Membuat program baru
  Future<String?> createProgram({
    required String programName,
    required String organizer,
    required String targetAudience,
    required String category,
    required String description,
    required String termsAndConditions,
    required String registrationGuide,
    required String status,
    File? imageFile,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      final docRef = await _firestore.collection('programs').add({
        'programName': programName,
        'organizer': organizer,
        'targetAudience': targetAudience,
        'category': category,
        'description': description,
        'termsAndConditions': termsAndConditions,
        'registrationGuide': registrationGuide,
        'status': status,
        'imageUrl': imageUrl ?? '',
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalApplications': 0,
      });

      return docRef.id;
    } catch (e) {
      _log.severe('Error creating program', e);
      return null;
    }
  }

  /// Memperbarui program yang sudah ada
  Future<bool> updateProgram({
    required String programId,
    required String programName,
    required String organizer,
    required String targetAudience,
    required String category,
    required String description,
    required String termsAndConditions,
    required String registrationGuide,
    required String status,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      String? imageUrl = existingImageUrl;
      
      if (imageFile != null) {
        // Hapus gambar lama jika ada
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await _deleteImage(existingImageUrl);
        }
        // Upload gambar baru
        imageUrl = await _uploadImage(imageFile);
      }

      await _firestore.collection('programs').doc(programId).update({
        'programName': programName,
        'organizer': organizer,
        'targetAudience': targetAudience,
        'category': category,
        'description': description,
        'termsAndConditions': termsAndConditions,
        'registrationGuide': registrationGuide,
        'status': status,
        'imageUrl': imageUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _log.severe('Error updating program: $programId', e);
      return false;
    }
  }

  /// Menghapus program
  Future<bool> deleteProgram(String programId) async {
    try {
      // Ambil data program terlebih dahulu untuk menghapus gambar
      final programData = await getProgramById(programId);
      
      if (programData != null) {
        // Hapus gambar jika ada
        final imageUrl = programData['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteImage(imageUrl);
        }
        
        // Hapus dokumen program
        await _firestore.collection('programs').doc(programId).delete();
        
        return true;
      }
      return false;
    } catch (e) {
      _log.severe('Error deleting program: $programId', e);
      return false;
    }
  }

  /// Upload gambar ke Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = 'program_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('program_images').child(fileName);
      
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      _log.severe('Error uploading image', e);
      return null;
    }
  }

  /// Hapus gambar dari Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      _log.warning('Error deleting image: $imageUrl', e);
    }
  }

  /// Mengambil program berdasarkan kategori
  Future<List<Map<String, dynamic>>> getProgramsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return _mapProgramDocuments(querySnapshot.docs);
    } catch (e) {
      _log.severe('Error getting programs by category: $category', e);
      return [];
    }
  }

  /// Mengambil program berdasarkan status
  Future<List<Map<String, dynamic>>> getProgramsByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return _mapProgramDocuments(querySnapshot.docs);
    } catch (e) {
      _log.severe('Error getting programs by status: $status', e);
      return [];
    }
  }

  /// Memperbarui jumlah total pengajuan untuk program tertentu
  Future<void> updateTotalApplications(String programId) async {
    try {
      final applicationsCount = await _firestore
          .collection('applications')
          .where('programId', isEqualTo: programId)
          .count()
          .get();

      await _firestore.collection('programs').doc(programId).update({
        'totalApplications': applicationsCount.count,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _log.severe('Error updating total applications: $programId', e);
    }
  }

  /// Helper method untuk memetakan dokumen program menjadi Map
  Map<String, dynamic> _mapProgramDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      'programName': data['programName'] ?? '',
      'organizer': data['organizer'] ?? '',
      'targetAudience': data['targetAudience'] ?? '',
      'category': data['category'] ?? '',
      'description': data['description'] ?? '',
      'termsAndConditions': data['termsAndConditions'] ?? '',
      'registrationGuide': data['registrationGuide'] ?? '',
      'status': data['status'] ?? 'inactive',
      'imageUrl': data['imageUrl'] ?? '',
      'createdBy': data['createdBy'] ?? '',
      'createdAt': data['createdAt'],
      'updatedAt': data['updatedAt'],
      'totalApplications': data['totalApplications'] ?? 0,
    };
  }

  /// Helper method untuk memetakan dokumen program menjadi List<Map>
  List<Map<String, dynamic>> _mapProgramDocuments(List<DocumentSnapshot> docs) {
    return docs.map(_mapProgramDocument).toList();
  }

  /// Helper method untuk memetakan dokumen aplikasi menjadi Map
  Map<String, dynamic> _mapApplicationDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return {
      'id': doc.id,
      'userId': data['userId'] ?? '',
      'programId': data['programId'] ?? '',
      'userName': data['userName'] ?? '',
      'userEmail': data['userEmail'] ?? '',
      'status': data['status'] ?? 'pending',
      'submittedAt': data['submittedAt'],
      'reviewedAt': data['reviewedAt'],
      'reviewedBy': data['reviewedBy'] ?? '',
      'notes': data['notes'] ?? '',
      'documents': data['documents'] ?? [],
    };
  }

  /// Helper method untuk memetakan dokumen aplikasi menjadi List<Map>
  List<Map<String, dynamic>> _mapApplicationDocuments(List<DocumentSnapshot> docs) {
    return docs.map(_mapApplicationDocument).toList();
  }
}