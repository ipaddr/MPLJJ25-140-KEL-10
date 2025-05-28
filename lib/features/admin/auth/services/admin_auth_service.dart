import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'admin_isLoggedIn';
  static const String _authTokenKey = 'admin_authToken';
  static const String _adminIdKey = 'admin_id';
  static const String _adminNameKey = 'admin_name';
  static const String _adminEmailKey = 'admin_email';
  static const String _lastLoginKey = 'admin_lastLogin';
  static const String _tokenExpiryKey = 'admin_tokenExpiry';

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

  /// Save admin login information
  Future<void> saveLoginInfo({
    required String authToken,
    required String adminId,
    String? name,
    String? email,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_authTokenKey, authToken);
      await prefs.setString(_adminIdKey, adminId);
      
      // Calculate token expiry (1 hour from now)
      final int expiryTime = DateTime.now().millisecondsSinceEpoch + _tokenExpiryDuration;
      await prefs.setInt(_tokenExpiryKey, expiryTime);
      
      if (name != null) {
        await prefs.setString(_adminNameKey, name);
      }
      
      if (email != null) {
        await prefs.setString(_adminEmailKey, email);
      }
      
      // Save current timestamp as last login time
      await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
      
    } catch (e) {
      debugPrint('Error saving login info: $e');
      rethrow;
    }
  }

  /// Get admin auth token
  Future<String?> getAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Get admin profile information
  Future<Map<String, dynamic>> getAdminProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return {
        'adminId': prefs.getString(_adminIdKey),
        'name': prefs.getString(_adminNameKey),
        'email': prefs.getString(_adminEmailKey),
        'lastLogin': prefs.getInt(_lastLoginKey),
      };
    } catch (e) {
      debugPrint('Error getting admin profile: $e');
      return {};
    }
  }

  /// Clear admin login information (logout)
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_adminIdKey);
      await prefs.remove(_adminNameKey);
      await prefs.remove(_adminEmailKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_tokenExpiryKey);
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }
}