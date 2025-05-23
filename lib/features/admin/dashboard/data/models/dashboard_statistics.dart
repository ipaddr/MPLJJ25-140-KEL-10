class DashboardStatistics {
  final int totalUsers;
  final int activePrograms;
  final int totalApplications;
  final int approvedApplications;
  final int rejectedApplications;
  final int pendingApplications;
  final Map<String, int> usersByStatus;
  final Map<String, int> applicationsByStatus;
  final List<RecentActivity> recentActivities;

  DashboardStatistics({
    required this.totalUsers,
    required this.activePrograms,
    required this.totalApplications,
    required this.approvedApplications,
    required this.rejectedApplications,
    required this.pendingApplications,
    required this.usersByStatus,
    required this.applicationsByStatus,
    required this.recentActivities,
  });
}

class RecentActivity {
  final String id;
  final String userName;
  final String programName;
  final String status;
  final DateTime? submissionDate;

  RecentActivity({
    required this.id,
    required this.userName,
    required this.programName,
    required this.status,
    this.submissionDate,
  });

  factory RecentActivity.fromMap(Map<String, dynamic> map) {
    return RecentActivity(
      id: map['id'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      programName: map['programName'] ?? 'Unknown Program',
      status: map['status'] ?? 'Unknown',
      submissionDate: map['submissionDate']?.toDate(),
    );
  }
}
