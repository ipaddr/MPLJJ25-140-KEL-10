import 'package:flutter/material.dart';

class ProgramListItemWidget extends StatelessWidget {
  final String programId;
  final Map<String, dynamic> programData;
  final VoidCallback onTap;

  const ProgramListItemWidget({
    super.key,
    required this.programId,
    required this.programData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (programData['imageUrl'] != null &&
                programData['imageUrl'].isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  programData['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Status Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors
                                  .blue
                                  .shade100, // Changed from green to blue
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          programData['category'] ?? 'Bantuan Sosial',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors
                                    .blue
                                    .shade700, // Changed from green to blue
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              programData['status'] == 'active'
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          programData['status'] == 'active'
                              ? 'Aktif'
                              : 'Tidak Aktif',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color:
                                programData['status'] == 'active'
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Program Name - Use admin field
                  Text(
                    programData['programName'] ?? 'Nama Program',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    programData['description'] ?? 'Tidak ada deskripsi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Footer Info - Use admin fields
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          programData['organizer'] ?? 'Unknown', // Admin field
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${programData['totalApplications'] ?? 0}', // Admin field
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color:
                            Colors.blue.shade400, // Changed from green to blue
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
