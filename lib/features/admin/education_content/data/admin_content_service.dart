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

  // Get all content with optional filtering
  Future<List<ContentModel>> getAllContent({
    String? statusFilter,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName)
          .orderBy('updatedAt', descending: true);

      // Apply status filter if provided
      if (statusFilter != null && statusFilter != 'all' && validStatuses.contains(statusFilter)) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      final querySnapshot = await query.get();
      List<ContentModel> contents = querySnapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();

      // Apply search filter if provided (client-side filtering)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        contents = contents.where((content) {
          return content.title.toLowerCase().contains(lowercaseQuery) ||
                 content.content.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }

      return contents;
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
    required String status,
    File? imageFile,
    List<String> tags = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl;
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      }

      final now = DateTime.now();
      final contentData = ContentModel(
        id: '', // Will be set by Firestore
        title: title,
        content: content,
        status: status,
        imageUrl: imageUrl,
        authorId: user.uid,
        authorName: user.displayName ?? user.email ?? 'Admin',
        createdAt: now,
        updatedAt: now,
        publishedAt: status == 'published' ? now : null,
        tags: tags,
      );

      final docRef = await _firestore.collection(_collectionName).add(contentData.toFirestore());
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
    required String status,
    File? imageFile,
    String? existingImageUrl,
    List<String> tags = const [],
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

      final now = DateTime.now();
      
      // Get existing content to preserve some fields
      final existingContent = await getContentById(contentId);
      if (existingContent == null) return false;

      final updateData = {
        'title': title,
        'content': content,
        'status': status,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(now),
        'tags': tags,
      };

      // Set publishedAt if status changed to published and wasn't published before
      if (status == 'published' && existingContent.status != 'published') {
        updateData['publishedAt'] = Timestamp.fromDate(now);
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
      // Get content first to check for image
      final content = await getContentById(contentId);
      
      if (content != null && content.imageUrl != null) {
        // Delete associated image
        await _deleteImage(content.imageUrl!);
      }

      await _firestore.collection(_collectionName).doc(contentId).delete();
      return true;
    } catch (e) {
      print('Error deleting content: $e');
      return false;
    }
  }

  // Get content count by status
  Future<Map<String, int>> getContentCountByStatus() async {
    try {
      final results = await Future.wait([
        _firestore.collection(_collectionName).where('status', isEqualTo: 'published').count().get(),
        _firestore.collection(_collectionName).where('status', isEqualTo: 'draft').count().get(),
        _firestore.collection(_collectionName).where('status', isEqualTo: 'archived').count().get(),
      ]);

      return {
        'published': results[0].count ?? 0,
        'draft': results[1].count ?? 0,
        'archived': results[2].count ?? 0,
      };
    } catch (e) {
      print('Error getting content count: $e');
      return {'published': 0, 'draft': 0, 'archived': 0};
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

  // Get published content for public viewing
  Future<List<ContentModel>> getPublishedContent({
    int limit = 10,
    String? lastDocumentId,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName)
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(limit);

      if (lastDocumentId != null) {
        final lastDoc = await _firestore.collection(_collectionName).doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting published content: $e');
      return [];
    }
  }

  // Private method to upload image
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = 'content_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child(fileName);
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Private method to delete image
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Get status display name
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'published':
        return 'Dipublikasikan';
      case 'draft':
        return 'Draf';
      case 'archived':
        return 'Diarsip';
      default:
        return status;
    }
  }

  // Get status value from display name
  static String getStatusValue(String displayName) {
    switch (displayName) {
      case 'Dipublikasikan':
        return 'published';
      case 'Draf':
        return 'draft';
      case 'Diarsip':
        return 'archived';
      default:
        return displayName.toLowerCase();
    }
  }
}