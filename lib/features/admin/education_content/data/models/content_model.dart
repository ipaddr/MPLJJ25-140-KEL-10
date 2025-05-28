import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk menyimpan data konten edukasi
/// 
/// Digunakan untuk mengonversi data antara aplikasi dan Firestore
class ContentModel {
  // Required fields
  final String id;
  final String title;
  final String content;
  final String status;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional fields
  final String? description;
  final String? imageUrl;
  final DateTime? publishedAt;
  final int viewCount;
  final List<String> tags;
  final String type;
  final String category;

  // Default values for constants
  static const String defaultType = 'Artikel';
  static const String defaultCategory = 'Umum';
  static const String defaultStatus = 'draft';
  static const int defaultViewCount = 0;
  static const List<String> defaultTags = [];

  /// Konstruktor untuk membuat instance ContentModel
  ContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.imageUrl,
    this.publishedAt,
    this.viewCount = defaultViewCount,
    this.tags = defaultTags,
    this.type = defaultType,
    this.category = defaultCategory,
  });

  /// Membuat ContentModel dari Firestore document
  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ContentModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      description: data['description'],
      status: data['status'] ?? defaultStatus,
      imageUrl: data['imageUrl'],
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      publishedAt: _parseDateTime(data['publishedAt'], nullable: true),
      viewCount: data['viewCount'] ?? defaultViewCount,
      tags: List<String>.from(data['tags'] ?? defaultTags),
      type: data['type'] ?? defaultType,
      category: data['category'] ?? defaultCategory,
    );
  }

  /// Helper untuk mengonversi Timestamp ke DateTime
  static DateTime _parseDateTime(dynamic timestamp, {bool nullable = false}) {
    if (timestamp == null) {
      return nullable ? DateTime.now() : DateTime.now();
    }
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    
    return DateTime.now();
  }

  /// Mengonversi ContentModel ke format data Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'description': description,
      'status': status,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'viewCount': viewCount,
      'tags': tags,
      'type': type,
      'category': category,
    };
  }

  /// Membuat salinan objek dengan nilai baru (immutable pattern)
  ContentModel copyWith({
    String? id,
    String? title,
    String? content,
    String? description,
    String? status,
    String? imageUrl,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? viewCount,
    List<String>? tags,
    String? type,
    String? category,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }
  
  /// Mendapatkan durasi baca perkiraan berdasarkan panjang konten
  String getReadTime() {
    // Rata-rata kecepatan baca: 200 kata per menit
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    return minutes <= 1 ? '1 menit' : '$minutes menit';
  }
  
  /// Mendapatkan deskripsi singkat dari konten
  String getShortDescription() {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    
    // Ekstrak dari konten jika deskripsi kosong
    final cleanContent = content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('\n', ' ');
        
    if (cleanContent.length <= 150) {
      return cleanContent;
    }
    
    return '${cleanContent.substring(0, 147)}...';
  }
}