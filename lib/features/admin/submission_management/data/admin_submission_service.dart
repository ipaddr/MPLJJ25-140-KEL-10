import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Safe conversion helper methods
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static String _safeParseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Safe parsing for supporting documents
  static List<Map<String, dynamic>> _safeParseSupportingDocuments(dynamic value) {
    if (value == null) return [];
    
    if (value is List) {
      return value.map((doc) {
        if (doc is Map<String, dynamic>) {
          return {
            'fileName': _safeParseString(doc['fileName']),
            'fileUrl': _safeParseString(doc['fileUrl']),
            'uploadDate': doc['uploadDate'],
            'fileSize': _safeParseInt(doc['fileSize']),
            'fileType': _safeParseString(doc['fileType']),
          };
        } else if (doc is String) {
          // Handle case where document is just a string (URL or filename)
          return {
            'fileName': doc,
            'fileUrl': doc,
            'uploadDate': null,
            'fileSize': 0,
            'fileType': 'unknown',
          };
        } else {
          // Handle unexpected data type
          return {
            'fileName': 'Unknown Document',
            'fileUrl': '',
            'uploadDate': null,
            'fileSize': 0,
            'fileType': 'unknown',
          };
        }
      }).toList();
    }
    
    return [];
  }

  // Get all submissions with optional filters
  Future<List<Map<String, dynamic>>> getAllSubmissions({
    String? programFilter,
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('applications');

      // Apply filters
      if (programFilter != null && programFilter != 'Semua Program') {
        query = query.where('programName', isEqualTo: programFilter);
      }

      if (statusFilter != null && statusFilter != 'Semua Status') {
        query = query.where('status', isEqualTo: statusFilter);
      }

      if (startDate != null) {
        query = query.where(
          'submissionDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'submissionDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('submissionDate', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'userId': _safeParseString(data['userId']),
          'programId': _safeParseString(data['programId']),
          'programName': _safeParseString(data['programName']),
          'userName': _safeParseString(data['userName']),
          'userEmail': _safeParseString(data['userEmail']),
          'submissionDate': data['submissionDate'] as Timestamp?,
          'status': _safeParseString(data['status']).isEmpty ? 'Baru' : _safeParseString(data['status']),
          'notes': _safeParseString(data['notes']),
          'reviewedBy': data['reviewedBy'],
          'reviewDate': data['reviewDate'] as Timestamp?,
          'supportingDocuments': _safeParseSupportingDocuments(data['supportingDocuments']),
        };
      }).toList();
    } catch (e) {
      print('Error getting submissions: $e');
      return [];
    }
  }

  // Get submission by ID with detailed information
  Future<Map<String, dynamic>?> getSubmissionById(String submissionId) async {
    try {
      final doc = await _firestore.collection('applications').doc(submissionId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      final userId = _safeParseString(data['userId']);
      final programId = _safeParseString(data['programId']);

      // Get user details
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.exists ? userDoc.data()! : {};

      // Get program details
      final programDoc = await _firestore.collection('programs').doc(programId).get();
      final programData = programDoc.exists ? programDoc.data()! : {};

      return {
        'id': doc.id,
        'userId': userId,
        'programId': programId,
        'programName': _safeParseString(data['programName']),
        'userName': _safeParseString(data['userName']),
        'userEmail': _safeParseString(data['userEmail']),
        'submissionDate': data['submissionDate'] as Timestamp?,
        'status': _safeParseString(data['status']).isEmpty ? 'Baru' : _safeParseString(data['status']),
        'notes': _safeParseString(data['notes']),
        'reviewedBy': data['reviewedBy'],
        'reviewDate': data['reviewDate'] as Timestamp?,
        'supportingDocuments': _safeParseSupportingDocuments(data['supportingDocuments']),
        'userDetails': {
          'fullName': _safeParseString(userData['fullName']),
          'email': _safeParseString(userData['email']),
          'phoneNumber': _safeParseString(userData['phoneNumber']),
          'location': _safeParseString(userData['location']),
          'nik': _safeParseString(userData['nik']),
          'jobType': _safeParseString(userData['jobType']),
          'monthlyIncome': _safeParseInt(userData['monthlyIncome']),
          'accountStatus': _safeParseString(userData['accountStatus']),
          'profilePictureUrl': _safeParseString(userData['profilePictureUrl']),
          'ktpPictureUrl': _safeParseString(userData['ktpPictureUrl']),
        },
        'programDetails': {
          'programName': _safeParseString(programData['programName']),
          'organizer': _safeParseString(programData['organizer']),
          'category': _safeParseString(programData['category']),
          'description': _safeParseString(programData['description']),
          'termsAndConditions': _safeParseString(programData['termsAndConditions']),
          'status': _safeParseString(programData['status']),
        },
      };
    } catch (e) {
      print('Error getting submission: $e');
      return null;
    }
  }

  // Update submission status
  Future<bool> updateSubmissionStatus({
    required String submissionId,
    required String newStatus,
    String? notes,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'status': newStatus,
        'reviewedBy': currentUser.uid,
        'reviewDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (notes != null && notes.isNotEmpty) {
        updateData['notes'] = notes;
      }

      await _firestore.collection('applications').doc(submissionId).update(updateData);

      // Update total applications count in the program
      final submissionDoc = await _firestore.collection('applications').doc(submissionId).get();
      if (submissionDoc.exists) {
        final programId = _safeParseString(submissionDoc.data()!['programId']);
        if (programId.isNotEmpty) {
          await _updateProgramApplicationCount(programId);
        }
      }

      return true;
    } catch (e) {
      print('Error updating submission status: $e');
      return false;
    }
  }

  // Approve submission
  Future<bool> approveSubmission({
    required String submissionId,
    String? notes,
  }) async {
    return await updateSubmissionStatus(
      submissionId: submissionId,
      newStatus: 'Disetujui',
      notes: notes,
    );
  }

  // Reject submission
  Future<bool> rejectSubmission({
    required String submissionId,
    String? notes,
  }) async {
    return await updateSubmissionStatus(
      submissionId: submissionId,
      newStatus: 'Ditolak',
      notes: notes,
    );
  }

  // Get unique program names for filter
  Future<List<String>> getProgramNames() async {
    try {
      final querySnapshot = await _firestore.collection('applications').get();

      final programNames = <String>{};
      for (final doc in querySnapshot.docs) {
        final programName = _safeParseString(doc.data()['programName']);
        if (programName.isNotEmpty) {
          programNames.add(programName);
        }
      }

      final result = ['Semua Program', ...programNames.toList()];
      result.sort((a, b) => a == 'Semua Program' ? -1 : b == 'Semua Program' ? 1 : a.compareTo(b));
      return result;
    } catch (e) {
      print('Error getting program names: $e');
      return ['Semua Program'];
    }
  }

  // Get submissions count by status
  Future<Map<String, int>> getSubmissionsCountByStatus() async {
    try {
      final results = await Future.wait([
        _firestore.collection('applications').where('status', isEqualTo: 'Baru').count().get(),
        _firestore.collection('applications').where('status', isEqualTo: 'Diproses').count().get(),
        _firestore.collection('applications').where('status', isEqualTo: 'Disetujui').count().get(),
        _firestore.collection('applications').where('status', isEqualTo: 'Ditolak').count().get(),
      ]);

      return {
        'Baru': results[0].count ?? 0,
        'Diproses': results[1].count ?? 0,
        'Disetujui': results[2].count ?? 0,
        'Ditolak': results[3].count ?? 0,
      };
    } catch (e) {
      print('Error getting submissions count: $e');
      return {'Baru': 0, 'Diproses': 0, 'Disetujui': 0, 'Ditolak': 0};
    }
  }

  // Update program application count
  Future<void> _updateProgramApplicationCount(String programId) async {
    try {
      if (programId.isEmpty) return;
      
      final applicationsCount = await _firestore
          .collection('applications')
          .where('programId', isEqualTo: programId)
          .count()
          .get();

      await _firestore.collection('programs').doc(programId).update({
        'totalApplications': applicationsCount.count ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating program application count: $e');
    }
  }

  // Delete submission (if needed)
  Future<bool> deleteSubmission(String submissionId) async {
    try {
      // Get submission data first to update program count
      final submissionDoc = await _firestore.collection('applications').doc(submissionId).get();
      if (submissionDoc.exists) {
        final programId = _safeParseString(submissionDoc.data()!['programId']);

        // Delete submission
        await _firestore.collection('applications').doc(submissionId).delete();

        // Update program application count
        if (programId.isNotEmpty) {
          await _updateProgramApplicationCount(programId);
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting submission: $e');
      return false;
    }
  }

  // Get recent submissions (for dashboard)
  Future<List<Map<String, dynamic>>> getRecentSubmissions({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('applications')
          .orderBy('submissionDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userName': _safeParseString(data['userName']),
          'programName': _safeParseString(data['programName']),
          'status': _safeParseString(data['status']).isEmpty ? 'Baru' : _safeParseString(data['status']),
          'submissionDate': data['submissionDate'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      print('Error getting recent submissions: $e');
      return [];
    }
  }
}