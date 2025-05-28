import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data untuk profil administrator
///
/// Menyimpan informasi profil, permission, dan program yang dikelola oleh admin
class AdminProfileModel {
  // Informasi dasar
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String position;
  final String role;
  final String? profilePictureUrl;
  
  // Informasi waktu
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  
  // Status dan data terkait
  final bool isActive;
  final List<String> managedPrograms;
  final Map<String, dynamic> permissions;

  /// Konstruktor untuk membuat objek AdminProfileModel
  AdminProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.position,
    required this.role,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.isActive = true,
    this.managedPrograms = const [],
    this.permissions = const {},
  });

  /// Membuat AdminProfileModel dari Firestore document
  factory AdminProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AdminProfileModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      position: data['position'] ?? '',
      role: data['role'] ?? 'admin',
      profilePictureUrl: data['profilePictureUrl'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastLogin: data['lastLogin'] != null 
          ? (data['lastLogin'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      managedPrograms: List<String>.from(data['managedPrograms'] ?? []),
      permissions: Map<String, dynamic>.from(data['permissions'] ?? {}),
    );
  }

  /// Helper untuk parsing Timestamp ke DateTime
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    return (timestamp as Timestamp).toDate();
  }

  /// Mengkonversi model ke format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'position': position,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'managedPrograms': managedPrograms,
      'permissions': permissions,
    };
  }

  /// Membuat salinan objek dengan nilai yang diperbarui
  AdminProfileModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? position,
    String? role,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    List<String>? managedPrograms,
    Map<String, dynamic>? permissions,
  }) {
    return AdminProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      position: position ?? this.position,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      managedPrograms: managedPrograms ?? this.managedPrograms,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Memeriksa apakah admin memiliki permission tertentu
  bool hasPermission(String permission) {
    return permissions[permission] == true;
  }
  
  /// Mendapatkan informasi role yang lebih deskriptif
  String getRoleDisplayName() {
    switch (role) {
      case 'super_admin':
        return 'Super Administrator';
      case 'content_admin':
        return 'Content Administrator';
      case 'program_admin':
        return 'Program Administrator';
      default:
        return 'Administrator';
    }
  }
}