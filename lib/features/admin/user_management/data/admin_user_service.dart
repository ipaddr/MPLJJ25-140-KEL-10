import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Removed unused _auth field

  // Valid status values - disesuaikan dengan UI baru
  static const List<String> validStatuses = ['active', 'inactive', 'suspended'];

  // Valid role values - ditambahkan untuk UI baru
  static const List<String> validRoles = ['user', 'admin'];

  // Safe conversion helper methods
  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static String _safeParseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _safeParseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  // Safe status parsing with validation
  static String _safeParseStatus(dynamic value) {
    final status = _safeParseString(value);
    if (status.isEmpty || !validStatuses.contains(status)) {
      return 'active'; // Default status
    }
    return status;
  }

  // Safe role parsing with validation
  static String _safeParseRole(dynamic value) {
    final role = _safeParseString(value);
    if (role.isEmpty || !validRoles.contains(role)) {
      return 'user'; // Default role
    }
    return role;
  }

  // Safe DateTime parsing
  static DateTime? _safeParseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'fullName': _safeParseString(data['fullName']),
          'email': _safeParseString(data['email']),
          'phoneNumber': _safeParseString(data['phoneNumber']),
          'address': _safeParseString(
            data['address'] ?? data['location'],
          ), // Support both field names
          'occupation': _safeParseString(
            data['occupation'] ?? data['jobType'],
          ), // Support both field names
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'gender': _safeParseString(data['gender']),
          'birthDate': _safeParseDateTime(data['birthDate']),
          'emergencyContactName': _safeParseString(
            data['emergencyContactName'],
          ),
          'emergencyContactPhone': _safeParseString(
            data['emergencyContactPhone'],
          ),
          'status': _safeParseStatus(
            data['status'] ?? data['accountStatus'],
          ), // Support both field names
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
      }).toList();
    } catch (e) {
      developer.log('Error getting users: $e', name: 'AdminUserService');
      return [];
    }
  }

  // Get user by ID - disesuaikan dengan field baru
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'id': doc.id,
          'fullName': _safeParseString(data['fullName']),
          'email': _safeParseString(data['email']),
          'phoneNumber': _safeParseString(data['phoneNumber']),
          'address': _safeParseString(data['address'] ?? data['location']),
          'occupation': _safeParseString(data['occupation'] ?? data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'gender': _safeParseString(data['gender']),
          'birthDate': _safeParseDateTime(data['birthDate']),
          'emergencyContactName': _safeParseString(
            data['emergencyContactName'],
          ),
          'emergencyContactPhone': _safeParseString(
            data['emergencyContactPhone'],
          ),
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
      return null;
    } catch (e) {
      developer.log('Error getting user: $e', name: 'AdminUserService');
      return null;
    }
  }

  // Update user data - simplified method signature for UI compatibility
  Future<bool> updateUser({
    required String userId,
    required String displayName,
    required String email,
    required String phoneNumber,
    required String address,
    required String role,
    required String status,
  }) async {
    try {
      // Validate status and role
      if (!validStatuses.contains(status)) {
        developer.log('Invalid status: $status', name: 'AdminUserService');
        return false;
      }

      if (!validRoles.contains(role)) {
        developer.log('Invalid role: $role', name: 'AdminUserService');
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'fullName': displayName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'address': address.trim(),
        'role': role,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('Error updating user: $e', name: 'AdminUserService');
      return false;
    }
  }

  // Update user data - method baru yang fleksibel untuk UI baru
  Future<bool> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      // Validate status and role if provided
      if (userData.containsKey('status') &&
          !validStatuses.contains(userData['status'])) {
        developer.log('Invalid status: ${userData['status']}', name: 'AdminUserService');
        return false;
      }

      if (userData.containsKey('role') &&
          !validRoles.contains(userData['role'])) {
        developer.log('Invalid role: ${userData['role']}', name: 'AdminUserService');
        return false;
      }

      // Ensure updatedAt is always set
      userData['updatedAt'] = FieldValue.serverTimestamp();

      // Convert DateTime to Timestamp if needed
      if (userData.containsKey('birthDate') &&
          userData['birthDate'] is DateTime) {
        userData['birthDate'] = Timestamp.fromDate(userData['birthDate']);
      }

      await _firestore.collection('users').doc(userId).update(userData);

      return true;
    } catch (e) {
      developer.log('Error updating user: $e', name: 'AdminUserService');
      return false;
    }
  }

  // Legacy update method - untuk backward compatibility
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
    try {
      // Validate status before updating
      if (!validStatuses.contains(accountStatus)) {
        developer.log('Invalid status: $accountStatus', name: 'AdminUserService');
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'location': location.trim(),
        'address': location.trim(), // Also update new field name
        'nik': nik.trim(),
        'jobType': jobType.trim(),
        'occupation': jobType.trim(), // Also update new field name
        'monthlyIncome': monthlyIncome,
        'accountStatus': accountStatus,
        'status': accountStatus, // Also update new field name
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('Error updating user: $e', name: 'AdminUserService');
      return false;
    }
  }

  // Update user status only
  Future<bool> updateUserStatus({
    required String userId,
    required String newStatus,
  }) async {
    try {
      // Validate status before updating
      if (!validStatuses.contains(newStatus)) {
        developer.log('Invalid status: $newStatus', name: 'AdminUserService');
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'status': newStatus,
        'accountStatus': newStatus, // Also update legacy field
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('Error updating user status: $e', name: 'AdminUserService');
      return false;
    }
  }

  // Update user role
  Future<bool> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      // Validate role before updating
      if (!validRoles.contains(newRole)) {
        developer.log('Invalid role: $newRole', name: 'AdminUserService');
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      developer.log('Error updating user role: $e', name: 'AdminUserService');
      return false;
    }
  }

  // Delete user (also delete from Firebase Auth)
  Future<bool> deleteUser(String userId) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Note: Deleting from Firebase Auth requires admin SDK or the user to be currently signed in
      // For this implementation, we'll only delete from Firestore
      // In production, you might want to use Firebase Admin SDK or mark the user as deleted

      return true;
    } catch (e) {
      developer.log('Error deleting user: $e', name: 'AdminUserService');
      return false;
    }
  }

  // Get users by status
  Future<List<Map<String, dynamic>>> getUsersByStatus(String status) async {
    try {
      // Validate status
      if (!validStatuses.contains(status)) {
        developer.log('Invalid status for filtering: $status', name: 'AdminUserService');
        return [];
      }

      // Query both old and new status field names
      final querySnapshot1 = await _firestore
          .collection('users')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      final querySnapshot2 = await _firestore
          .collection('users')
          .where('accountStatus', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      // Combine and deduplicate results
      final userIds = <String>{};
      final users = <Map<String, dynamic>>[];

      for (final doc in [...querySnapshot1.docs, ...querySnapshot2.docs]) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          final data = doc.data();
          users.add({
            'id': doc.id,
            'fullName': _safeParseString(data['fullName']),
            'email': _safeParseString(data['email']),
            'phoneNumber': _safeParseString(data['phoneNumber']),
            'address': _safeParseString(data['address'] ?? data['location']),
            'occupation': _safeParseString(
              data['occupation'] ?? data['jobType'],
            ),
            'monthlyIncome': _safeParseInt(data['monthlyIncome']),
            'gender': _safeParseString(data['gender']),
            'birthDate': _safeParseDateTime(data['birthDate']),
            'emergencyContactName': _safeParseString(
              data['emergencyContactName'],
            ),
            'emergencyContactPhone': _safeParseString(
              data['emergencyContactPhone'],
            ),
            'status': _safeParseStatus(data['status'] ?? data['accountStatus']),
            'role': _safeParseRole(data['role']),
            'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
            'createdAt': data['createdAt'] as Timestamp?,
            'updatedAt': data['updatedAt'] as Timestamp?,
            'lastLogin': data['lastLogin'] as Timestamp?,
            'emailVerified': _safeParseBool(data['emailVerified']),
          });
        }
      }

      return users;
    } catch (e) {
      developer.log('Error getting users by status: $e', name: 'AdminUserService');
      return [];
    }
  }

  // Get users by location/address
  Future<List<Map<String, dynamic>>> getUsersByLocation(String location) async {
    try {
      // Query both old and new address field names
      final querySnapshot1 = await _firestore
          .collection('users')
          .where('address', isEqualTo: location)
          .orderBy('createdAt', descending: true)
          .get();

      final querySnapshot2 = await _firestore
          .collection('users')
          .where('location', isEqualTo: location)
          .orderBy('createdAt', descending: true)
          .get();

      // Combine and deduplicate results
      final userIds = <String>{};
      final users = <Map<String, dynamic>>[];

      for (final doc in [...querySnapshot1.docs, ...querySnapshot2.docs]) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          final data = doc.data();
          users.add({
            'id': doc.id,
            'fullName': _safeParseString(data['fullName']),
            'email': _safeParseString(data['email']),
            'phoneNumber': _safeParseString(data['phoneNumber']),
            'address': _safeParseString(data['address'] ?? data['location']),
            'occupation': _safeParseString(
              data['occupation'] ?? data['jobType'],
            ),
            'monthlyIncome': _safeParseInt(data['monthlyIncome']),
            'gender': _safeParseString(data['gender']),
            'birthDate': _safeParseDateTime(data['birthDate']),
            'emergencyContactName': _safeParseString(
              data['emergencyContactName'],
            ),
            'emergencyContactPhone': _safeParseString(
              data['emergencyContactPhone'],
            ),
            'status': _safeParseStatus(data['status'] ?? data['accountStatus']),
            'role': _safeParseRole(data['role']),
            'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
            'createdAt': data['createdAt'] as Timestamp?,
            'updatedAt': data['updatedAt'] as Timestamp?,
            'lastLogin': data['lastLogin'] as Timestamp?,
            'emailVerified': _safeParseBool(data['emailVerified']),
          });
        }
      }

      return users;
    } catch (e) {
      developer.log('Error getting users by location: $e', name: 'AdminUserService');
      return [];
    }
  }

  // Get unique locations for filter
  Future<List<String>> getUserLocations() async {
    try {
      final querySnapshot = await _firestore.collection('''
users''').get();

      final locations = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final address = _safeParseString(data['address']);
        final location = _safeParseString(data['location']);

        if (address.isNotEmpty) locations.add(address);
        if (location.isNotEmpty) locations.add(location);
      }

      // Fixed: Removed unnecessary .toList() call
      final result = ['Semua Lokasi', ...locations];
      result.sort(
        (a, b) => a == 'Semua Lokasi'
            ? -1
            : b == 'Semua Lokasi'
                ? 1
                : a.compareTo(b),
      );
      return result;
    } catch (e) {
      developer.log('Error getting user locations: $e', name: 'AdminUserService');
      return ['Semua Lokasi'];
    }
  }

  // Get users count by status
  Future<Map<String, int>> getUsersCountByStatus() async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('users')
            .where('status', isEqualTo: 'active')
            .count()
            .get(),
        _firestore
            .collection('users')
            .where('status', isEqualTo: 'inactive')
            .count()
            .get(),
        _firestore
            .collection('users')
            .where('status', isEqualTo: 'suspended')
            .count()
            .get(),
      ]);

      return {
        'active': results[0].count ?? 0,
        'inactive': results[1].count ?? 0,
        'suspended': results[2].count ?? 0,
      };
    } catch (e) {
      developer.log('Error getting users count: $e', name: 'AdminUserService');
      return {'active': 0, 'inactive': 0, 'suspended': 0};
    }
  }

  // Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String searchTerm) async {
    try {
      final lowercaseSearch = searchTerm.toLowerCase();

      // Get all users and filter client-side (Firestore doesn't support case-insensitive search)
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final filteredUsers = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final fullName = _safeParseString(data['fullName']).toLowerCase();
        final email = _safeParseString(data['email']).toLowerCase();

        return fullName.contains(lowercaseSearch) ||
            email.contains(lowercaseSearch);
      }).toList();

      return filteredUsers.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'fullName': _safeParseString(data['fullName']),
          'email': _safeParseString(data['email']),
          'phoneNumber': _safeParseString(data['phoneNumber']),
          'address': _safeParseString(data['address'] ?? data['location']),
          'occupation': _safeParseString(data['occupation'] ?? data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'gender': _safeParseString(data['gender']),
          'birthDate': _safeParseDateTime(data['birthDate']),
          'emergencyContactName': _safeParseString(
            data['emergencyContactName'],
          ),
          'emergencyContactPhone': _safeParseString(
            data['emergencyContactPhone'],
          ),
          'status': _safeParseStatus(data['status'] ?? data['accountStatus']),
          'role': _safeParseRole(data['role']),
          'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'emailVerified': _safeParseBool(data['emailVerified']),
        };
      }).toList();
    } catch (e) {
      developer.log('Error searching users: $e', name: 'AdminUserService');
      return [];
    }
  }

  // Get users with applications count
  Future<List<Map<String, dynamic>>> getUsersWithApplicationsCount() async {
    try {
      final users = await getAllUsers();

      // Get application counts for each user
      for (var user in users) {
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('userId', isEqualTo: user['id'])
            .count()
            .get();

        user['totalApplications'] = applicationsSnapshot.count ?? 0;
      }

      return users;
    } catch (e) {
      developer.log('Error getting users with applications count: $e', name: 'AdminUserService');
      return [];
    }
  }

  // Migrate old field names to new ones
  Future<void> migrateUserFields() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final updates = <String, dynamic>{};

        // Migrate location to address
        if (data.containsKey('location') && !data.containsKey('address')) {
          updates['address'] = data['location'];
        }

        // Migrate jobType to occupation
        if (data.containsKey('jobType') && !data.containsKey('occupation')) {
          updates['occupation'] = data['jobType'];
        }

        // Migrate accountStatus to status
        if (data.containsKey('accountStatus') && !data.containsKey('status')) {
          updates['status'] = data['accountStatus'];
        }

        // Add default role if missing
        if (!data.containsKey('role')) {
          updates['role'] = 'user';
        }

        // Add default gender if missing
        if (!data.containsKey('gender')) {
          updates['gender'] = 'Laki-laki';
        }

        // Apply updates if any
        if (updates.isNotEmpty) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await doc.reference.update(updates);
          developer.log('Migrated user ${doc.id}', name: 'AdminUserService');
        }
      }
    } catch (e) {
      developer.log('Error migrating user fields: $e', name: 'AdminUserService');
    }
  }

  // Fix inconsistent status values in database
  Future<void> fixInconsistentStatuses() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final currentStatus = _safeParseString(
          data['status'] ?? data['accountStatus'],
        );

        if (!validStatuses.contains(currentStatus)) {
          developer.log('Fixing user ${doc.id} with invalid status: $currentStatus', name: 'AdminUserService');
          await doc.reference.update({
            'status': 'active',
            'accountStatus': 'active', // Also update legacy field
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      developer.log('Error fixing inconsistent statuses: $e', name: 'AdminUserService');
    }
  }
}