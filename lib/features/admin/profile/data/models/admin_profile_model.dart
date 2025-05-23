import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String position;
  final String role;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;
  final List<String> managedPrograms;
  final Map<String, dynamic> permissions;

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

  // Convert from Firestore document
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      managedPrograms: List<String>.from(data['managedPrograms'] ?? []),
      permissions: Map<String, dynamic>.from(data['permissions'] ?? {}),
    );
  }

  // Convert to Firestore document
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

  // Create a copy with updated fields
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
}