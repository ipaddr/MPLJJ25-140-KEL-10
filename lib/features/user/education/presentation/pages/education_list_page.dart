import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';
import 'package:socio_care/core/navigation/route_names.dart';

/// Halaman yang menampilkan daftar konten edukasi dan informasi
/// Pengguna dapat mencari dan memfilter konten berdasarkan kategori
class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  // Controllers dan state variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  // UI constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _cardRadius = 12.0;
  static const double _cardElevation = 3.0;
  static const double _imageHeight = 180.0;

  // Collection constants
  static const String _collectionPath = 'education_content';
  static const String _publishedStatus = 'published';

  // Available categories
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

  /// Mengambil konten edukasi yang telah dipublikasikan
  Future<List<QueryDocumentSnapshot>> _getPublishedContent() async {
    try {
      // Buat query dasar dengan filter status publikasi
      Query query = _createBaseQuery();

      final snapshot = await query.limit(50).get();
      return snapshot.docs;
    } catch (e) {
      debugPrint('Error getting published content: $e');

      // Query alternatif jika terjadi masalah dengan indeks
      return await _getFallbackPublishedContent(e);
    }
  }

  /// Membuat query dasar untuk konten edukasi
  Query _createBaseQuery() {
    Query query = FirebaseFirestore.instance
        .collection(_collectionPath)
        .where('status', isEqualTo: _publishedStatus)
        .orderBy('publishedAt', descending: true);

    // Filter berdasarkan kategori jika dipilih
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return query;
  }

  /// Query alternatif jika terjadi kesalahan dengan query utama
  Future<List<QueryDocumentSnapshot>> _getFallbackPublishedContent(
    dynamic originalError,
  ) async {
    try {
      // Query tanpa orderBy untuk menghindari masalah indeks
      Query fallbackQuery = FirebaseFirestore.instance
          .collection(_collectionPath)
          .where('status', isEqualTo: _publishedStatus);

      if (_selectedCategory != 'All') {
        fallbackQuery = fallbackQuery.where(
          'category',
          isEqualTo: _selectedCategory,
        );
      }

      final snapshot = await fallbackQuery.limit(50).get();

      // Urutkan secara manual berdasarkan waktu
      final docs = snapshot.docs.toList();
      _sortDocumentsByTimestamp(docs);

      return docs;
    } catch (e2) {
      debugPrint('Fallback query also failed: $e2');
      throw e2;
    }
  }

  /// Mengurutkan dokumen berdasarkan timestamp
  void _sortDocumentsByTimestamp(List<QueryDocumentSnapshot> docs) {
    docs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aTime =
          aData['publishedAt'] as Timestamp? ??
          aData['updatedAt'] as Timestamp?;
      final bTime =
          bData['publishedAt'] as Timestamp? ??
          bData['updatedAt'] as Timestamp?;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });
  }

  /// Memfilter artikel berdasarkan pencarian
  List<DocumentSnapshot> _filterArticles(List<DocumentSnapshot> articles) {
    if (_searchQuery.isEmpty) {
      return articles;
    }

    return articles.where((article) {
      try {
        final data = article.data() as Map<String, dynamic>?;
        if (data == null) return false;

        final searchLower = _searchQuery.toLowerCase();

        // Cari dalam judul, konten, deskripsi, dan kategori
        return _isTextContainsQuery(data['title'], searchLower) ||
            _isTextContainsQuery(data['content'], searchLower) ||
            _isTextContainsQuery(data['description'], searchLower) ||
            _isTextContainsQuery(data['category'], searchLower);
      } catch (e) {
        debugPrint('Error filtering article ${article.id}: $e');
        return false;
      }
    }).toList();
  }

  /// Memeriksa apakah teks mengandung query pencarian
  bool _isTextContainsQuery(dynamic text, String query) {
    return text != null && text.toString().toLowerCase().contains(query);
  }

  /// Format tanggal relatif
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

  /// Menangani ketika artikel diklik
  Future<void> _handleArticleClick(
    BuildContext context,
    String articleId,
    String title,
    Map<String, dynamic> fullData,
  ) async {
    try {
      // Increment view count
      await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(articleId)
          .update({'viewCount': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error updating view count: $e');
    }

    // Navigate to detail page
    if (!mounted) return;

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
      debugPrint('Navigation error: $e');
      _showErrorSnackbar('Gagal membuka detail artikel');
    }
  }

  /// Menampilkan pesan error dalam snackbar
  void _showErrorSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const UserBottomNavigationBar(
        selectedIndex: 2, // Education is the third item
      ),
    );
  }

  /// Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  /// Membangun body utama
  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [_buildSearchAndFilterSection(), _buildArticlesList()],
      ),
    );
  }

  /// Membangun bagian pencarian dan filter
  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
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
          _buildSearchField(),
          const SizedBox(height: _smallSpacing),
          _buildCategoryFilters(),
        ],
      ),
    );
  }

  /// Membangun field pencarian
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari artikel edukasi...',
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
        suffixIcon:
            _searchQuery.isNotEmpty
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
          borderRadius: BorderRadius.circular(_cardRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _spacing,
          vertical: _smallSpacing,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  /// Membangun filter kategori
  Widget _buildCategoryFilters() {
    return SizedBox(
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
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Membangun daftar artikel
  Widget _buildArticlesList() {
    return Expanded(
      child: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _getPublishedContent(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingView();
          }

          final allArticles = snapshot.data ?? [];
          final filteredArticles = _filterArticles(allArticles);

          if (filteredArticles.isEmpty) {
            return _buildEmptyView(allArticles);
          }

          return _buildArticlesListView(filteredArticles);
        },
      ),
    );
  }

  /// Membangun tampilan untuk loading state
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: _spacing),
          Text('Memuat konten edukasi...'),
        ],
      ),
    );
  }

  /// Membangun tampilan untuk error state
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: _spacing),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _spacing),
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

  /// Membangun tampilan ketika tidak ada artikel
  Widget _buildEmptyView(List<DocumentSnapshot> allArticles) {
    final messageText = _getEmptyStateMessage(allArticles);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: _spacing),
            Text(
              messageText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: _spacing),
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

  /// Mendapatkan pesan untuk tampilan kosong
  String _getEmptyStateMessage(List<DocumentSnapshot> allArticles) {
    if (_searchQuery.isNotEmpty) {
      return 'Tidak ada konten yang ditemukan\nuntuk "$_searchQuery"';
    }

    if (allArticles.isEmpty) {
      return 'Belum ada konten edukasi yang dipublikasikan';
    }

    return 'Tidak ada konten di kategori "$_selectedCategory"';
  }

  /// Membangun tampilan daftar artikel
  Widget _buildArticlesListView(List<DocumentSnapshot> articles) {
    return ListView.builder(
      padding: const EdgeInsets.all(_spacing),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final doc = articles[index];
        final data = doc.data() as Map<String, dynamic>? ?? {};

        return _buildArticleCard(
          context,
          doc.id,
          data['title']?.toString() ?? 'No Title',
          _getArticleSummary(data),
          data['category']?.toString() ?? 'Umum',
          data['imageUrl']?.toString(),
          (data['publishedAt'] ?? data['updatedAt'])?.toDate(),
          (data['viewCount'] as num?)?.toInt() ?? 0,
          data,
        );
      },
    );
  }

  /// Mendapatkan ringkasan artikel
  String _getArticleSummary(Map<String, dynamic> data) {
    // Jika ada deskripsi, gunakan deskripsi
    if (data['description'] != null &&
        data['description'].toString().isNotEmpty) {
      return data['description'].toString();
    }

    // Jika tidak ada deskripsi tapi ada konten, ambil sebagian konten
    if (data['content'] != null) {
      final content = data['content'].toString();
      if (content.length > 150) {
        return content.substring(0, 150) + '...';
      }
      return content;
    }

    return 'No Content';
  }

  /// Membangun kartu artikel
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
      margin: const EdgeInsets.only(bottom: _spacing),
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: InkWell(
        onTap: () => _handleArticleClick(context, articleId, title, fullData),
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              _buildArticleImage(imageUrl),
            _buildArticleContent(
              title,
              summary,
              category,
              publishedAt,
              viewCount,
              fullData,
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun bagian gambar artikel
  Widget _buildArticleImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_cardRadius),
        topRight: Radius.circular(_cardRadius),
      ),
      child: Image.network(
        imageUrl,
        height: _imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: _imageHeight,
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
            height: _imageHeight,
            color: Colors.grey.shade100,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  /// Membangun bagian konten artikel
  Widget _buildArticleContent(
    String title,
    String summary,
    String category,
    DateTime? publishedAt,
    int viewCount,
    Map<String, dynamic> fullData,
  ) {
    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildArticleBadges(fullData, category),
          const SizedBox(height: 8),
          _buildArticleTitle(title),
          const SizedBox(height: 8),
          _buildArticleSummary(summary),
          const SizedBox(height: _smallSpacing),
          _buildArticleFooter(fullData, publishedAt, viewCount),
        ],
      ),
    );
  }

  /// Membangun badge artikel
  Widget _buildArticleBadges(Map<String, dynamic> data, String category) {
    return Row(
      children: [
        _buildBadge(
          data['type']?.toString() ?? 'Artikel',
          Colors.blue.shade100,
          Colors.blue.shade700,
        ),
        const SizedBox(width: 8),
        _buildBadge(category, Colors.green.shade100, Colors.green.shade700),
      ],
    );
  }

  /// Membangun badge dengan teks dan warna
  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// Membangun judul artikel
  Widget _buildArticleTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Poppins',
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Membangun ringkasan artikel
  Widget _buildArticleSummary(String summary) {
    return Text(
      summary,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Membangun footer artikel
  Widget _buildArticleFooter(
    Map<String, dynamic> data,
    DateTime? publishedAt,
    int viewCount,
  ) {
    return Row(
      children: [
        // Author
        Icon(Icons.person, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          data['authorName']?.toString() ?? 'Unknown',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 12),

        // Date
        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          publishedAt != null ? _formatDate(publishedAt) : 'Unknown',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const Spacer(),

        // Views
        Icon(Icons.visibility, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          '$viewCount',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(width: 8),

        // Forward icon
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue.shade400),
      ],
    );
  }
}
