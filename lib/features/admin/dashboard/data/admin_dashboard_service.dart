import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'models/dashboard_statistics.dart';

/// Service untuk mendapatkan data statistik dashboard admin
class AdminDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _programsCollection = FirebaseFirestore.instance.collection('programs');
  final CollectionReference _applicationsCollection = FirebaseFirestore.instance.collection('applications');

  /// Mendapatkan semua statistik dashboard dalam satu permintaan
  Future<DashboardStatistics> getDashboardStatistics() async {
    try {
      // Run requests in parallel for better performance
      final results = await Future.wait([
        getTotalUsersCount(),
        getActiveProgramsCount(),
        getTotalApplicationsCount(),
        getApprovedApplicationsCount(),
        getRejectedApplicationsCount(),
        getPendingApplicationsCount(),
        getUsersByVerificationStatus(),
        getApplicationsByStatus(),
        getRecentActivities(),
      ]);

      // Map results to our statistics object
      return DashboardStatistics(
        totalUsers: results[0] as int,
        activePrograms: results[1] as int,
        totalApplications: results[2] as int,
        approvedApplications: results[3] as int,
        rejectedApplications: results[4] as int,
        pendingApplications: results[5] as int,
        usersByStatus: results[6] as Map<String, int>,
        applicationsByStatus: results[7] as Map<String, int>,
        recentActivities: (results[8] as List<Map<String, dynamic>>)
            .map((data) => RecentActivity.fromMap(data))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error getting dashboard statistics: $e');
      return _getEmptyStatistics();
    }
  }

  /// Mendapatkan jumlah total pengguna
  Future<int> getTotalUsersCount() async {
    try {
      final querySnapshot = await _usersCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting users count: $e');
      return 0;
    }
  }

  /// Mendapatkan jumlah program aktif
  Future<int> getActiveProgramsCount() async {
    try {
      final querySnapshot = await _programsCollection
          .where('status', isEqualTo: 'active')
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting active programs count: $e');
      return 0;
    }
  }

  /// Mendapatkan jumlah total pengajuan
  Future<int> getTotalApplicationsCount() async {
    try {
      final querySnapshot = await _applicationsCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting applications count: $e');
      return 0;
    }
  }

  /// Mendapatkan jumlah pengajuan yang disetujui
  Future<int> getApprovedApplicationsCount() async {
    try {
      final querySnapshot = await _applicationsCollection
          .where('status', isEqualTo: 'Disetujui')
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting approved applications count: $e');
      return 0;
    }
  }

  /// Mendapatkan jumlah pengajuan yang ditolak
  Future<int> getRejectedApplicationsCount() async {
    try {
      final querySnapshot = await _applicationsCollection
          .where('status', isEqualTo: 'Ditolak')
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting rejected applications count: $e');
      return 0;
    }
  }

  /// Mendapatkan jumlah pengajuan yang menunggu
  Future<int> getPendingApplicationsCount() async {
    try {
      final querySnapshot = await _applicationsCollection
          .where('status', whereIn: ['Baru', 'Diproses'])
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting pending applications count: $e');
      return 0;
    }
  }

  /// Mendapatkan aktivitas terbaru (10 pengajuan terakhir)
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final querySnapshot = await _applicationsCollection
          .orderBy('submissionDate', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'userName': data['userName'] ?? 'Unknown User',
          'programName': data['programName'] ?? 'Unknown Program',
          'status': data['status'] ?? 'Unknown',
          'submissionDate': data['submissionDate'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting recent activities: $e');
      return [];
    }
  }

  /// Mendapatkan pengguna berdasarkan status verifikasi
  Future<Map<String, int>> getUsersByVerificationStatus() async {
    try {
      // Optimize to use a single query with aggregation if available in your Firestore plan
      final results = await Future.wait([
        _usersCollection.where('accountStatus', isEqualTo: 'active').count().get(),
        _usersCollection.where('accountStatus', isEqualTo: 'pending_verification').count().get(),
        _usersCollection.where('accountStatus', isEqualTo: 'suspended').count().get(),
      ]);

      return {
        'active': results[0].count ?? 0,
        'pending': results[1].count ?? 0,
        'suspended': results[2].count ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting users by status: $e');
      return {'active': 0, 'pending': 0, 'suspended': 0};
    }
  }

  /// Mendapatkan pengajuan berdasarkan status untuk data grafik
  Future<Map<String, int>> getApplicationsByStatus() async {
    try {
      // Optimize to use a single query with aggregation if available in your Firestore plan
      final results = await Future.wait([
        _applicationsCollection.where('status', isEqualTo: 'Baru').count().get(),
        _applicationsCollection.where('status', isEqualTo: 'Diproses').count().get(),
        _applicationsCollection.where('status', isEqualTo: 'Disetujui').count().get(),
        _applicationsCollection.where('status', isEqualTo: 'Ditolak').count().get(),
      ]);

      return {
        'new': results[0].count ?? 0,
        'processing': results[1].count ?? 0,
        'approved': results[2].count ?? 0,
        'rejected': results[3].count ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting applications by status: $e');
      return {'new': 0, 'processing': 0, 'approved': 0, 'rejected': 0};
    }
  }

  /// Mendapatkan statistik kosong ketika terjadi error
  DashboardStatistics _getEmptyStatistics() {
    return DashboardStatistics(
      totalUsers: 0,
      activePrograms: 0,
      totalApplications: 0,
      approvedApplications: 0,
      rejectedApplications: 0,
      pendingApplications: 0,
      usersByStatus: {'active': 0, 'pending': 0, 'suspended': 0},
      applicationsByStatus: {'new': 0, 'processing': 0, 'approved': 0, 'rejected': 0},
      recentActivities: [],
    );
  }
}