import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/dashboard_statistics.dart';

class RecentActivitiesWidget extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivitiesWidget({
    super.key,
    required this.activities,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Baru':
        return Colors.blue;
      case 'Diproses':
        return Colors.orange;
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Belum ada aktivitas terbaru',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final formattedDate = activity.submissionDate != null
                    ? DateFormat('dd MMM yyyy, HH:mm').format(activity.submissionDate!)
                    : 'Tanggal tidak tersedia';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(activity.status).withOpacity(0.1),
                    child: Icon(
                      Icons.assignment,
                      color: _getStatusColor(activity.status),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${activity.userName} mengajukan ${activity.programName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(activity.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(activity.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}