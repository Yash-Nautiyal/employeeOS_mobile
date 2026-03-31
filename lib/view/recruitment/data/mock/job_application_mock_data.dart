/// Mock applications for job postings (no database).
///
/// Each application belongs to a job via [job_id]. In a real app,
/// this would come from a backend; here it's just in-memory data
/// used by the Applications tab.
List<Map<String, dynamic>> get jobApplicationMockList => [
      {
        'id': 'app-1',
        'job_id': 'job-mock-1',
        'job_title': 'Senior Flutter Developer',
        'full_name': 'Yash Nautiyal1',
        'email': 'yashnautiyal04@gmail.com',
        'phone': '+91-98765-00001',
        'status': 'Applied',
        'applied_on': '2025-06-25T09:30:00.000Z',
        'resume_url':
            'https://example.com/resumes/alice_johnson_flutter_developer.pdf',
      },
      {
        'id': 'app-2',
        'job_id': 'job-mock-1',
        'job_title': 'Senior Flutter Developer',
        'full_name': 'Yash Nautiyal2',
        'email': 'ynautiyal811@gmail.com',
        'phone': '+91-98765-00002',
        'status': 'Shortlisted',
        'applied_on': '2025-06-26T11:15:00.000Z',
        'resume_url':
            'https://example.com/resumes/rahul_verma_senior_flutter.pdf',
      },
      {
        'id': 'app-3',
        'job_id': 'job-mock-1',
        'job_title': 'Senior Flutter Developer',
        'full_name': 'Yash Nautiyal3',
        'email': 'itscrzy45@gmail.com',
        'phone': '+91-98765-00003',
        'status': 'Shortlisted',
        'applied_on': '2025-06-27T10:00:00.000Z',
        'resume_url': 'https://example.com/resumes/dev_candidate_flutter.pdf',
      },
    ];
