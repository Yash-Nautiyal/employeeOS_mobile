/// Mock job postings for UI development (no database).
///
/// [description] is stored as a **Quill Delta JSON string**: the same format
/// you get from `jsonEncode(quillController.document.toDelta().toJson())`.
/// To display it: `Document.fromJson(jsonDecode(description) as List)` then
/// a read-only QuillController + QuillEditor.
List<Map<String, dynamic>> get jobPostingMockList => [
      {
        'id': 'job-mock-1',
        'title': 'Senior Flutter Developer',
        'department': 'Engineering',
        'description': _description1,
        'location': 'Remote',
        'positions': 2,
        'is_active': true,
        'last_date_to_apply': '2026-12-15T23:59:59.000Z',
        'joining_type': 'Notice Period',
        'is_internship': false,
        'ctc_range': '₹15–22 LPA',
        'posted_by_name': 'Yash Nautiyal',
        'posted_by_email': 'nautiyalyash4@gmail.com',
        'created_at': '2026-01-23T10:00:00.000Z',
        'pipeline': [
          {
            'id': 'e1',
            'name': 'Shortlist',
            'type': 'statusOnly',
          },
          {
            'id': 'e2',
            'name': 'Telephone',
            'type': 'interview',
          },
          {
            'id': 'e3',
            'name': 'Task Submit',
            'type': 'submission',
          },
          {
            'id': 'e4',
            'name': 'Technical',
            'type': 'interview',
          },
          {
            'id': 'e5',
            'name': 'Onboarding',
            'type': 'interview',
          },
        ],
      },
      {
        'id': 'job-mock-2',
        'title': 'Cloud Internship – AWS',
        'department': 'Tech',
        'description': _description2,
        'location': 'Bangalore',
        'positions': 1,
        'is_active': true,
        'last_date_to_apply': '2026-08-30T23:59:59.000Z',
        'joining_type': 'Immediate',
        'is_internship': true,
        'ctc_range': null,
        'posted_by_name': 'Yash Nautiyal',
        'posted_by_email': 'nautiyalyash4@gmail.com',
        'created_at': '2026-02-20T09:00:00.000Z',
        'pipeline': [
          {
            'id': 't1',
            'name': 'Shortlist',
            'type': 'statusOnly',
          },
          {
            'id': 't2',
            'name': 'Telephone',
            'type': 'interview',
          },
          {
            'id': 't3',
            'name': 'Task Submit',
            'type': 'submission',
          },
          {
            'id': 't4',
            'name': 'Technical',
            'type': 'interview',
          },
          {
            'id': 't5',
            'name': 'Onboarding',
            'type': 'interview',
          },
        ],
      },
    ];

/// Quill Delta JSON string: heading, bullet list, bold.
const String _description1 =
    r'[{"insert":"Role\n"},{"insert":"Senior Flutter Developer\n","attributes":{"header":1}},{"insert":"\nResponsibilities\n"},{"insert":"Design and ship features in the Flutter app\n","attributes":{"list":"bullet"}},{"insert":"Collaborate with backend and design teams\n","attributes":{"list":"bullet"}},{"insert":"Write tests and maintain code quality\n","attributes":{"list":"bullet"}},{"insert":"\nRequirements\n"},{"insert":"3+ years Flutter/Dart\n","attributes":{"list":"ordered"}},{"insert":"Strong understanding of state management\n","attributes":{"list":"ordered"}},{"insert":"Experience with REST APIs\n","attributes":{"list":"ordered"}}]';

/// Quill Delta JSON string: plain and bullet list.
const String _description2 =
    r'[{"insert":"About the role\n"},{"insert":"6-month internship on AWS and cloud tools.\n\n"},{"insert":"What you’ll do\n"},{"insert":"Assist in building and deploying services on AWS\n","attributes":{"list":"bullet"}},{"insert":"Learn Lambda, API Gateway, and CI/CD\n","attributes":{"list":"bullet"}},{"insert":"Support the engineering team in day-to-day tasks\n","attributes":{"list":"bullet"}}]';
