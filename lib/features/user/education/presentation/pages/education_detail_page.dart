import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/features/user/education/widgets/education_detail_widget.dart';
import 'package:share_plus/share_plus.dart';

/// Halaman untuk menampilkan detail konten edukasi
class EducationDetailPage extends StatefulWidget {
  final String articleId;

  const EducationDetailPage({
    super.key,
    required this.articleId,
  });

  @override
  State<EducationDetailPage> createState() => _EducationDetailPageState();
}

class _EducationDetailPageState extends State<EducationDetailPage> {
  // State variables
  bool _isBookmarked = false;
  bool _isLoading = true;
  Map<String, dynamic>? _articleData;
  
  // Constants
  static const String _collectionPath = 'education_content';

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  /// Memuat data artikel dari Firestore
  Future<void> _loadArticle() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionPath)
          .doc(widget.articleId)
          .get();

      if (mounted) {
        setState(() {
          _articleData = doc.exists ? doc.data() : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading article: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Toggle status bookmark artikel
  Future<void> _toggleBookmark() async {
    // TODO: Implement bookmark functionality with user authentication
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    _showSnackBar(_isBookmarked ? 'Konten disimpan' : 'Konten dihapus dari simpanan');
  }

  /// Menampilkan snackbar dengan pesan tertentu
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Membagikan artikel ke aplikasi lain
  Future<void> _shareArticle() async {
    if (_articleData == null) return;
    
    try {
      final title = _articleData!['title'] ?? 'Artikel SocioCare';
      
      // Extract preview text safely
      String previewText = '';
      if (_articleData!.containsKey('description') && 
          _articleData!['description'] != null) {
        previewText = _articleData!['description'] as String;
      } else if (_articleData!.containsKey('content') && 
                _articleData!['content'] != null) {
        final content = _articleData!['content'] as String;
        previewText = content.length > 100 
            ? '${content.substring(0, 100)}...' 
            : content;
      }
      
      final shareText = 'Baca konten menarik: $title\n\n$previewText';
      
      await Share.share(shareText, subject: title);
    } catch (e) {
      debugPrint('Error sharing article: $e');
      _showSnackBar('Gagal membagikan artikel');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_articleData == null) {
      return _buildErrorState();
    }

    return _buildContentState();
  }

  /// Membangun tampilan loading
  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Membangun tampilan error saat artikel tidak ditemukan
  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konten Tidak Ditemukan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Konten tidak ditemukan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun tampilan konten artikel
  Widget _buildContentState() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: EducationDetailViewWidget(
          articleId: widget.articleId,
          articleData: _articleData!,
        ),
      ),
    );
  }

  /// Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _articleData!['title'] ?? 'Detail Konten',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
          onPressed: _toggleBookmark,
          tooltip: _isBookmarked ? 'Hapus dari simpanan' : 'Simpan artikel',
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareArticle,
          tooltip: 'Bagikan artikel',
        ),
      ],
    );
  }
}