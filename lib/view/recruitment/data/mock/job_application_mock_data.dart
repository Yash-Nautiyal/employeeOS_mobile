/// Mock applications for job postings (no database).
///
/// Each application belongs to a job via [job_id]. In a real app,
/// this would come from a backend; here it's just in-memory data
/// used by the Applications tab.
List<Map<String, dynamic>> get jobApplicationMockList => [
      {
        'id': 'app-1',
        'job_id': 'job-mock-1',
        'full_name': 'Alice Johnson',
        'email': 'alice@example.com',
        'phone': '+91-98765-00001',
        'status': 'Applied',
        'applied_on': '2025-06-25T09:30:00.000Z',
        'resume_url':
            'https://example.com/resumes/alice_johnson_flutter_developer.pdf',
      },
      {
        'id': 'app-2',
        'job_id': 'job-mock-1',
        'full_name': 'Rahul Verma',
        'email': 'rahul.verma@example.com',
        'phone': '+91-98765-00002',
        'status': 'Shortlisted',
        'applied_on': '2025-06-26T11:15:00.000Z',
        'resume_url':
            'https://example.com/resumes/rahul_verma_senior_flutter.pdf',
      },
      {
        'id': 'app-3',
        'job_id': 'job-mock-2',
        'full_name': 'Sneha Patel',
        'email': 'sneha.patel@example.com',
        'phone': '+91-98765-00003',
        'status': 'Applied',
        'applied_on': '2025-06-21T15:45:00.000Z',
        'resume_url':
            'https://example.com/resumes/sneha_patel_cloud_intern.pdf',
      },
      {
        'id': 'app-4',
        'job_id': 'job-mock-2',
        'full_name': 'Michael Lee',
        'email': 'michael.lee@example.com',
        'phone': '+91-98765-00004',
        'status': 'Rejected',
        'applied_on': '2025-06-22T10:00:00.000Z',
        'resume_url':
            'https://example.com/resumes/michael_lee_cloud_intern.pdf',
      },
    ];
