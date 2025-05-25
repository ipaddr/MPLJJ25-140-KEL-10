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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Dipublikasikan':
        return Icons.public_rounded;
      case 'Draf':
        return Icons.edit_document;
      case 'Diarsip':
        return Icons.archive_rounded;
      default:
        return Icons.help_outline_rounded;
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
    final status = _safeGetString('status');
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final publishDate = content['publish_date'];
    final formattedDate = _formatDate(publishDate);
    final viewCount = _safeGetInt('view_count');
    final imageUrl = content['image_url'] as String?;
    final title = _safeGetString('title');
    final author = _safeGetString('author');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onEdit,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.blue.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Status
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.2),
                              statusColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      
                      // View Count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$viewCount',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image Section
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade100,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey.shade400,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gambar tidak dapat dimuat',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade200,
                                    Colors.grey.shade100,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue.shade700,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Author and Date Info
                  Row(
                    children: [
                      // Author
                      if (author != 'N/A') ...[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    author,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      // Date
                      if (formattedDate != 'N/A') ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Edit Button
                      Expanded(
                        child: Container(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(
                              Icons.edit_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Edit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.blue.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Delete Button
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_rounded,
                            size: 20,
                          ),
                          color: Colors.red.shade700,
                          tooltip: 'Hapus Konten',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}