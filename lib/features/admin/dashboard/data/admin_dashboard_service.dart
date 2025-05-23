import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get total users count
  Future<int> getTotalUsersCount() async {
    try {
      final querySnapshot = await _firestore.collection('users').count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting users count: $e');
      return 0;
    }
  }

  // Get active programs count
  Future<int> getActiveProgramsCount() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('programs')
              .where('status', isEqualTo: 'active')
              .count()
              .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting active programs count: $e');
      return 0;
    }
  }

  // Get total applications count
  Future<int> getTotalApplicationsCount() async {
    try {
      final querySnapshot =
          await _firestore.collection('applications').count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting applications count: $e');
      return 0;
    }
  }

  // Get approved applications count
  Future<int> getApprovedApplicationsCount() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('applications')
              .where('status', isEqualTo: 'Disetujui')
              .count()
              .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting approved applications count: $e');
      return 0;
    }
  }

  // Get rejected applications count
  Future<int> getRejectedApplicationsCount() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('applications')
              .where('status', isEqualTo: 'Ditolak')
              .count()
              .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting rejected applications count: $e');
      return 0;
    }
  }

  // Get pending applications count
  Future<int> getPendingApplicationsCount() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('applications')
              .where('status', whereIn: ['Baru', 'Diproses'])
              .count()
              .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting pending applications count: $e');
      return 0;
    }
  }

  // Get recent activities (last 10 applications)
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('applications')
              .orderBy('submissionDate', descending: true)
              .limit(10)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userName': data['userName'] ?? 'Unknown User',
          'programName': data['programName'] ?? 'Unknown Program',
          'status': data['status'] ?? 'Unknown',
          'submissionDate': data['submissionDate'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Get users by verification status
  Future<Map<String, int>> getUsersByVerificationStatus() async {
    try {
      final activeUsers =
          await _firestore
              .collection('users')
              .where('accountStatus', isEqualTo: 'active')
              .count()
              .get();

      final pendingUsers =
          await _firestore
              .collection('users')
              .where('accountStatus', isEqualTo: 'pending_verification')
              .count()
              .get();

      final suspendedUsers =
          await _firestore
              .collection('users')
              .where('accountStatus', isEqualTo: 'suspended')
              .count()
              .get();

      return {
        'active': activeUsers.count ?? 0,
        'pending': pendingUsers.count ?? 0,
        'suspended': suspendedUsers.count ?? 0,
      };
    } catch (e) {
      print('Error getting users by status: $e');
      return {'active': 0, 'pending': 0, 'suspended': 0};
    }
  }

  // Get applications by status for chart data
  Future<Map<String, int>> getApplicationsByStatus() async {
    try {
      final newApplications =
          await _firestore
              .collection('applications')
              .where('status', isEqualTo: 'Baru')
              .count()
              .get();

      final processingApplications =
          await _firestore
              .collection('applications')
              .where('status', isEqualTo: 'Diproses')
              .count()
              .get();

      final approvedApplications =
          await _firestore
              .collection('applications')
              .where('status', isEqualTo: 'Disetujui')
              .count()
              .get();

      final rejectedApplications =
          await _firestore
              .collection('applications')
              .where('status', isEqualTo: 'Ditolak')
              .count()
              .get();

      return {
        'new': newApplications.count ?? 0,
        'processing': processingApplications.count ?? 0,
        'approved': approvedApplications.count ?? 0,
        'rejected': rejectedApplications.count ?? 0,
      };
    } catch (e) {
      print('Error getting applications by status: $e');
      return {'new': 0, 'processing': 0, 'approved': 0, 'rejected': 0};
    }
  }
}
