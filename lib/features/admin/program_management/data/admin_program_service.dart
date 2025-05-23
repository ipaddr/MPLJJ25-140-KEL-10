import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AdminProgramService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all programs
  Future<List<Map<String, dynamic>>> getAllPrograms() async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
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
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'totalApplications': data['totalApplications'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting programs: $e');
      return [];
    }
  }

  // Get program by ID
  Future<Map<String, dynamic>?> getProgramById(String programId) async {
    try {
      final doc = await _firestore.collection('programs').doc(programId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
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
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'totalApplications': data['totalApplications'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error getting program: $e');
      return null;
    }
  }

  // Create new program
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
      print('Error creating program: $e');
      return null;
    }
  }

  // Update program
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
        // Delete old image if exists
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await _deleteImage(existingImageUrl);
        }
        // Upload new image
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
      print('Error updating program: $e');
      return false;
    }
  }

  // Delete program
  Future<bool> deleteProgram(String programId) async {
    try {
      // Get program data first to delete image
      final programData = await getProgramById(programId);
      
      if (programData != null) {
        // Delete image if exists
        final imageUrl = programData['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteImage(imageUrl);
        }
        
        // Delete program document
        await _firestore.collection('programs').doc(programId).delete();
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting program: $e');
      return false;
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = 'program_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('program_images').child(fileName);
      
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Get programs by category
  Future<List<Map<String, dynamic>>> getProgramsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .where('category', isEqualTo: category)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
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
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'totalApplications': data['totalApplications'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting programs by category: $e');
      return [];
    }
  }

  // Get programs by status
  Future<List<Map<String, dynamic>>> getProgramsByStatus(String status) async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
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
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'totalApplications': data['totalApplications'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting programs by status: $e');
      return [];
    }
  }

  // Update total applications count
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
      print('Error updating total applications: $e');
    }
  }
}