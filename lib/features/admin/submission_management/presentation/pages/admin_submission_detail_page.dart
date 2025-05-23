import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_submission_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSubmissionDetailPage extends StatefulWidget {
  final String submissionId;

  const AdminSubmissionDetailPage({super.key, required this.submissionId});

  @override
  State<AdminSubmissionDetailPage> createState() => _AdminSubmissionDetailPageState();
}

class _AdminSubmissionDetailPageState extends State<AdminSubmissionDetailPage> {
  final AdminSubmissionService _submissionService = AdminSubmissionService();
  final TextEditingController _notesController = TextEditingController();
  
  Map<String, dynamic>? _submissionData;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubmissionData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final submissionData = await _submissionService.getSubmissionById(widget.submissionId);
      
      if (submissionData != null) {
        setState(() {
          _submissionData = submissionData;
          _notesController.text = submissionData['notes'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Pengajuan tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengajuan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSubmissionStatus(String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi ${newStatus == 'Disetujui' ? 'Persetujuan' : 'Penolakan'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Apakah Anda yakin ingin ${newStatus == 'Disetujui' ? 'menyetujui' : 'menolak'} pengajuan ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan Admin',
                border: OutlineInputBorder(),
                hintText: 'Masukkan catatan (opsional)',
              ),
              maxLines: 3,
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
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'Disetujui' ? Colors.green : Colors.red,
            ),
            child: Text(newStatus == 'Disetujui' ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isUpdating = true;
      });

      try {
        final success = await _submissionService.updateSubmissionStatus(
          submissionId: widget.submissionId,
          newStatus: newStatus,
          notes: _notesController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pengajuan berhasil ${newStatus == 'Disetujui' ? 'disetujui' : 'ditolak'}')),
          );
          
          // Reload data to show updated status
          await _loadSubmissionData();
          
          // Navigate back to submission list after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.go(RouteNames.adminSubmissionManagement);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal ${newStatus == 'Disetujui' ? 'menyetujui' : 'menolak'} pengajuan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _downloadDocument(Map<String, dynamic> document) async {
    try {
      final fileUrl = document['fileUrl'] as String?;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka dokumen')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL dokumen tidak valid')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error membuka dokumen: ${e.toString()}')),
      );
    }
  }

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

  String _formatCurrency(dynamic amount) {
    int value = 0;
    
    if (amount is int) {
      value = amount;
    } else if (amount is String) {
      value = int.tryParse(amount) ?? 0;
    } else if (amount is double) {
      value = amount.toInt();
    }
    
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  String _safeGetString(Map<String, dynamic>? data, String key, [String defaultValue = 'N/A']) {
    if (data == null) return defaultValue;
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  Widget _buildSupportingDocumentsSection() {
    final documents = _submissionData!['supportingDocuments'] as List<Map<String, dynamic>>;
    
    if (documents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dokumen Pendukung',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tidak ada dokumen pendukung yang dilampirkan.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dokumen Pendukung',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ...documents.map((doc) {
              final fileName = doc['fileName'] as String? ?? 'Dokumen';
              final fileSize = doc['fileSize'] as int? ?? 0;
              final fileType = doc['fileType'] as String? ?? 'unknown';
              final uploadDate = doc['uploadDate'] as Timestamp?;
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      _getFileIcon(fileType),
                      color: Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fileSize > 0) Text('Ukuran: ${_formatFileSize(fileSize)}'),
                      if (uploadDate != null)
                        Text('Upload: ${DateFormat('dd MMM yyyy, HH:mm').format(uploadDate.toDate())}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _downloadDocument(doc),
                        tooltip: 'Lihat',
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadDocument(doc),
                        tooltip: 'Download',
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.attach_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Pengajuan'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Pengajuan'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.adminSubmissionManagement),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = _getStatusColor(_submissionData!['status']);
    final submissionDate = _submissionData!['submissionDate'] as Timestamp?;
    final formattedDate = submissionDate != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(submissionDate.toDate())
        : 'N/A';

    final reviewDate = _submissionData!['reviewDate'] as Timestamp?;
    final formattedReviewDate = reviewDate != null
        ? DateFormat('dd MMMM yyyy, HH:mm').format(reviewDate.toDate())
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.adminSubmissionManagement),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Submission Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengajuan dari ${_safeGetString(_submissionData, 'userName')} untuk Program ${_safeGetString(_submissionData, 'programName')}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                _safeGetString(_submissionData, 'status'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text('Tanggal Pengajuan: $formattedDate'),
                        if (formattedReviewDate != null)
                          Text('Tanggal Review: $formattedReviewDate'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // User Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Pengguna',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        _buildDetailRow('Nama Lengkap', _safeGetString(_submissionData!['userDetails'], 'fullName')),
                        _buildDetailRow('Email', _safeGetString(_submissionData!['userDetails'], 'email')),
                        _buildDetailRow('No. Telepon', _safeGetString(_submissionData!['userDetails'], 'phoneNumber')),
                        _buildDetailRow('NIK', _safeGetString(_submissionData!['userDetails'], 'nik')),
                        _buildDetailRow('Lokasi', _safeGetString(_submissionData!['userDetails'], 'location')),
                        _buildDetailRow('Jenis Pekerjaan', _safeGetString(_submissionData!['userDetails'], 'jobType')),
                        _buildDetailRow(
                          'Penghasilan Bulanan', 
                          _formatCurrency(_submissionData!['userDetails']['monthlyIncome'] ?? 0)
                        ),
                        _buildDetailRow('Status Akun', _safeGetString(_submissionData!['userDetails'], 'accountStatus')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Program Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Program',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        _buildDetailRow('Nama Program', _safeGetString(_submissionData!['programDetails'], 'programName')),
                        _buildDetailRow('Penyelenggara', _safeGetString(_submissionData!['programDetails'], 'organizer')),
                        _buildDetailRow('Kategori', _safeGetString(_submissionData!['programDetails'], 'category')),
                        const SizedBox(height: 8.0),
                        const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(_safeGetString(_submissionData!['programDetails'], 'description')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Supporting Documents Card
                _buildSupportingDocumentsSection(),
                const SizedBox(height: 16.0),

                // Admin Notes Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Admin',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(_safeGetString(_submissionData, 'notes').isEmpty 
                            ? 'Tidak ada catatan.' 
                            : _safeGetString(_submissionData, 'notes')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Action Buttons
                if (_submissionData!['status'] == 'Baru' || _submissionData!['status'] == 'Diproses')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateSubmissionStatus('Disetujui'),
                          icon: _isUpdating 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: const Text('Setujui', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : () => _updateSubmissionStatus('Ditolak'),
                          icon: _isUpdating 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.cancel_outlined, color: Colors.white),
                          label: const Text('Tolak', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}