import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'All',
    'Umum',
    'Kesehatan', 
    'Pendidikan',
    'Ekonomi',
    'Hukum',
    'Teknologi',
    'Lingkungan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Updated method to get published content from admin collection
  Future<List<QueryDocumentSnapshot>> _getPublishedContent() async {
    try {
      // Use the same collection as admin: 'education_content'
      Query query = FirebaseFirestore.instance
          .collection('education_content') // Changed from 'education_articles'
          .where('status', isEqualTo: 'published') // Only get published content
          .orderBy('publishedAt', descending: true); // Order by published date

      // Filter by category if selected
      if (_selectedCategory != 'All') {
        query = query.where('category', isEqualTo: _selectedCategory);
      }

      final snapshot = await query.limit(50).get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting published content: $e');
      
      // Fallback query without orderBy if there's an index issue
      try {
        Query fallbackQuery = FirebaseFirestore.instance
            .collection('education_content')
            .where('status', isEqualTo: 'published');

        if (_selectedCategory != 'All') {
          fallbackQuery = fallbackQuery.where('category', isEqualTo: _selectedCategory);
        }

        final snapshot = await fallbackQuery.limit(50).get();
        
        // Sort manually by publishedAt or updatedAt
        final docs = snapshot.docs.toList();
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          
          final aTime = aData['publishedAt'] as Timestamp? ?? aData['updatedAt'] as Timestamp?;
          final bTime = bData['publishedAt'] as Timestamp? ?? bData['updatedAt'] as Timestamp?;
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          return bTime.compareTo(aTime);
        });
        
        return docs;
      } catch (e2) {
        print('Fallback query also failed: $e2');
        throw e2;
      }
    }
  }

  List<DocumentSnapshot> _filterArticles(List<DocumentSnapshot> articles) {
    if (_searchQuery.isEmpty) {
      return articles;
    }

    return articles.where((article) {
      try {
        final data = article.data() as Map<String, dynamic>?;
        if (data == null) return false;

        final title = data['title']?.toString().toLowerCase() ?? '';
        final content = data['content']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';
        final category = data['category']?.toString().toLowerCase() ?? '';

        final searchLower = _searchQuery.toLowerCase();

        return title.contains(searchLower) ||
            content.contains(searchLower) ||
            description.contains(searchLower) ||
            category.contains(searchLower);
      } catch (e) {
        print('Error filtering article ${article.id}: $e');
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edukasi & Informasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari artikel edukasi...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _errorMessage = null;
                              });
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade700,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Articles List
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _getPublishedContent(),
                builder: (context, snapshot) {
                  // Error handling
                  if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    print('FutureBuilder error: $error');

                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Terjadi kesalahan saat memuat konten',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Detail error: ${error.length > 100 ? error.substring(0, 100) + "..." : error}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memuat konten edukasi...'),
                        ],
                      ),
                    );
                  }

                  // Get and filter articles
                  final allArticles = snapshot.data ?? [];
                  final filteredArticles = _filterArticles(allArticles);

                  // Empty state
                  if (filteredArticles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada konten yang ditemukan\nuntuk "${_searchQuery}"'
                                  : allArticles.isEmpty
                                      ? 'Belum ada konten edukasi yang dipublikasikan'
                                      : 'Tidak ada konten di kategori "${_selectedCategory}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Konten akan muncul setelah admin mempublikasikannya',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Success state - show articles
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final doc = filteredArticles[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      return _buildArticleCard(
                        context,
                        doc.id,
                        data['title']?.toString() ?? 'No Title',
                        data['description']?.toString() ??
                            (data['content'] != null &&
                                    data['content'].toString().length > 150
                                ? data['content'].toString().substring(0, 150) + '...'
                                : data['content']?.toString() ?? 'No Content'),
                        data['category']?.toString() ?? 'Umum',
                        data['imageUrl']?.toString(),
                        (data['publishedAt'] ?? data['updatedAt'])?.toDate(),
                        (data['viewCount'] as num?)?.toInt() ?? 0,
                        data,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(
        selectedIndex: 2, // Education is the third item
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    String articleId,
    String title,
    String summary,
    String category,
    String? imageUrl,
    DateTime? publishedAt,
    int viewCount,
    Map<String, dynamic> fullData,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () async {
          try {
            // Increment view count in the correct collection
            await FirebaseFirestore.instance
                .collection('education_content') // Changed collection name
                .doc(articleId)
                .update({'viewCount': FieldValue.increment(1)});
          } catch (e) {
            print('Error updating view count: $e');
          }

          // Navigate to detail page
          try {
            context.push(
              '/user/education/detail/$articleId',
              extra: {
                'title': title,
                'content': fullData['content'] ?? '',
                'data': fullData,
              },
            );
          } catch (e) {
            print('Navigation error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal membuka detail artikel'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  imageUrl,
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
                  // Type and Category Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          fullData['type']?.toString() ?? 'Artikel',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
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
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    title,
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

                  // Summary
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fullData['authorName']?.toString() ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        publishedAt != null ? _formatDate(publishedAt) : 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$viewCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.blue.shade400,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}