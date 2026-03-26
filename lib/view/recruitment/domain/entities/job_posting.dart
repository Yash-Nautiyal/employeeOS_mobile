import 'package:equatable/equatable.dart';

/// Job posting entity. [description] is stored as JSON (Quill Delta)
/// from flutter_quill — use [Document.fromJson(jsonDecode(description))]
/// to display in a read-only QuillEditor.
class JobPosting extends Equatable {
  final String id;
  final String title;
  final String department;

  /// Quill document as JSON string (Delta format from flutter_quill).
  final String? description;
  final String? location;
  final int positions;
  final DateTime? lastDateToApply;
  final String joiningType;
  final bool isInternship;
  final String? ctcRange;
  final String postedByName;
  final String postedByEmail;
  final DateTime? createdAt;
  final bool isActive;

  const JobPosting({
    required this.id,
    required this.title,
    required this.department,
    this.description,
    this.location,
    this.positions = 1,
    this.lastDateToApply,
    required this.joiningType,
    this.isInternship = false,
    this.ctcRange,
    required this.postedByName,
    required this.postedByEmail,
    this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        department,
        description,
        location,
        positions,
        lastDateToApply,
        joiningType,
        isInternship,
        ctcRange,
        postedByName,
        postedByEmail,
        createdAt,
        isActive,
      ];
}
