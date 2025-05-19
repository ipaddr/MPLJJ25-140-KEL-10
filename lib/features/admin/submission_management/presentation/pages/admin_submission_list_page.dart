import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart'; // Adjust if needed
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_submission_card_widget.dart';
import 'package:intl/intl.dart'; // For date formatting

class AdminSubmissionListPage extends StatefulWidget {
  const AdminSubmissionListPage({super.key});

  @override
  State<AdminSubmissionListPage> createState() =>
      _AdminSubmissionListPageState();
}

class _AdminSubmissionListPageState extends State<AdminSubmissionListPage> {
  // Placeholder data - replace with actual data fetching logic
  final List<Map<String, dynamic>> _allSubmissions = [
    {
      'id': 'sub_001',
      'user_name': 'Budi Santoso',
      'program_name': 'Beasiswa Pendidikan Anak',
      'status': 'Baru',
      'submission_date': DateTime(2023, 10, 26),
      // Add more submission details here for detail page
      'user_id': 'user_001',
      'program_id': 'prog_001',
      'user_details': {'email': 'budi@example.com', 'lokasi': 'Jakarta'},
      ' syarat_terpenuhi': {'KTP': true, 'KK': true, 'Slip Gaji': false},
      'catatan_admin': 'Menunggu review dokumen',
    },
    {
      'id': 'sub_002',
      'user_name': 'Siti Aminah',
      'program_name': 'Bantuan Kesehatan Lansia',
      'status': 'Diproses',
      'submission_date': DateTime(2023, 10, 25),
      'user_id': 'user_002',
      'program_id': 'prog_002',
      'user_details': {'email': 'siti@example.com', 'lokasi': 'Bandung'},
      ' syarat_terpenuhi': {'Surat Sakit': true, 'Kartu Lansia': true},
      'catatan_admin': 'Dokumen lengkap, menunggu persetujuan',
    },
    {
      'id': 'sub_003',
      'user_name': 'Agus Dharmawan',
      'program_name': 'Pelatihan Keterampilan Digital',
      'status': 'Disetujui',
      'submission_date': DateTime(2023, 10, 20),
      'user_id': 'user_003',
      'program_id': 'prog_003',
      'user_details': {'email': 'agus@example.com', 'lokasi': 'Surabaya'},
      ' syarat_terpenuhi': {'Formulir Online': true, 'Portofolio': true},
      'catatan_admin': 'Peserta terdaftar di pelatihan',
    },
    {
      'id': 'sub_004',
      'user_name': 'Dewi Lestari',
      'program_name': 'Bantuan Pangan Keluarga Pra-Sejahtera',
      'status': 'Ditolak',
      'submission_date': DateTime(2023, 10, 18),
      'user_id': 'user_004',
      'program_id': 'prog_004',
      'user_details': {'email': 'dewi@example.com', 'lokasi': 'Yogyakarta'},
      ' syarat_terpenuhi': {'Surat Keterangan Tidak Mampu': false},
      'catatan_admin': 'Persyaratan tidak terpenuhi',
    },
    // Add more placeholder submissions
  ];

  List<Map<String, dynamic>> _filteredSubmissions = [];
  String? _selectedProgramFilter;
  String? _selectedStatusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  // Placeholder filter options (fetch from backend in real app)
  final List<String> _programNames = [
    'Semua Program',
    'Beasiswa Pendidikan Anak',
    'Bantuan Kesehatan Lansia',
    'Pelatihan Keterampilan Digital',
    'Bantuan Pangan Keluarga Pra-Sejahtera',
  ];
  final List<String> _statuses = [
    'Semua Status',
    'Baru',
    'Diproses',
    'Disetujui',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _filteredSubmissions = _allSubmissions;
    _selectedProgramFilter = _programNames.first;
    _selectedStatusFilter = _statuses.first;
  }

