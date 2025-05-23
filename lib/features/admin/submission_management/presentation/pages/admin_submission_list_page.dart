import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_submission_card_widget.dart';
import '../../data/admin_submission_service.dart';
import 'package:intl/intl.dart';

class AdminSubmissionListPage extends StatefulWidget {
  const AdminSubmissionListPage({super.key});

  @override
  State<AdminSubmissionListPage> createState() =>
      _AdminSubmissionListPageState();
}

class _AdminSubmissionListPageState extends State<AdminSubmissionListPage> {
  final AdminSubmissionService _submissionService = AdminSubmissionService();
  
  List<Map<String, dynamic>> _allSubmissions = [];
  List<Map<String, dynamic>> _filteredSubmissions = [];
  List<String> _programNames = ['Semua Program'];
  
  String? _selectedProgramFilter;
  String? _selectedStatusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool _isLoading = true;
  String? _errorMessage;

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
    _selectedProgramFilter = _programNames.first;
    _selectedStatusFilter = _statuses.first;
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load program names and submissions concurrently
      final results = await Future.wait([
        _submissionService.getProgramNames(),
        _submissionService.getAllSubmissions(
          programFilter: _selectedProgramFilter != 'Semua Program' ? _selectedProgramFilter : null,
          statusFilter: _selectedStatusFilter != 'Semua Status' ? _selectedStatusFilter : null,
          startDate: _startDateFilter,
          endDate: _endDateFilter,
        ),
      ]);

      final programNames = results[0] as List<String>;
      final submissions = results[1] as List<Map<String, dynamic>>;

      setState(() {
        _programNames = programNames;
        if (!_programNames.contains(_selectedProgramFilter)) {
          _selectedProgramFilter = _programNames.first;
        }
        _allSubmissions = submissions;
        _filteredSubmissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengajuan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _filterSubmissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final submissions = await _submissionService.getAllSubmissions(
        programFilter: _selectedProgramFilter != 'Semua Program' ? _selectedProgramFilter : null,
        statusFilter: _selectedStatusFilter != 'Semua Status' ? _selectedStatusFilter : null,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );

      setState(() {
        _filteredSubmissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memfilter data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDateFilter != null && _endDateFilter != null
          ? DateTimeRange(start: _startDateFilter!, end: _endDateFilter!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDateFilter = picked.start;
        _endDateFilter = picked.end;
      });
      await _filterSubmissions();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDateFilter = null;
      _endDateFilter = null;
    });
    _filterSubmissions();
  }

  void _viewSubmissionDetail(String submissionId) {
    context.go('${RouteNames.adminSubmissionDetail}/$submissionId');
  }

  Future<void> _approveSubmission(String submissionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: const Text('Apakah Anda yakin ingin menyetujui pengajuan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _submissionService.approveSubmission(
          submissionId: submissionId,
          notes: 'Disetujui oleh admin',
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengajuan berhasil disetujui')),
          );
          await _filterSubmissions(); // Reload submissions
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyetujui pengajuan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _rejectSubmission(String submissionId) async {
    String? rejectionNotes;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penolakan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin menolak pengajuan ini?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => rejectionNotes = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _submissionService.rejectSubmission(
          submissionId: submissionId,
          notes: rejectionNotes?.isNotEmpty == true ? rejectionNotes! : 'Ditolak oleh admin',
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengajuan berhasil ditolak')),
          );
          await _filterSubmissions(); // Reload submissions
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menolak pengajuan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengajuan Bantuan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSubmissions,
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filters (Program, Status)
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
                          items: _programNames.map((String programName) {
                            return DropdownMenuItem<String>(
                              value: programName,
                              child: Text(
                                programName,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                          items: _statuses.map((String status) {
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
                      backgroundColor: Colors.white.withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 20.0),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _startDateFilter == null || _endDateFilter == null
                                ? 'Pilih Rentang Tanggal'
                                : '${DateFormat('dd MMM yyyy').format(_startDateFilter!)} - ${DateFormat('dd MMM yyyy').format(_endDateFilter!)}',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_startDateFilter != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20.0),
                            onPressed: _clearDateFilter,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Submission List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_errorMessage!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSubmissions,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _filteredSubmissions.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada pengajuan yang ditemukan',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadSubmissions,
                              child: ListView.builder(
                                itemCount: _filteredSubmissions.length,
                                itemBuilder: (context, index) {
                                  final submission = _filteredSubmissions[index];
                                  final submissionDate = submission['submissionDate'] as Timestamp?;
                                  
                                  return AdminSubmissionCardWidget(
                                    submission: {
                                      'id': submission['id'],
                                      'user_name': submission['userName'],
                                      'program_name': submission['programName'],
                                      'status': submission['status'],
                                      'submission_date': submissionDate?.toDate(),
                                    },
                                    onViewDetail: () => _viewSubmissionDetail(submission['id']),
                                    onApprove: () => _approveSubmission(submission['id']),
                                    onReject: () => _rejectSubmission(submission['id']),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}