/// Role for app-wide permissions. Matches ROLE PERMISSIONS: EMPLOYEE, HR, ADMIN.
enum UserRole {
  employee,
  hr,
  admin;

  static UserRole fromString(String? value) {
    if (value == null || value.trim().isEmpty) return UserRole.employee;
    final lower = value.trim().toLowerCase();
    switch (lower) {
      case 'admin':
        return UserRole.admin;
      case 'hr':
        return UserRole.hr;
      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  String get value => name;
  bool get isEmployee => this == UserRole.employee;
  bool get isHR => this == UserRole.hr;
  bool get isAdmin => this == UserRole.admin;
  bool get canManageOwnJobs => isHR || isAdmin;
  bool get canManageGlobalConfig => isAdmin;
  bool get canManageAnyJob => isAdmin;
}