  void _filterSubmissions() {
    List<Map<String, dynamic>> submissions =
        _allSubmissions.where((submission) {
          // Program Filter
          final programMatch =
              _selectedProgramFilter == _programNames.first ||
              submission['program_name'] == _selectedProgramFilter;

          // Status Filter
          final statusMatch =
              _selectedStatusFilter == _statuses.first ||
              submission['status'] == _selectedStatusFilter;

          // Date Range Filter
          final submissionDate = submission['submission_date'] as DateTime;
          final dateMatch =
              (_startDateFilter == null ||
                  submissionDate.isAfter(
                    _startDateFilter!.subtract(const Duration(days: 1)),
                  )) &&
              (_endDateFilter == null ||
                  submissionDate.isBefore(
                    _endDateFilter!.add(const Duration(days: 1)),
                  ));

          return programMatch && statusMatch && dateMatch;
        }).toList();

    setState(() {
      _filteredSubmissions = submissions;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDateFilter != null && _endDateFilter != null
              ? DateTimeRange(start: _startDateFilter!, end: _endDateFilter!)
              : null,
    );

    if (picked != null) {
      setState(() {
        _startDateFilter = picked.start;
        _endDateFilter = picked.end;
      });
      _filterSubmissions();
    }
  }

  void _viewSubmissionDetail(String submissionId) {
    // TODO: Navigate to Submission Detail Page
    context.go(
      '${RouteNames.adminSubmissionDetail}/$submissionId',
    ); // Example with go_router
  }

  void _approveSubmission(String submissionId) {
    // TODO: Implement approve logic (show confirmation, call API to update status)
    print('Attempting to approve submission with ID: $submissionId');
    // Example: Update status in local list (for demonstration)
    setState(() {
      final submissionIndex = _allSubmissions.indexWhere(
        (sub) => sub['id'] == submissionId,
      );
      if (submissionIndex != -1) {
        _allSubmissions[submissionIndex]['status'] = 'Disetujui';
        _filterSubmissions(); // Re-filter after status update
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submission $submissionId approved (placeholder)'),
      ),
    );
  }

  void _rejectSubmission(String submissionId) {
    // TODO: Implement reject logic (show confirmation, call API to update status)
    print('Attempting to reject submission with ID: $submissionId');
    // Example: Update status in local list (for demonstration)
    setState(() {
      final submissionIndex = _allSubmissions.indexWhere(
        (sub) => sub['id'] == submissionId,
      );
      if (submissionIndex != -1) {
        _allSubmissions[submissionIndex]['status'] = 'Ditolak';
        _filterSubmissions(); // Re-filter after status update
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Submission $submissionId rejected (placeholder)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengajuan Bantuan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      drawer:
          const AdminNavigationDrawer(), // Your Admin Navigation Drawer widget
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filters (Program, Status, Date Range)
                  Row(
                    children: [
                      // Program Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Program',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          value: _selectedProgramFilter,
                          items:
                              _programNames.map((String programName) {
                                return DropdownMenuItem<String>(
                                  value: programName,
                                  child: Text(programName),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedProgramFilter = newValue;
                            });
                            _filterSubmissions();
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Status',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          value: _selectedStatusFilter,
                          items:
                              _statuses.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedStatusFilter = newValue;
                            });
                            _filterSubmissions();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Date Range Filter Button
                  OutlinedButton(
                    onPressed: () => _selectDateRange(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 20.0),
                        const SizedBox(width: 8.0),
                        Text(
                          _startDateFilter == null || _endDateFilter == null
                              ? 'Pilih Rentang Tanggal'
                              : '${DateFormat('dd MMM yyyy').format(_startDateFilter!)} - ${DateFormat('dd MMM yyyy').format(_endDateFilter!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_startDateFilter !=
                            null) // Add clear button if date is selected
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20.0),
                            onPressed: () {
                              setState(() {
                                _startDateFilter = null;
                                _endDateFilter = null;
                              });
                              _filterSubmissions();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Submission List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = _filteredSubmissions[index];
                  return AdminSubmissionCardWidget(
                    submission: submission,
                    onViewDetail: () => _viewSubmissionDetail(submission['id']),
                    onApprove: () => _approveSubmission(submission['id']),
                    onReject: () => _rejectSubmission(submission['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
