import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

/// Service untuk manajemen pengajuan oleh admin
///
/// Menyediakan fungsi-fungsi untuk mengambil daftar pengajuan,
/// memperbarui status pengajuan, dan operasi terkait pengajuan lainnya
class AdminSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _logger = Logger('AdminSubmissionService');

  // Collection paths
  static const String _applicationsCollection = 'applications';
  static const String _usersCollection = 'users';
  static const String _programsCollection = 'programs';

  /// Mengambil semua pengajuan dengan filter opsional
  Future<List<Map<String, dynamic>>> getAllSubmissions({
    String? programFilter,
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_applicationsCollection);

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

      return _mapApplicationDocuments(querySnapshot.docs);
    } catch (e) {
      _logger.severe('Error getting submissions', e);
      return [];
    }
  }

  /// Mengambil pengajuan berdasarkan ID dengan informasi detail
  Future<Map<String, dynamic>?> getSubmissionById(String submissionId) async {
    try {
      final doc = await _firestore
          .collection(_applicationsCollection)
          .doc(submissionId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      final userId = _safeParseString(data['userId']);
      final programId = _safeParseString(data['programId']);

      // Get user and program details in parallel
      final results = await Future.wait([
        _firestore.collection(_usersCollection).doc(userId).get(),
        _firestore.collection(_programsCollection).doc(programId).get(),
      ]);

      final userDoc = results[0];
      final programDoc = results[1];
      
      final userData = userDoc.exists ? userDoc.data()! : <String, dynamic>{};
      final programData = programDoc.exists ? programDoc.data()! : <String, dynamic>{};

      return {
        'id': doc.id,
        'userId': userId,
        'programId': programId,
        'programName': _safeParseString(data['programName']),
        'userName': _safeParseString(data['userName']),
        'userEmail': _safeParseString(data['userEmail']),
        'submissionDate': data['submissionDate'] as Timestamp?,
        'status': _safeParseString(data['status']).isEmpty
            ? 'Baru'
            : _safeParseString(data['status']),
        'notes': _safeParseString(data['notes']),
        'reviewedBy': data['reviewedBy'],
        'reviewDate': data['reviewDate'] as Timestamp?,
        'supportingDocuments': _safeParseSupportingDocuments(
          data['supportingDocuments'],
        ),
        'userDetails': _mapUserDetails(Map<String, dynamic>.from(userData)),
        'programDetails': _mapProgramDetails(Map<String, dynamic>.from(programData)),
      };
    } catch (e) {
      _logger.severe('Error getting submission details: $submissionId', e);
      return null;
    }
  }

  /// Memperbarui status pengajuan
  Future<bool> updateSubmissionStatus({
    required String submissionId,
    required String newStatus,
    String? notes,
    required String status,
    String? reviewNotes,
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

      await _firestore
          .collection(_applicationsCollection)
          .doc(submissionId)
          .update(updateData);

      // Update program application count
      final submissionDoc = await _firestore
          .collection(_applicationsCollection)
          .doc(submissionId)
          .get();
          
      if (submissionDoc.exists) {
        final programId = _safeParseString(submissionDoc.data()!['programId']);
        if (programId.isNotEmpty) {
          await _updateProgramApplicationCount(programId);
        }
      }

      return true;
    } catch (e) {
      _logger.severe('Error updating submission status: $submissionId', e);
      return false;
    }
  }

  /// Menyetujui pengajuan
  Future<bool> approveSubmission({
    required String submissionId,
    String? notes,
  }) async {
    return await updateSubmissionStatus(
      submissionId: submissionId,
      newStatus: 'Disetujui',
      notes: notes,
      status: '',
    );
  }

  /// Menolak pengajuan
  Future<bool> rejectSubmission({
    required String submissionId,
    String? notes,
  }) async {
    return await updateSubmissionStatus(
      submissionId: submissionId,
      newStatus: 'Ditolak',
      notes: notes,
      status: '',
    );
  }

  /// Mendapatkan nama-nama program unik untuk filter
  Future<List<String>> getProgramNames() async {
    try {
      final querySnapshot = await _firestore
          .collection(_applicationsCollection)
          .get();

      final programNames = <String>{};
      for (final doc in querySnapshot.docs) {
        final programName = _safeParseString(doc.data()['programName']);
        if (programName.isNotEmpty) {
          programNames.add(programName);
        }
      }

      final result = ['Semua Program', ...programNames.toList()];
      result.sort((a, b) =>
          a == 'Semua Program' ? -1 : b == 'Semua Program' ? 1 : a.compareTo(b),
      );
      return result;
    } catch (e) {
      _logger.severe('Error getting program names', e);
      return ['Semua Program'];
    }
  }

  /// Mendapatkan jumlah pengajuan berdasarkan status
  Future<Map<String, int>> getSubmissionsCountByStatus() async {
    try {
      // Get counts for all statuses in parallel for better performance
      final results = await Future.wait([
        _getCountByStatus('Baru'),
        _getCountByStatus('Diproses'),
        _getCountByStatus('Disetujui'),
        _getCountByStatus('Ditolak'),
      ]);

      return {
        'Baru': results[0],
        'Diproses': results[1],
        'Disetujui': results[2],
        'Ditolak': results[3],
      };
    } catch (e) {
      _logger.severe('Error getting submissions count by status', e);
      return {'Baru': 0, 'Diproses': 0, 'Disetujui': 0, 'Ditolak': 0};
    }
  }

  /// Membantu mendapatkan jumlah berdasarkan status
  Future<int> _getCountByStatus(String status) async {
    try {
      final result = await _firestore
          .collection(_applicationsCollection)
          .where('status', isEqualTo: status)
          .count()
          .get();
      return result.count ?? 0;
    } catch (e) {
      _logger.warning('Error getting count for status: $status', e);
      return 0;
    }
  }

  /// Memperbarui jumlah pengajuan untuk program tertentu
  Future<void> _updateProgramApplicationCount(String programId) async {
    try {
      if (programId.isEmpty) return;

      final applicationsCount = await _firestore
          .collection(_applicationsCollection)
          .where('programId', isEqualTo: programId)
          .count()
          .get();

      await _firestore.collection(_programsCollection).doc(programId).update({
        'totalApplications': applicationsCount.count ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.warning('Error updating program application count: $programId', e);
    }
  }

  /// Menghapus pengajuan
  Future<bool> deleteSubmission(String submissionId) async {
    try {
      // Get submission data first to update program count
      final submissionDoc = await _firestore
          .collection(_applicationsCollection)
          .doc(submissionId)
          .get();
          
      if (submissionDoc.exists) {
        final programId = _safeParseString(submissionDoc.data()!['programId']);

        // Delete submission
        await _firestore
            .collection(_applicationsCollection)
            .doc(submissionId)
            .delete();

        // Update program application count
        if (programId.isNotEmpty) {
          await _updateProgramApplicationCount(programId);
        }

        return true;
      }
      return false;
    } catch (e) {
      _logger.severe('Error deleting submission: $submissionId', e);
      return false;
    }
  }

  /// Mendapatkan pengajuan terbaru (untuk dashboard)
  Future<List<Map<String, dynamic>>> getRecentSubmissions({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_applicationsCollection)
          .orderBy('submissionDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userName': _safeParseString(data['userName']),
          'programName': _safeParseString(data['programName']),
          'status': _safeParseString(data['status']).isEmpty
              ? 'Baru'
              : _safeParseString(data['status']),
          'submissionDate': data['submissionDate'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      _logger.severe('Error getting recent submissions', e);
      return [];
    }
  }

  // Helper Methods

  /// Helper untuk parsing integer dengan aman
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Helper untuk parsing string dengan aman
  static String _safeParseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Helper untuk parsing dokumen pendukung dengan aman
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
        }
        // Handle unexpected data type
        return {
          'fileName': 'Unknown Document',
          'fileUrl': '',
          'uploadDate': null,
          'fileSize': 0,
          'fileType': 'unknown',
        };
      }).toList();
    }

    return [];
  }

  /// Helper untuk memetakan dokumen pengajuan
  List<Map<String, dynamic>> _mapApplicationDocuments(List<DocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'userId': _safeParseString(data['userId']),
        'programId': _safeParseString(data['programId']),
        'programName': _safeParseString(data['programName']),
        'userName': _safeParseString(data['userName']),
        'userEmail': _safeParseString(data['userEmail']),
        'submissionDate': data['submissionDate'] as Timestamp?,
        'status': _safeParseString(data['status']).isEmpty
            ? 'Baru'
            : _safeParseString(data['status']),
        'notes': _safeParseString(data['notes']),
        'reviewedBy': data['reviewedBy'],
        'reviewDate': data['reviewDate'] as Timestamp?,
        'supportingDocuments': _safeParseSupportingDocuments(
          data['supportingDocuments'],
        ),
      };
    }).toList();
  }
  
  /// Helper untuk memetakan detail pengguna
  Map<String, dynamic> _mapUserDetails(Map<String, dynamic> userData) {
    return {
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
    };
  }
  
  /// Helper untuk memetakan detail program
  Map<String, dynamic> _mapProgramDetails(Map<String, dynamic> programData) {
    return {
      'programName': _safeParseString(programData['programName']),
      'organizer': _safeParseString(programData['organizer']),
      'category': _safeParseString(programData['category']),
      'description': _safeParseString(programData['description']),
      'termsAndConditions': _safeParseString(programData['termsAndConditions']),
      'status': _safeParseString(programData['status']),
    };
  }
}