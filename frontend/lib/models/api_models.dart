class LoginResponse {
  const LoginResponse({
    required this.role,
    required this.studentId,
    required this.username,
    required this.fullName,
    required this.email,
  });

  final String role;
  final int? studentId;
  final String username;
  final String fullName;
  final String email;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      role: json['role'] as String? ?? 'student',
      studentId: json['student_id'] as int?,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String? ?? '',
    );
  }
}

class JobItem {
  const JobItem({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.packageLpa,
    required this.deadline,
  });

  final int id;
  final String title;
  final String company;
  final String location;
  final String description;
  final int packageLpa;
  final String deadline;

  factory JobItem.fromJson(Map<String, dynamic> json) {
    return JobItem(
      id: json['id'] as int,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
      packageLpa: json['package'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
    );
  }
}

class ApplicationItem {
  const ApplicationItem({
    required this.id,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.jobTitle,
    required this.company,
    required this.location,
  });

  final int id;
  final int jobId;
  final String status;
  final String appliedAt;
  final String jobTitle;
  final String company;
  final String location;

  factory ApplicationItem.fromJson(Map<String, dynamic> json) {
    return ApplicationItem(
      id: json['id'] as int,
      jobId: json['job'] as int,
      status: json['status'] as String? ?? 'Pending',
      appliedAt: json['applied_at'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? 'Unknown role',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}
