import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAuthService {
  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'user_isLoggedIn';
  static const String _authTokenKey = 'user_authToken';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _lastLoginKey = 'user_lastLogin';
  static const String _tokenExpiryKey = 'user_tokenExpiry';

  // Token expiry duration - 1 hour
  static const int _tokenExpiryDuration = 3600000; // 1 hour in milliseconds

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final String? authToken = prefs.getString(_authTokenKey);
      final int? tokenExpiry = prefs.getInt(_tokenExpiryKey);

      // If no token or not logged in, return false
      if (!isLoggedIn || authToken == null) {
        return false;
      }

      // Check if token is expired
      final int now = DateTime.now().millisecondsSinceEpoch;
      if (tokenExpiry != null && now > tokenExpiry) {
        // Try to refresh the token
        return _refreshAuthToken();
      }

      return true;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Try to refresh the auth token
  Future<bool> _refreshAuthToken() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      // If no current user, authentication has expired
      if (currentUser == null) {
        await logout();
        return false;
      }
      
      // Force token refresh
      await currentUser.getIdToken(true);
      String? newToken = await currentUser.getIdToken();
      
      if (newToken == null) {
        await logout();
        return false;
      }
      
      // Save the new token
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, newToken);
      
      // Set new expiry time
      final int expiryTime = DateTime.now().millisecondsSinceEpoch + _tokenExpiryDuration;
      await prefs.setInt(_tokenExpiryKey, expiryTime);
      
      return true;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await logout();
      return false;
    }
  }

  /// Save user login information
  Future<void> saveLoginInfo({
    required String authToken,
    required String userId,
    String? name,
    String? email,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_authTokenKey, authToken);
      await prefs.setString(_userIdKey, userId);
      
      // Calculate token expiry (1 hour from now)
      final int expiryTime = DateTime.now().millisecondsSinceEpoch + _tokenExpiryDuration;
      await prefs.setInt(_tokenExpiryKey, expiryTime);
      
      if (name != null) {
        await prefs.setString(_userNameKey, name);
      }
      
      if (email != null) {
        await prefs.setString(_userEmailKey, email);
      }
      
      // Save current timestamp as last login time
      await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
      
    } catch (e) {
      debugPrint('Error saving login info: $e');
      rethrow;
    }
  }

  /// Get user auth token
  Future<String?> getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Get user profile information
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return {
        'userId': prefs.getString(_userIdKey),
        'name': prefs.getString(_userNameKey),
        'email': prefs.getString(_userEmailKey),
        'lastLogin': prefs.getInt(_lastLoginKey),
      };
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return {};
    }
  }

  /// Clear user login information (logout)
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_tokenExpiryKey);
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }
}