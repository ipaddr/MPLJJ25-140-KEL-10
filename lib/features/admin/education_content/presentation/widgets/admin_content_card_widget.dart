import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminContentCardWidget extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminContentCardWidget({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dipublikasikan':
        return Colors.green;
      case 'Draf':
        return Colors.orange;
      case 'Diarsip':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = content[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  int _safeGetInt(String key, [int defaultValue = 0]) {
    final value = content[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    try {
      if (date is DateTime) {
        return DateFormat('dd MMM yyyy').format(date);
      } else if (date is String) {
        final parsedDate = DateTime.tryParse(date);
        if (parsedDate != null) {
          return DateFormat('dd MMM yyyy').format(parsedDate);
        }
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_safeGetString('status'));
    final publishDate = content['publish_date'];
    final formattedDate = _formatDate(publishDate);
    final viewCount = _safeGetInt('view_count');
    final imageUrl = content['image_url'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image (if available)
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              
              // Title
              Text(
                _safeGetString('title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),

              // Author info (if available)
              if (_safeGetString('author') != 'N/A') ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Penulis: ${_safeGetString('author')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
              ],

              // Status and Date Row
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
                      _safeGetString('status'),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // View count and stats
              Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '$viewCount kali dilihat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20.0),
                      color: Colors.blue,
                      onPressed: onEdit,
                      tooltip: 'Edit Konten',
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 20.0),
                      color: Colors.red,
                      onPressed: onDelete,
                      tooltip: 'Hapus Konten',
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}