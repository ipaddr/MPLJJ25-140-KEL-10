import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/features/user/education/presentation/pages/education_detail_page.dart';

class EducationDetailViewWidget extends StatelessWidget {
  final String articleId;
  final Map<String, dynamic> articleData;

  const EducationDetailViewWidget({
    super.key,
    required this.articleId,
    required this.articleData,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = articleData['createdAt']?.toDate();
    final updatedAt = articleData['updatedAt']?.toDate();
    final publishedAt = articleData['publishedAt']?.toDate();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          if (articleData['imageUrl'] != null &&
              articleData['imageUrl'].isNotEmpty)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(articleData['imageUrl']),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    print('Error loading image: $error');
                  },
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type and Category Badges
                Row(
                  children: [
                    if (articleData['type'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          articleData['type'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        articleData['category'] ?? 'Umum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  articleData['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Article Meta Information
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Penulis: ${articleData['authorName'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dipublikasikan: ${publishedAt != null ? _formatDate(publishedAt) : (createdAt != null ? _formatDate(createdAt) : 'Unknown')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (updatedAt != null && updatedAt != createdAt) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Diperbarui: ${_formatDate(updatedAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${articleData['viewCount'] ?? 0} kali dibaca',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description (if available)
                if (articleData['description'] != null &&
                    articleData['description'].isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.summarize,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Deskripsi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          articleData['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Main Content
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konten',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        articleData['content'] ?? 'No content available',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tags (if available)
                if (articleData['tags'] != null &&
                    articleData['tags'].isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        (articleData['tags'] as List).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Related Articles Section
                _buildRelatedArticles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konten Terkait',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('education_content') // Use correct collection
                  .where('category', isEqualTo: articleData['category'])
                  .where(
                    'status',
                    isEqualTo: 'published',
                  ) // Only published content
                  .limit(3)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada konten terkait',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            final relatedArticles =
                snapshot.data!.docs
                    .where((doc) => doc.id != articleId)
                    .take(2)
                    .toList();

            if (relatedArticles.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada konten terkait',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            return Column(
              children:
                  relatedArticles.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              data['imageUrl'] != null
                                  ? Image.network(
                                    data['imageUrl'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.article,
                                          color: Colors.grey.shade400,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.article,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                        ),
                        title: Text(
                          data['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          data['description'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EducationDetailPage(articleId: doc.id),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}
