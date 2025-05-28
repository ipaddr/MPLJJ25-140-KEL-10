import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// Service for managing user data in admin module
///
/// Provides methods for retrieving, updating, and managing users
/// with support for both legacy and new field names
class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constants for valid field values
  static const List<String> validStatuses = ['active', 'inactive', 'suspended'];
  static const List<String> validRoles = ['user', 'admin'];

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');

  /// Safe conversion from dynamic to int
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Safe conversion from dynamic to String
  static String _safeParseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Safe conversion from dynamic to bool
  static bool _safeParseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Safe parsing for status with validation
  static String _safeParseStatus(dynamic value) {
    final status = _safeParseString(value);
    return validStatuses.contains(status) ? status : 'active';
  }

  /// Safe parsing for role with validation
  static String _safeParseRole(dynamic value) {
    final role = _safeParseString(value);
    return validRoles.contains(role) ? role : 'user';
  }

  /// Safe parsing for DateTime from various formats
  static DateTime? _safeParseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Maps document data to standardized user object
  Map<String, dynamic> _mapDocToUserObject(String id, Map<String, dynamic> data) {
    return {
      'id': id,
      'fullName': _safeParseString(data['fullName']),
      'email': _safeParseString(data['email']),
      'phoneNumber': _safeParseString(data['phoneNumber']),
      'address': _safeParseString(data['address'] ?? data['location']),
      'occupation': _safeParseString(data['occupation'] ?? data['jobType']),
      'monthlyIncome': _safeParseInt(data['monthlyIncome']),
      'gender': _safeParseString(data['gender']),
      'birthDate': _safeParseDateTime(data['birthDate']),
      'emergencyContactName': _safeParseString(data['emergencyContactName']),
      'emergencyContactPhone': _safeParseString(data['emergencyContactPhone']),
      'status': _safeParseStatus(data['status'] ?? data['accountStatus']),
      'role': _safeParseRole(data['role']),
      'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
      'createdAt': data['createdAt'] as Timestamp?,
      'updatedAt': data['updatedAt'] as Timestamp?,
      'lastLogin': data['lastLogin'] as Timestamp?,
      'emailVerified': _safeParseBool(data['emailVerified']),

      // Legacy fields for backward compatibility
      'location': _safeParseString(data['location']),
      'nik': _safeParseString(data['nik']),
      'jobType': _safeParseString(data['jobType']),
      'accountStatus': _safeParseStatus(data['accountStatus']),
      'ktpPictureUrl': _safeParseString(data['ktpPictureUrl']),
    };
  }

  /// Handle operation errors consistently
  void _logError(String operation, Object error) {
    developer.log('Error $operation: $error', name: 'AdminUserService');
  }

  /// Get all users with optional sorting
  Future<List<Map<String, dynamic>>> getAllUsers({
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      final querySnapshot = await _usersCollection
          .orderBy(sortBy, descending: descending)
          .get();

      return querySnapshot.docs
          .map((doc) => _mapDocToUserObject(doc.id, doc.data()))
          .toList();
    } catch (e) {
      _logError('getting users', e);
      return [];
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      
      if (doc.exists) {
        return _mapDocToUserObject(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      _logError('getting user', e);
      return null;
    }
  }

  /// Update user data with flexible fields
  Future<bool> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      // Validate status if provided
      if (userData.containsKey('status') &&
          !validStatuses.contains(userData['status'])) {
        _logError('updating user', 'Invalid status: ${userData['status']}');
        return false;
      }

      // Validate role if provided
      if (userData.containsKey('role') &&
          !validRoles.contains(userData['role'])) {
        _logError('updating user', 'Invalid role: ${userData['role']}');
        return false;
      }

      // Always set updatedAt timestamp
      userData['updatedAt'] = FieldValue.serverTimestamp();

      // Convert DateTime to Timestamp if needed
      if (userData.containsKey('birthDate') &&
          userData['birthDate'] is DateTime) {
        userData['birthDate'] = Timestamp.fromDate(userData['birthDate']);
      }

      await _usersCollection.doc(userId).update(userData);
      return true;
    } catch (e) {
      _logError('updating user data', e);
      return false;
    }
  }

  /// Update basic user information
  Future<bool> updateUser({
    required String userId,
    required String displayName,
    required String email,
    required String phoneNumber,
    required String address,
    required String role,
    required String status,
  }) async {
    // Validation
    if (!validStatuses.contains(status) || !validRoles.contains(role)) {
      _logError('updating user', 'Invalid status: $status or role: $role');
      return false;
    }

    return updateUserData(userId, {
      'fullName': displayName.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'address': address.trim(),
      'role': role,
      'status': status,
    });
  }

  /// Legacy update method for backward compatibility
  Future<bool> updateUserLegacy({
    required String userId,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String location,
    required String nik,
    required String jobType,
    required int monthlyIncome,
    required String accountStatus,
  }) async {
    if (!validStatuses.contains(accountStatus)) {
      _logError('updating user legacy', 'Invalid status: $accountStatus');
      return false;
    }

    return updateUserData(userId, {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'location': location.trim(),
      'address': location.trim(),
      'nik': nik.trim(),
      'jobType': jobType.trim(),
      'occupation': jobType.trim(),
      'monthlyIncome': monthlyIncome,
      'accountStatus': accountStatus,
      'status': accountStatus,
    });
  }

  /// Update user status only
  Future<bool> updateUserStatus({
    required String userId,
    required String newStatus,
  }) async {
    return updateUserData(userId, {
      'status': newStatus,
      'accountStatus': newStatus, // Support legacy field
    });
  }

  /// Update user role
  Future<bool> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    return updateUserData(userId, {
      'role': newRole,
    });
  }

  /// Delete user document
  Future<bool> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      return true;
    } catch (e) {
      _logError('deleting user', e);
      return false;
    }
  }

  /// Get users filtered by status
  Future<List<Map<String, dynamic>>> getUsersByStatus(String status) async {
    if (!validStatuses.contains(status)) {
      _logError('getting users by status', 'Invalid status: $status');
      return [];
    }

    try {
      // Efficiently combine queries with Promise.all pattern
      final results = await Future.wait([
        _usersCollection.where('status', isEqualTo: status).get(),
        _usersCollection.where('accountStatus', isEqualTo: status).get(),
      ]);

      final userDocs = [...results[0].docs, ...results[1].docs];
      
      // Deduplicate users by ID
      final Map<String, Map<String, dynamic>> uniqueUsers = {};
      
      for (final doc in userDocs) {
        if (!uniqueUsers.containsKey(doc.id)) {
          uniqueUsers[doc.id] = _mapDocToUserObject(doc.id, doc.data());
        }
      }
      
      return uniqueUsers.values.toList();
    } catch (e) {
      _logError('getting users by status', e);
      return [];
    }
  }

  /// Get users filtered by location/address
  Future<List<Map<String, dynamic>>> getUsersByLocation(String location) async {
    try {
      final results = await Future.wait([
        _usersCollection.where('address', isEqualTo: location).get(),
        _usersCollection.where('location', isEqualTo: location).get(),
      ]);

      final userDocs = [...results[0].docs, ...results[1].docs];
      
      // Deduplicate users by ID
      final Map<String, Map<String, dynamic>> uniqueUsers = {};
      
      for (final doc in userDocs) {
        if (!uniqueUsers.containsKey(doc.id)) {
          uniqueUsers[doc.id] = _mapDocToUserObject(doc.id, doc.data());
        }
      }
      
      return uniqueUsers.values.toList();
    } catch (e) {
      _logError('getting users by location', e);
      return [];
    }
  }

  /// Get unique locations for filter dropdown
  Future<List<String>> getUserLocations() async {
    try {
      final querySnapshot = await _usersCollection.get();
      
      // Use Set for efficient deduplication
      final locations = <String>{};
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final address = _safeParseString(data['address']);
        final location = _safeParseString(data['location']);

        if (address.isNotEmpty) locations.add(address);
        if (location.isNotEmpty) locations.add(location);
      }

      final result = ['Semua Lokasi', ...locations];
      
      // Sort with "Semua Lokasi" always first
      result.sort((a, b) => 
        a == 'Semua Lokasi' ? -1 : 
        b == 'Semua Lokasi' ? 1 : 
        a.compareTo(b)
      );
      
      return result;
    } catch (e) {
      _logError('getting user locations', e);
      return ['Semua Lokasi'];
    }
  }

  /// Get number of users by status
  Future<Map<String, int>> getUsersCountByStatus() async {
    try {
      // Parallel queries for better performance
      final results = await Future.wait([
        _usersCollection.where('status', isEqualTo: 'active').count().get(),
        _usersCollection.where('status', isEqualTo: 'inactive').count().get(),
        _usersCollection.where('status', isEqualTo: 'suspended').count().get(),
      ]);

      return {
        'active': results[0].count ?? 0,
        'inactive': results[1].count ?? 0,
        'suspended': results[2].count ?? 0,
      };
    } catch (e) {
      _logError('getting users count', e);
      return {'active': 0, 'inactive': 0, 'suspended': 0};
    }
  }

  /// Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return getAllUsers();
    }
    
    try {
      final lowercaseSearch = searchTerm.toLowerCase();
      
      // Get all users and filter client-side (Firestore doesn't support case-insensitive search)
      final querySnapshot = await _usersCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            final fullName = _safeParseString(data['fullName']).toLowerCase();
            final email = _safeParseString(data['email']).toLowerCase();
            return fullName.contains(lowercaseSearch) || 
                  email.contains(lowercaseSearch);
          })
          .map((doc) => _mapDocToUserObject(doc.id, doc.data()))
          .toList();
    } catch (e) {
      _logError('searching users', e);
      return [];
    }
  }

  /// Get users with their application counts
  Future<List<Map<String, dynamic>>> getUsersWithApplicationsCount() async {
    try {
      final users = await getAllUsers();

      // Add application counts in parallel
      final userFutures = users.map((user) async {
        final applicationsSnapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: user['id'])
          .count()
          .get();

        user['totalApplications'] = applicationsSnapshot.count ?? 0;
        return user;
      });

      return await Future.wait(userFutures);
    } catch (e) {
      _logError('getting users with applications count', e);
      return [];
    }
  }

  /// Migrate legacy field names to new ones
  Future<void> migrateUserFields() async {
    try {
      final querySnapshot = await _usersCollection.get();
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final updates = <String, dynamic>{};

        // Field mappings to check and update
        final fieldMappings = {
          'location': 'address',
          'jobType': 'occupation',
          'accountStatus': 'status',
        };

        // Check each mapping
        fieldMappings.forEach((oldField, newField) {
          if (data.containsKey(oldField) && !data.containsKey(newField)) {
            updates[newField] = data[oldField];
          }
        });

        // Add default fields if missing
        if (!data.containsKey('role')) updates['role'] = 'user';
        if (!data.containsKey('gender')) updates['gender'] = 'Laki-laki';

        // Apply updates if any
        if (updates.isNotEmpty) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await doc.reference.update(updates);
          developer.log('Migrated user ${doc.id}', name: 'AdminUserService');
        }
      }
    } catch (e) {
      _logError('migrating user fields', e);
    }
  }

  /// Fix inconsistent status values in database
  Future<void> fixInconsistentStatuses() async {
    try {
      final querySnapshot = await _usersCollection.get();

      final batch = _firestore.batch();
      int updateCount = 0;
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final currentStatus = _safeParseString(
          data['status'] ?? data['accountStatus'],
        );

        if (!validStatuses.contains(currentStatus)) {
          developer.log(
            'Fixing user ${doc.id} with invalid status: $currentStatus', 
            name: 'AdminUserService'
          );
          
          batch.update(doc.reference, {
            'status': 'active',
            'accountStatus': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          updateCount++;
          
          // Firebase has a limit of 500 operations per batch
          if (updateCount >= 400) {
            await batch.commit();
            updateCount = 0;
          }
        }
      }
      
      if (updateCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      _logError('fixing inconsistent statuses', e);
    }
  }
}