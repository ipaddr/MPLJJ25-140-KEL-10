import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/features/user/education/presentation/pages/education_detail_page.dart';

/// Widget untuk menampilkan konten artikel edukasi secara detail
class EducationDetailViewWidget extends StatelessWidget {
  final String articleId;
  final Map<String, dynamic> articleData;

  // UI Constants
  static const double _cardPadding = 20.0;
  static const double _sectionSpacing = 24.0;
  static const double _itemSpacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _badgeRadius = 20.0;
  static const double _cardRadius = 12.0;
  static const int _relatedArticlesLimit = 3;

  const EducationDetailViewWidget({
    super.key,
    required this.articleId,
    required this.articleData,
  });

  /// Format tanggal ke format Indonesia
  String _formatDate(DateTime? date) {
    if (date == null) return 'Tidak tersedia';

    const months = [
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
          _buildHeroImage(),
          Padding(
            padding: const EdgeInsets.all(_cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeCategoryBadges(),
                const SizedBox(height: _itemSpacing),
                _buildTitle(),
                const SizedBox(height: _itemSpacing),
                _buildMetaInfo(createdAt, updatedAt, publishedAt),
                const SizedBox(height: _sectionSpacing),
                if (_hasDescription()) ...[
                  _buildDescriptionSection(),
                  const SizedBox(height: _sectionSpacing),
                ],
                _buildContentSection(),
                const SizedBox(height: _sectionSpacing),
                if (_hasTags()) ...[
                  _buildTagsSection(),
                  const SizedBox(height: _sectionSpacing),
                ],
                _buildRelatedArticles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tampilan gambar utama artikel
  Widget _buildHeroImage() {
    final hasImage =
        articleData['imageUrl'] != null &&
        articleData['imageUrl'].toString().isNotEmpty;

    if (!hasImage) return const SizedBox.shrink();

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(articleData['imageUrl']),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {
            debugPrint('Error loading image: $error');
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
    );
  }

  /// Membangun badge tipe dan kategori
  Widget _buildTypeCategoryBadges() {
    return Row(
      children: [
        if (articleData['type'] != null) ...[
          _buildBadge(
            text: articleData['type'],
            backgroundColor: Colors.blue.shade100,
            textColor: Colors.blue.shade700,
          ),
          const SizedBox(width: _tinySpacing),
        ],
        _buildBadge(
          text: articleData['category'] ?? 'Umum',
          backgroundColor: Colors.green.shade100,
          textColor: Colors.green.shade700,
        ),
      ],
    );
  }

  /// Membangun badge dengan warna kustom
  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_badgeRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// Membangun judul artikel
  Widget _buildTitle() {
    return Text(
      articleData['title'] ?? 'Tanpa Judul',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
    );
  }

  /// Membangun informasi meta artikel (penulis, tanggal publikasi, dll)
  Widget _buildMetaInfo(
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  ) {
    return Container(
      padding: const EdgeInsets.all(_itemSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildMetaRow(
            icon: Icons.person,
            text: 'Penulis: ${articleData['authorName'] ?? 'Tidak diketahui'}',
          ),
          const SizedBox(height: _tinySpacing),
          _buildMetaRow(
            icon: Icons.access_time,
            text:
                'Dipublikasikan: ${_getPublishedDateText(publishedAt, createdAt)}',
          ),
          if (updatedAt != null && updatedAt != createdAt) ...[
            const SizedBox(height: _tinySpacing),
            _buildMetaRow(
              icon: Icons.update,
              text: 'Diperbarui: ${_formatDate(updatedAt)}',
            ),
          ],
          const SizedBox(height: _tinySpacing),
          _buildMetaRow(
            icon: Icons.visibility,
            text: '${articleData['viewCount'] ?? 0} kali dibaca',
          ),
        ],
      ),
    );
  }

  /// Mendapatkan teks tanggal publikasi
  String _getPublishedDateText(DateTime? publishedAt, DateTime? createdAt) {
    if (publishedAt != null) return _formatDate(publishedAt);
    if (createdAt != null) return _formatDate(createdAt);
    return 'Tidak diketahui';
  }

  /// Membangun baris informasi meta dengan ikon
  Widget _buildMetaRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: _tinySpacing),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  /// Membangun bagian deskripsi artikel
  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(_itemSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: _tinySpacing),
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
          const SizedBox(height: _smallSpacing),
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
    );
  }

  /// Membangun bagian konten utama artikel
  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
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
          const SizedBox(height: _itemSpacing),
          Text(
            articleData['content'] ?? 'Tidak ada konten tersedia',
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
    );
  }

  /// Membangun bagian tag artikel
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _smallSpacing),
        Wrap(
          spacing: _tinySpacing,
          runSpacing: _tinySpacing,
          children: _buildTagsList(),
        ),
      ],
    );
  }

  /// Membangun daftar tag
  List<Widget> _buildTagsList() {
    final List<dynamic> tags = articleData['tags'] ?? [];
    return tags.map((tag) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(_itemSpacing),
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
    }).toList();
  }

  /// Membangun bagian artikel terkait
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
        const SizedBox(height: _itemSpacing),
        _buildRelatedArticlesStream(),
      ],
    );
  }

  /// Membangun stream untuk artikel terkait
  Widget _buildRelatedArticlesStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRelatedArticlesQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoRelatedContent();
        }

        final relatedArticles =
            snapshot.data!.docs
                .where((doc) => doc.id != articleId)
                .take(2)
                .toList();

        if (relatedArticles.isEmpty) {
          return _buildNoRelatedContent();
        }

        return Column(
          children:
              relatedArticles
                  .map((doc) => _buildRelatedArticleItem(doc))
                  .toList(),
        );
      },
    );
  }

  /// Mendapatkan query untuk artikel terkait
  Query _getRelatedArticlesQuery() {
    return FirebaseFirestore.instance
        .collection('education_content')
        .where('category', isEqualTo: articleData['category'])
        .where('status', isEqualTo: 'published')
        .limit(_relatedArticlesLimit);
  }

  /// Membangun tampilan ketika tidak ada konten terkait
  Widget _buildNoRelatedContent() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Center(
        child: Text(
          'Tidak ada konten terkait',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  /// Membangun item artikel terkait
  Widget _buildRelatedArticleItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: _smallSpacing),
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Builder(
        builder:
            (context) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _buildRelatedArticleImage(data),
              title: Text(
                data['title'] ?? 'Tanpa Judul',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                data['description'] ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _navigateToArticle(context, doc.id),
            ),
      ),
    );
  }

  /// Membangun gambar artikel terkait
  Widget _buildRelatedArticleImage(Map<String, dynamic> data) {
    const double imageSize = 60;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child:
          data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
              ? Image.network(
                data['imageUrl'],
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => _buildPlaceholderImage(),
              )
              : _buildPlaceholderImage(),
    );
  }

  /// Membangun gambar placeholder
  Widget _buildPlaceholderImage() {
    const double imageSize = 60;

    return Container(
      width: imageSize,
      height: imageSize,
      color: Colors.grey.shade200,
      child: Icon(Icons.article, color: Colors.grey.shade400),
    );
  }

  /// Navigasi ke halaman artikel lain
  void _navigateToArticle(BuildContext context, String articleId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EducationDetailPage(articleId: articleId),
      ),
    );
  }

  /// Cek apakah artikel memiliki deskripsi
  bool _hasDescription() {
    return articleData['description'] != null &&
        articleData['description'].toString().isNotEmpty;
  }

  /// Cek apakah artikel memiliki tag
  bool _hasTags() {
    final tags = articleData['tags'];
    return tags != null && tags is List && tags.isNotEmpty;
  }
}
