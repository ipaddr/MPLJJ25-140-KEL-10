import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Valid status values
  static const List<String> validStatuses = [
    'active',
    'pending_verification',
    'suspended',
  ];

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
      return 'pending_verification'; // Default status
    }
    return status;
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot =
          await _firestore
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
          'location': _safeParseString(data['location']),
          'nik': _safeParseString(data['nik']),
          'jobType': _safeParseString(data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'accountStatus': _safeParseStatus(data['accountStatus']),
          'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
          'ktpPictureUrl': _safeParseString(data['ktpPictureUrl']),
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'emailVerified': _safeParseBool(data['emailVerified']),
        };
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Get user by ID
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
          'location': _safeParseString(data['location']),
          'nik': _safeParseString(data['nik']),
          'jobType': _safeParseString(data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'accountStatus': _safeParseStatus(data['accountStatus']),
          'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
          'ktpPictureUrl': _safeParseString(data['ktpPictureUrl']),
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'emailVerified': _safeParseBool(data['emailVerified']),
        };
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user data
  Future<bool> updateUser({
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
        print('Invalid status: $accountStatus');
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'location': location.trim(),
        'nik': nik.trim(),
        'jobType': jobType.trim(),
        'monthlyIncome': monthlyIncome, // Ensure this is stored as int
        'accountStatus': accountStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating user: $e');
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
        print('Invalid status: $newStatus');
        return false;
      }

      await _firestore.collection('users').doc(userId).update({
        'accountStatus': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating user status: $e');
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
      print('Error deleting user: $e');
      return false;
    }
  }

  // Get users by status
  Future<List<Map<String, dynamic>>> getUsersByStatus(String status) async {
    try {
      // Validate status
      if (!validStatuses.contains(status)) {
        print('Invalid status for filtering: $status');
        return [];
      }

      final querySnapshot =
          await _firestore
              .collection('users')
              .where('accountStatus', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'fullName': _safeParseString(data['fullName']),
          'email': _safeParseString(data['email']),
          'phoneNumber': _safeParseString(data['phoneNumber']),
          'location': _safeParseString(data['location']),
          'nik': _safeParseString(data['nik']),
          'jobType': _safeParseString(data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'accountStatus': _safeParseStatus(data['accountStatus']),
          'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
          'ktpPictureUrl': _safeParseString(data['ktpPictureUrl']),
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'emailVerified': _safeParseBool(data['emailVerified']),
        };
      }).toList();
    } catch (e) {
      print('Error getting users by status: $e');
      return [];
    }
  }

  // Get users by location
  Future<List<Map<String, dynamic>>> getUsersByLocation(String location) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('location', isEqualTo: location)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'fullName': _safeParseString(data['fullName']),
          'email': _safeParseString(data['email']),
          'phoneNumber': _safeParseString(data['phoneNumber']),
          'location': _safeParseString(data['location']),
          'nik': _safeParseString(data['nik']),
          'jobType': _safeParseString(data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'accountStatus': _safeParseStatus(data['accountStatus']),
          'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
          'ktpPictureUrl': _safeParseString(data['ktpPictureUrl']),
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'emailVerified': _safeParseBool(data['emailVerified']),
        };
      }).toList();
    } catch (e) {
      print('Error getting users by location: $e');
      return [];
    }
  }

  // Get unique locations for filter
  Future<List<String>> getUserLocations() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      final locations = <String>{};
      for (final doc in querySnapshot.docs) {
        final location = _safeParseString(doc.data()['location']);
        if (location.isNotEmpty) {
          locations.add(location);
        }
      }

      final result = ['Semua Lokasi', ...locations.toList()];
      result.sort(
        (a, b) =>
            a == 'Semua Lokasi'
                ? -1
                : b == 'Semua Lokasi'
                ? 1
                : a.compareTo(b),
      );
      return result;
    } catch (e) {
      print('Error getting user locations: $e');
      return ['Semua Lokasi'];
    }
  }

  // Get users count by status
  Future<Map<String, int>> getUsersCountByStatus() async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('users')
            .where('accountStatus', isEqualTo: 'active')
            .count()
            .get(),
        _firestore
            .collection('users')
            .where('accountStatus', isEqualTo: 'pending_verification')
            .count()
            .get(),
        _firestore
            .collection('users')
            .where('accountStatus', isEqualTo: 'suspended')
            .count()
            .get(),
      ]);

      return {
        'active': results[0].count ?? 0,
        'pending_verification': results[1].count ?? 0,
        'suspended': results[2].count ?? 0,
      };
    } catch (e) {
      print('Error getting users count: $e');
      return {'active': 0, 'pending_verification': 0, 'suspended': 0};
    }
  }

  // Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String searchTerm) async {
    try {
      final lowercaseSearch = searchTerm.toLowerCase();

      // Get all users and filter client-side (Firestore doesn't support case-insensitive search)
      final querySnapshot =
          await _firestore
              .collection('users')
              .orderBy('createdAt', descending: true)
              .get();

      final filteredUsers =
          querySnapshot.docs.where((doc) {
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
          'location': _safeParseString(data['location']),
          'nik': _safeParseString(data['nik']),
          'jobType': _safeParseString(data['jobType']),
          'monthlyIncome': _safeParseInt(data['monthlyIncome']),
          'accountStatus': _safeParseStatus(data['accountStatus']),
          'profilePictureUrl': _safeParseString(data['profilePictureUrl']),
          'ktpPictureUrl': _safeParseString(data['ktpPictureUrl']),
          'createdAt': data['createdAt'] as Timestamp?,
          'updatedAt': data['updatedAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'emailVerified': _safeParseBool(data['emailVerified']),
        };
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get users with applications count
  Future<List<Map<String, dynamic>>> getUsersWithApplicationsCount() async {
    try {
      final users = await getAllUsers();

      // Get application counts for each user
      for (var user in users) {
        final applicationsSnapshot =
            await _firestore
                .collection('applications')
                .where('userId', isEqualTo: user['id'])
                .count()
                .get();

        user['totalApplications'] = applicationsSnapshot.count ?? 0;
      }

      return users;
    } catch (e) {
      print('Error getting users with applications count: $e');
      return [];
    }
  }

  // Fix inconsistent status values in database
  Future<void> fixInconsistentStatuses() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final currentStatus = _safeParseString(data['accountStatus']);

        if (!validStatuses.contains(currentStatus)) {
          print('Fixing user ${doc.id} with invalid status: $currentStatus');
          await doc.reference.update({
            'accountStatus': 'pending_verification',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error fixing inconsistent statuses: $e');
    }
  }
}
