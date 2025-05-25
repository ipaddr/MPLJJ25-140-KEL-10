import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String content;
  final String? description; // Added description field
  final String status;
  final String? imageUrl;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int viewCount;
  final List<String> tags;
  final String type; // Added type field (Artikel, Video, Infografis, etc.)
  final String category; // Added category field (Umum, Kesehatan, Pendidikan, etc.)

  ContentModel({
    required this.id,
    required this.title,
    required this.content,
    this.description,
    required this.status,
    this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.viewCount = 0,
    this.tags = const [],
    this.type = 'Artikel',
    this.category = 'Umum',
  });

  // Convert from Firestore document
  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ContentModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'draft',
      imageUrl: data['imageUrl'],
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      viewCount: data['viewCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      type: data['type'] ?? 'Artikel',
      category: data['category'] ?? 'Umum',
    );
  }

  // Convert to Firestore document
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

  // Copy with method for updates
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
}