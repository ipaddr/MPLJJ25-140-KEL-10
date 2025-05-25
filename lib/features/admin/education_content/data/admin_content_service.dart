import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/content_model.dart';

class AdminContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'education_content';

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

  // Get display name for status
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

  // Get status value from display name
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

  // Get all content with optional filtering
  Future<List<ContentModel>> getAllContent({
    String? status,
    String? type,
    String? category,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName).orderBy('updatedAt', descending: true);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting content: $e');
      return [];
    }
  }

  // Get content by ID
  Future<ContentModel?> getContentById(String contentId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(contentId).get();
      
      if (doc.exists) {
        return ContentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting content by ID: $e');
      return null;
    }
  }

  // Create new content
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
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

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
        authorName: user.displayName ?? user.email ?? 'Unknown',
        createdAt: now,
        updatedAt: now,
        publishedAt: status == 'published' ? now : null,
        tags: tags,
      );

      final docRef = await _firestore.collection(_collectionName).add(contentModel.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating content: $e');
      return null;
    }
  }

  // Update existing content
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
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl = existingImageUrl;

      // Upload new image if provided
      if (imageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null) {
          await _deleteImage(existingImageUrl);
        }
        imageUrl = await _uploadImage(imageFile);
      }

      final updateData = {
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

      // Set publishedAt if status is published and it wasn't published before
      if (status == 'published') {
        final existingContent = await getContentById(contentId);
        if (existingContent != null && existingContent.status != 'published') {
          updateData['publishedAt'] = FieldValue.serverTimestamp();
        }
      }

      await _firestore.collection(_collectionName).doc(contentId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating content: $e');
      return false;
    }
  }

  // Delete content
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
      print('Error deleting content: $e');
      return false;
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName = 'content_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('education_content').child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Get published content for users
  Future<List<ContentModel>> getPublishedContent({
    String? type,
    String? category,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true);

      if (type != null && type.isNotEmpty) {
        query = query.where('type', isEqualTo: type);
      }
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting published content: $e');
      return [];
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String contentId) async {
    try {
      await _firestore.collection(_collectionName).doc(contentId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Search content
  Future<List<ContentModel>> searchContent(String searchTerm, {bool publishedOnly = true}) async {
    try {
      Query query = _firestore.collection(_collectionName);
      
      if (publishedOnly) {
        query = query.where('status', isEqualTo: 'published');
      }

      final querySnapshot = await query.get();
      
      final lowercaseSearch = searchTerm.toLowerCase();
      final filteredDocs = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().toLowerCase();
        final content = (data['content'] ?? '').toString().toLowerCase();
        final description = (data['description'] ?? '').toString().toLowerCase();
        
        return title.contains(lowercaseSearch) || 
               content.contains(lowercaseSearch) ||
               description.contains(lowercaseSearch);
      }).toList();

      return filteredDocs.map((doc) => ContentModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching content: $e');
      return [];
    }
  }
}