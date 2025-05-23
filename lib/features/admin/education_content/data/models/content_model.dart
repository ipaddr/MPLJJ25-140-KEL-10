import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String content;
  final String status;
  final String? imageUrl;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int viewCount;
  final List<String> tags;

  ContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.viewCount = 0,
    this.tags = const [],
  });

  // Convert from Firestore document
  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ContentModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      status: data['status'] ?? 'draft',
      imageUrl: data['imageUrl'],
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      viewCount: data['viewCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'status': status,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'viewCount': viewCount,
      'tags': tags,
    };
  }

  // Create a copy with updated fields
  ContentModel copyWith({
    String? title,
    String? content,
    String? status,
    String? imageUrl,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? viewCount,
    List<String>? tags,
  }) {
    return ContentModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
    );
  }
}
