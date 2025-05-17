import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:intl/intl.dart';

class AdminSubmissionDetailPage extends StatelessWidget {
  final String submissionId; // To receive the submission ID

  const AdminSubmissionDetailPage({super.key, required this.submissionId});

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
    // TODO: Fetch submission data based on submissionId
    // Placeholder fetching logic (replace with actual data fetching from backend)
    final Map<String, dynamic> submissionData = {
      'id': submissionId,
      'user_name': 'Nama Pengguna ${submissionId}',
      'program_name': 'Nama Program ${submissionId}',
      'status': 'Baru', // Example status
      'submission_date': DateTime.now().subtract(
        Duration(days: int.parse(submissionId.split('_').last)),
      ), // Example date
      'user_id': 'user_${submissionId.split('_').last}',
      'program_id': 'prog_${submissionId.split('_').last}',
      'user_details': {
        'email': 'user${submissionId.split('_').last}@example.com',
        'lokasi': 'Lokasi ${submissionId.split('_').last}',
        'telepon': '08123456789',
        'alamat': 'Jl. Contoh No. ${submissionId.split('_').last}, Kota',
        // Add more user details
      },
      'persyaratan': [
        // Example requirements and their fulfillment status
        {'nama': 'Scan KTP', 'terpenuhi': true},
        {'nama': 'Kartu Keluarga', 'terpenuhi': true},
        {'nama': 'Slip Gaji', 'terpenuhi': false},
        {'nama': 'Surat Keterangan Tidak Mampu', 'terpenuhi': true},
      ],
      'catatan_admin': 'Catatan untuk pengajuan ${submissionId}',
      // Add other relevant submission details
    };

    final statusColor = _getStatusColor(submissionData['status']);
    final submissionDate = submissionData['submission_date'] as DateTime?;
    final formattedDate =
        submissionDate != null
            ? DateFormat('dd MMM yyyy').format(submissionDate)
            : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          // Back button to Submission List Page
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminSubmissionManagement); // Navigate back
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade200,
            ], // Consistent gradient
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Submission Info
                Text(
                  'Pengajuan dari ${submissionData['user_name'] ?? 'N/A'} untuk Program ${submissionData['program_name'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        submissionData['status'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Tanggal Pengajuan: $formattedDate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32.0),

                // User Details
                const Text(
                  'Detail Pengguna',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Email: ${submissionData['user_details']?['email'] ?? 'N/A'}',
                ),
                Text(
                  'Lokasi: ${submissionData['user_details']?['lokasi'] ?? 'N/A'}',
                ),
                Text(
                  'Telepon: ${submissionData['user_details']?['telepon'] ?? 'N/A'}',
                ),
                Text(
                  'Alamat: ${submissionData['user_details']?['alamat'] ?? 'N/A'}',
                ),

                // Add more user details as needed
                const Divider(height: 32.0),

                // Requirement Fulfillment
                const Text(
                  'Pemenuhan Persyaratan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                ...(submissionData['persyaratan']
                            as List<Map<String, dynamic>>? ??
                        [])
                    .map((req) {
                      return Row(
                        children: [
                          Icon(
                            req['terpenuhi'] == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                req['terpenuhi'] == true
                                    ? Colors.green
                                    : Colors.red,
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(req['nama'] ?? 'N/A'),
                        ],
                      );
                    })
                    .toList(),
                const Divider(height: 32.0),

                // Admin Notes
                const Text(
                  'Catatan Admin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(submissionData['catatan_admin'] ?? 'Tidak ada catatan.'),

                const Divider(height: 32.0),

                // Action Buttons (Approve/Reject based on current status)
                if (submissionData['status'] == 'Baru' ||
                    submissionData['status'] == 'Diproses')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement approve logic (call API, update status, navigate back)
                          print(
                            'Approving submission: ${submissionData['id']}',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Approving submission (placeholder)',
                              ),
                            ),
                          );
                          // After action, might navigate back
                          // context.go(RouteNames.adminSubmissionManagement);
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Setujui',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement reject logic (call API, update status, navigate back)
                          print(
                            'Rejecting submission: ${submissionData['id']}',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Rejecting submission (placeholder)',
                              ),
                            ),
                          );
                          // After action, might navigate back
                          // context.go(RouteNames.adminSubmissionManagement);
                        },
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Tolak',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
