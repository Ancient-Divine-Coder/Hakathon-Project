enum UserRole {
  faculty,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String? value) {
    if (value == null) return UserRole.faculty;
    final normalized = value.toLowerCase().trim();
    if (normalized == 'admin' || normalized == 'administrator') {
      return UserRole.admin;
    }
    return UserRole.faculty;
  }
}
