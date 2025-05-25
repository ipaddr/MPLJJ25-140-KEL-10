import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/features/user/education/widgets/education_detail_widget.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isBookmarked = false;
  bool _isLoading = true;
  Map<String, dynamic>? _articleData;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      // Use the correct collection name
      final doc = await FirebaseFirestore.instance
          .collection('education_content') // Changed from 'education_articles'
          .doc(widget.articleId)
          .get();

      if (doc.exists) {
        setState(() {
          _articleData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading article: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    // TODO: Implement bookmark functionality with user authentication
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Konten disimpan' : 'Konten dihapus dari simpanan',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareArticle() async {
    if (_articleData != null) {
      await Share.share(
        'Baca konten menarik: ${_articleData!['title']}\n\n${_articleData!['description'] ?? _articleData!['content']?.toString().substring(0, 100) ?? ''}',
        subject: _articleData!['title'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

    if (_articleData == null) {
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

    return Scaffold(
      appBar: AppBar(
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
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareArticle,
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
        child: EducationDetailViewWidget(
          articleId: widget.articleId,
          articleData: _articleData!,
        ),
      ),
    );
  }
}