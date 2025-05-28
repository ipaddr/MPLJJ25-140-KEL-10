import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/content_model.dart';

/// Service untuk mengelola konten edukasi dalam aplikasi
///
/// Menyediakan fungsi-fungsi untuk membuat, membaca, mengupdate, dan menghapus konten
class AdminContentService {
  // Firebase services
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  // Collection name
  static const String _collectionName = 'education_content';
  static const String _storagePath = 'education_content';

  // Valid status values
  static const List<String> validStatuses = [
    'draft',
    'published',
    'archived',
  ];

  // Valid content types
  static const List<String> validTypes = [
    'Artikel',
    'Video',
    'Infografis',
    'Panduan',
    'Tips',
  ];

  // Valid categories
  static const List<String> validCategories = [
    'Umum',
    'Kesehatan',
    'Pendidikan',
    'Ekonomi',
    'Hukum',
    'Teknologi',
    'Lingkungan',
  ];

  /// Konstruktor dengan dependency injection untuk pengujian yang lebih mudah
  AdminContentService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storage = storage ?? FirebaseStorage.instance,
    _auth = auth ?? FirebaseAuth.instance;

  /// Mendapatkan nama tampilan untuk status
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'draft':
        return 'Draf';
      case 'published':
        return 'Dipublikasikan';
      case 'archived':
        return 'Diarsip';
      default:
        return status;
    }
  }

  /// Mendapatkan nilai status dari nama tampilan
  static String getStatusValue(String displayName) {
    switch (displayName) {
      case 'Draf':
        return 'draft';
      case 'Dipublikasikan':
        return 'published';
      case 'Diarsip':
        return 'archived';
      default:
        return displayName.toLowerCase();
    }
  }

  /// Mendapatkan semua konten dengan filter opsional
  Future<List<ContentModel>> getAllContent({
    String? status,
    String? type,
    String? category,
  }) async {
    try {
      Query query = _buildFilteredQuery(
        status: status,
        type: type,
        category: category,
      );

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting content: $e');
      return [];
    }
  }
  
  /// Membuat query dengan filter yang diterapkan
  Query _buildFilteredQuery({
    String? status,
    String? type,
    String? category,
    bool orderByUpdated = true,
    bool descending = true,
  }) {
    Query query = _firestore.collection(_collectionName);
    
    // Apply ordering first (important for query optimization)
    if (orderByUpdated) {
      query = query.orderBy('updatedAt', descending: descending);
    }

    // Apply filters
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query;
  }

  /// Mendapatkan konten berdasarkan ID
  Future<ContentModel?> getContentById(String contentId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(contentId).get();
      
      if (doc.exists) {
        return ContentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting content by ID: $e');
      return null;
    }
  }

  /// Membuat konten baru
  Future<String?> createContent({
    required String title,
    required String content,
    String? description,
    required String status,
    String type = 'Artikel',
    String category = 'Umum',
    File? imageFile,
    List<String> tags = const [],
  }) async {
    try {
      final user = _getCurrentUser();

      // Upload image if provided
      final imageUrl = imageFile != null 
          ? await _uploadImage(imageFile)
          : null;

      final now = DateTime.now();
      final contentModel = ContentModel(
        id: '', // Will be set by Firestore
        title: title,
        content: content,
        description: description,
        status: status,
        type: type,
        category: category,
        imageUrl: imageUrl,
        authorId: user.uid,
        authorName: _getAuthorName(user),
        createdAt: now,
        updatedAt: now,
        publishedAt: status == 'published' ? now : null,
        tags: tags,
      );

      final docRef = await _firestore
          .collection(_collectionName)
          .add(contentModel.toFirestore());
          
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating content: $e');
      return null;
    }
  }

  /// Update konten yang ada
  Future<bool> updateContent({
    required String contentId,
    required String title,
    required String content,
    String? description,
    required String status,
    String? type,
    String? category,
    File? imageFile,
    String? existingImageUrl,
    List<String>? tags,
  }) async {
    try {
      final user = _getCurrentUser();

      // Handle image updates
      final imageUrl = await _handleImageUpdate(
        imageFile: imageFile,
        existingImageUrl: existingImageUrl,
      );

      // Prepare update data
      final updateData = _prepareUpdateData(
        title: title,
        content: content,
        description: description,
        status: status,
        type: type,
        category: category,
        imageUrl: imageUrl,
        tags: tags,
      );

      // Update publishedAt if needed
      if (status == 'published') {
        await _updatePublishedAtIfNeeded(contentId, status, updateData);
      }

      // Update document
      await _firestore
          .collection(_collectionName)
          .doc(contentId)
          .update(updateData);
          
      return true;
    } catch (e) {
      debugPrint('Error updating content: $e');
      return false;
    }
  }

  /// Prepare update data map
  Map<String, dynamic> _prepareUpdateData({
    required String title,
    required String content,
    String? description,
    required String status,
    String? type,
    String? category,
    String? imageUrl,
    List<String>? tags,
  }) {
    return {
      'title': title,
      'content': content,
      'description': description,
      'status': status,
      'type': type ?? 'Artikel',
      'category': category ?? 'Umum',
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      'tags': tags ?? [],
    };
  }

  /// Update publishedAt timestamp if content becomes published
  Future<void> _updatePublishedAtIfNeeded(
    String contentId, 
    String newStatus,
    Map<String, dynamic> updateData
  ) async {
    final existingContent = await getContentById(contentId);
    
    if (existingContent != null && 
        existingContent.status != 'published' &&
        newStatus == 'published') {
      updateData['publishedAt'] = FieldValue.serverTimestamp();
    }
  }

  /// Handle image upload/deletion for updates
  Future<String?> _handleImageUpdate({
    File? imageFile,
    String? existingImageUrl,
  }) async {
    // If no new image and no existing image, return null
    if (imageFile == null && existingImageUrl == null) {
      return null;
    }
    
    // If no new image but has existing image, keep the existing one
    if (imageFile == null) {
      return existingImageUrl;
    }
    
    // Delete existing image if there is one
    if (existingImageUrl != null) {
      await _deleteImage(existingImageUrl);
    }
    
    // Upload new image
    return await _uploadImage(imageFile);
  }

  /// Menghapus konten
  Future<bool> deleteContent(String contentId) async {
    try {
      final content = await getContentById(contentId);
      
      // Delete associated image if exists
      if (content?.imageUrl != null) {
        await _deleteImage(content!.imageUrl!);
      }

      await _firestore.collection(_collectionName).doc(contentId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting content: $e');
      return false;
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final user = _getCurrentUser();

      final fileName = 'content_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(_storagePath).child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  /// Get published content for users
  Future<List<ContentModel>> getPublishedContent({
    String? type,
    String? category,
    int limit = 50,
  }) async {
    try {
      // Start with base query for published content
      Query query = _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true);

      // Apply optional filters
      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Apply limit
      query = query.limit(limit);

      // Execute query
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting published content: $e');
      return [];
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String contentId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(contentId)
          .update({
            'viewCount': FieldValue.increment(1),
          });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  /// Search content
  Future<List<ContentModel>> searchContent(
    String searchTerm, 
    {bool publishedOnly = true}
  ) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return [];
      }

      // Base query
      Query query = _firestore.collection(_collectionName);
      
      // Apply published filter if needed
      if (publishedOnly) {
        query = query.where('status', isEqualTo: 'published');
      }

      // Get all matching documents
      final querySnapshot = await query.get();
      
      // Perform client-side filtering (Firestore doesn't support full-text search)
      final lowercaseSearch = searchTerm.toLowerCase();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((data) => _contentMatchesSearch(data, lowercaseSearch))
          .map((data) => ContentModel.fromFirestore(
              querySnapshot.docs.firstWhere(
                (doc) => (doc.data() as Map<String, dynamic>)['title'] == data['title']
              )
            ))
          .toList();
    } catch (e) {
      debugPrint('Error searching content: $e');
      return [];
    }
  }
  
  /// Check if content matches search term
  bool _contentMatchesSearch(Map<String, dynamic> data, String searchTerm) {
    final title = (data['title'] ?? '').toString().toLowerCase();
    final content = (data['content'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();
    final tags = List<String>.from(data['tags'] ?? [])
        .map((tag) => tag.toLowerCase())
        .join(' ');
    
    return title.contains(searchTerm) || 
           content.contains(searchTerm) ||
           description.contains(searchTerm) ||
           tags.contains(searchTerm);
  }
  
  /// Get current authenticated user or throw exception
  User _getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user;
  }
  
  /// Get author name from user
  String _getAuthorName(User user) {
    return user.displayName ?? 
           user.email ?? 
           'Admin';
  }
}