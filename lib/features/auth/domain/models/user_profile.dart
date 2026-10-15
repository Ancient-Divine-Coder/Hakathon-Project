import '../../../../core/models/user_role.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? facultyProfileId;
  final DateTime? lastLoginAt;
  final bool isActive;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.facultyProfileId,
    this.lastLoginAt,
    this.isActive = true,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? facultyProfileId,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      facultyProfileId: facultyProfileId ?? this.facultyProfileId,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'facultyProfileId': facultyProfileId,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime? parsedLastLogin;
    if (map['lastLoginAt'] != null) {
      parsedLastLogin = DateTime.tryParse(map['lastLoginAt'].toString());
    }

    return UserProfile(
      uid: id ?? map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      role: UserRoleExtension.fromString(map['role']?.toString()),
      facultyProfileId: map['facultyProfileId']?.toString(),
      lastLoginAt: parsedLastLogin,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
