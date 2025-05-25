import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/dashboard_statistics.dart';

class RecentActivitiesWidget extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivitiesWidget({super.key, required this.activities});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
      case 'pending':
        return Colors.blue;
      case 'diproses':
      case 'processing':
        return Colors.orange;
      case 'disetujui':
      case 'approved':
        return Colors.green;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
      case 'pending':
        return Icons.fiber_new_rounded;
      case 'diproses':
      case 'processing':
        return Icons.hourglass_empty_rounded;
      case 'disetujui':
      case 'approved':
        return Icons.check_circle_rounded;
      case 'ditolak':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada aktivitas terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aktivitas akan muncul di sini',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          // Header - COMPACT
          Container(
            padding: const EdgeInsets.all(16), // REDUCED from 20
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade50.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // REDUCED from 8
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Colors.blue.shade700,
                    size: 18, // REDUCED from 20
                  ),
                ),
                const SizedBox(width: 10), // REDUCED from 12
                Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 16, // REDUCED from 18
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ), // REDUCED
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10), // REDUCED from 12
                  ),
                  child: Text(
                    '${activities.length} item',
                    style: TextStyle(
                      fontSize: 11, // REDUCED from 12
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activities List - SCROLLABLE
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16), // REDUCED from 20
              itemCount: activities.length,
              separatorBuilder:
                  (context, index) => Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                    ), // REDUCED from 8
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey.shade200,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final formattedDate =
                    activity.submissionDate != null
                        ? DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(activity.submissionDate!)
                        : 'Tanggal tidak tersedia';

                return Container(
                  padding: const EdgeInsets.all(10), // REDUCED from 12
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10), // REDUCED from 12
                    border: Border.all(
                      color: _getStatusColor(
                        activity.status,
                      ).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status Icon - COMPACT
                      Container(
                        padding: const EdgeInsets.all(6), // REDUCED from 8
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(
                                activity.status,
                              ).withValues(alpha: 0.2),
                              _getStatusColor(
                                activity.status,
                              ).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            6,
                          ), // REDUCED from 8
                          border: Border.all(
                            color: _getStatusColor(
                              activity.status,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getStatusIcon(activity.status),
                          color: _getStatusColor(activity.status),
                          size: 16, // REDUCED from 20
                        ),
                      ),
                      const SizedBox(width: 10), // REDUCED from 12
                      // Content - COMPACT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.userName,
                              style: const TextStyle(
                                fontSize: 12, // REDUCED from 14
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1), // REDUCED from 2
                            Text(
                              'mengajukan ${activity.programName}',
                              style: TextStyle(
                                fontSize: 11, // REDUCED from 13
                                color: Colors.grey.shade600,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4), // REDUCED from 6
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ), // REDUCED
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getStatusColor(
                                          activity.status,
                                        ).withValues(alpha: 0.2),
                                        _getStatusColor(
                                          activity.status,
                                        ).withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // REDUCED from 10
                                    border: Border.all(
                                      color: _getStatusColor(
                                        activity.status,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    activity.status,
                                    style: TextStyle(
                                      fontSize: 10, // REDUCED from 11
                                      color: _getStatusColor(activity.status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6), // REDUCED from 8
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 10, // REDUCED from 12
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 3), // REDUCED from 4
                                Expanded(
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 10, // REDUCED from 11
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
