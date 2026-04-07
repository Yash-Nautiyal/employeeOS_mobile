class JobOption {
  final String id;
  final String title;

  const JobOption({required this.id, required this.title});
}

class HrOption {
  final String id;
  final String fullName;
  final String email;

  const HrOption({
    required this.id,
    required this.fullName,
    required this.email,
  });

  String get displayName {
    final name = fullName.trim();
    if (name.isNotEmpty) return name;
    final mail = email.trim();
    if (mail.isNotEmpty) return mail;
    return id;
  }
}
