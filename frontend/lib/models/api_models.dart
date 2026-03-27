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
    required this.isApplied,
    required this.isBookmarked,
  });

  final int id;
  final String title;
  final String company;
  final String location;
  final String description;
  final int packageLpa;
  final String deadline;
  final bool isApplied;
  final bool isBookmarked;

  factory JobItem.fromJson(Map<String, dynamic> json) {
    return JobItem(
      id: json['id'] as int,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
      packageLpa: json['package'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
      isApplied: json['is_applied'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  JobItem copyWith({
    bool? isApplied,
    bool? isBookmarked,
  }) {
    return JobItem(
      id: id,
      title: title,
      company: company,
      location: location,
      description: description,
      packageLpa: packageLpa,
      deadline: deadline,
      isApplied: isApplied ?? this.isApplied,
      isBookmarked: isBookmarked ?? this.isBookmarked,
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
    required this.packageLpa,
    required this.deadline,
  });

  final int id;
  final int jobId;
  final String status;
  final String appliedAt;
  final String jobTitle;
  final String company;
  final String location;
  final int packageLpa;
  final String deadline;

  factory ApplicationItem.fromJson(Map<String, dynamic> json) {
    return ApplicationItem(
      id: json['id'] as int,
      jobId: json['job'] as int,
      status: json['status'] as String? ?? 'Pending',
      appliedAt: json['applied_at'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? 'Unknown role',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      packageLpa: json['package'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
    );
  }

  ApplicationItem copyWith({String? status}) {
    return ApplicationItem(
      id: id,
      jobId: jobId,
      status: status ?? this.status,
      appliedAt: appliedAt,
      jobTitle: jobTitle,
      company: company,
      location: location,
      packageLpa: packageLpa,
      deadline: deadline,
    );
  }
}

class BookmarkItem {
  const BookmarkItem({
    required this.id,
    required this.jobId,
    required this.createdAt,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.description,
    required this.packageLpa,
    required this.deadline,
  });

  final int id;
  final int jobId;
  final String createdAt;
  final String jobTitle;
  final String company;
  final String location;
  final String description;
  final int packageLpa;
  final String deadline;

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'] as int,
      jobId: json['job'] as int,
      createdAt: json['created_at'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? 'Unknown role',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      packageLpa: json['package'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
    );
  }
}

class StudentProfileItem {
  const StudentProfileItem({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.branch,
    required this.cgpa,
    required this.year,
    required this.graduationYear,
  });

  final int id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String branch;
  final double cgpa;
  final int year;
  final int graduationYear;

  factory StudentProfileItem.fromJson(Map<String, dynamic> json) {
    return StudentProfileItem(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0,
      year: json['year'] as int? ?? 0,
      graduationYear: json['graduation_year'] as int? ?? 0,
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.appliedRoles,
    required this.bookmarkedRoles,
    required this.shortlisted,
    required this.pendingReviews,
    required this.availableJobs,
  });

  final int appliedRoles;
  final int bookmarkedRoles;
  final int shortlisted;
  final int pendingReviews;
  final int availableJobs;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      appliedRoles: json['applied_roles'] as int? ?? 0,
      bookmarkedRoles: json['bookmarked_roles'] as int? ?? 0,
      shortlisted: json['shortlisted'] as int? ?? 0,
      pendingReviews: json['pending_reviews'] as int? ?? 0,
      availableJobs: json['available_jobs'] as int? ?? 0,
    );
  }
}

class StudentDashboardData {
  const StudentDashboardData({
    required this.profile,
    required this.stats,
    required this.recentApplications,
    required this.recentBookmarks,
    required this.recommendedJobs,
    required this.acceptedOffer,
  });

  final StudentProfileItem profile;
  final DashboardStats stats;
  final List<ApplicationItem> recentApplications;
  final List<BookmarkItem> recentBookmarks;
  final List<JobItem> recommendedJobs;
  final ApplicationItem? acceptedOffer;

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> applicationData =
        json['recent_applications'] as List<dynamic>? ?? const <dynamic>[];
    final List<dynamic> bookmarkData =
        json['recent_bookmarks'] as List<dynamic>? ?? const <dynamic>[];
    final List<dynamic> recommendationData =
        json['recommended_jobs'] as List<dynamic>? ?? const <dynamic>[];

    return StudentDashboardData(
      profile: StudentProfileItem.fromJson(
        json['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      stats: DashboardStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      recentApplications: applicationData
          .whereType<Map<String, dynamic>>()
          .map(ApplicationItem.fromJson)
          .toList(growable: false),
      recentBookmarks: bookmarkData
          .whereType<Map<String, dynamic>>()
          .map(BookmarkItem.fromJson)
          .toList(growable: false),
      recommendedJobs: recommendationData
          .whereType<Map<String, dynamic>>()
          .map(JobItem.fromJson)
          .toList(growable: false),
      acceptedOffer:
          (json['accepted_offer'] as Map<String, dynamic>?) != null
          ? ApplicationItem.fromJson(
              json['accepted_offer'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.activeJobPosts,
    required this.totalApplicants,
    required this.offeredStudents,
    required this.rejectedStudents,
  });

  final int activeJobPosts;
  final int totalApplicants;
  final int offeredStudents;
  final int rejectedStudents;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      activeJobPosts: json['active_job_posts'] as int? ?? 0,
      totalApplicants: json['total_applicants'] as int? ?? 0,
      offeredStudents: json['offered_students'] as int? ?? 0,
      rejectedStudents: json['rejected_students'] as int? ?? 0,
    );
  }
}

class AdminApplicantItem {
  const AdminApplicantItem({
    required this.id,
    required this.studentId,
    required this.jobId,
    required this.status,
    required this.appliedAt,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.packageLpa,
    required this.deadline,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
    required this.branch,
    required this.cgpa,
    required this.year,
  });

  final int id;
  final int studentId;
  final int jobId;
  final String status;
  final String appliedAt;
  final String jobTitle;
  final String company;
  final String location;
  final int packageLpa;
  final String deadline;
  final String studentName;
  final String studentEmail;
  final String studentPhone;
  final String branch;
  final double cgpa;
  final int year;

  factory AdminApplicantItem.fromJson(Map<String, dynamic> json) {
    return AdminApplicantItem(
      id: json['id'] as int,
      studentId: json['student'] as int,
      jobId: json['job'] as int,
      status: json['status'] as String? ?? 'Pending',
      appliedAt: json['applied_at'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      packageLpa: json['package'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
      studentName: json['student_name'] as String? ?? '',
      studentEmail: json['student_email'] as String? ?? '',
      studentPhone: json['student_phone'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0,
      year: json['year'] as int? ?? 0,
    );
  }

  AdminApplicantItem copyWith({String? status}) {
    return AdminApplicantItem(
      id: id,
      studentId: studentId,
      jobId: jobId,
      status: status ?? this.status,
      appliedAt: appliedAt,
      jobTitle: jobTitle,
      company: company,
      location: location,
      packageLpa: packageLpa,
      deadline: deadline,
      studentName: studentName,
      studentEmail: studentEmail,
      studentPhone: studentPhone,
      branch: branch,
      cgpa: cgpa,
      year: year,
    );
  }
}

class AdminDashboardData {
  const AdminDashboardData({
    required this.stats,
    required this.recentJobs,
    required this.recentApplicants,
  });

  final AdminDashboardStats stats;
  final List<JobItem> recentJobs;
  final List<AdminApplicantItem> recentApplicants;

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jobs = json['recent_jobs'] as List<dynamic>? ?? const [];
    final List<dynamic> applicants =
        json['recent_applicants'] as List<dynamic>? ?? const [];

    return AdminDashboardData(
      stats: AdminDashboardStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      recentJobs: jobs
          .whereType<Map<String, dynamic>>()
          .map(JobItem.fromJson)
          .toList(growable: false),
      recentApplicants: applicants
          .whereType<Map<String, dynamic>>()
          .map(AdminApplicantItem.fromJson)
          .toList(growable: false),
    );
  }
}

class AdminApplicationDetail {
  const AdminApplicationDetail({
    required this.application,
    required this.profile,
    required this.statusChoices,
  });

  final AdminApplicantItem application;
  final StudentProfileItem profile;
  final List<String> statusChoices;

  factory AdminApplicationDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawChoices =
        json['status_choices'] as List<dynamic>? ?? const [];
    return AdminApplicationDetail(
      application: AdminApplicantItem.fromJson(
        json['application'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
      profile: StudentProfileItem.fromJson(
        json['profile'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      statusChoices: rawChoices.map((choice) => '$choice').toList(growable: false),
    );
  }
}

class CompanySummaryItem {
  const CompanySummaryItem({
    required this.company,
    required this.totalJobs,
    required this.totalApplications,
    required this.offeredCount,
    required this.rejectedCount,
    required this.pendingCount,
  });

  final String company;
  final int totalJobs;
  final int totalApplications;
  final int offeredCount;
  final int rejectedCount;
  final int pendingCount;

  factory CompanySummaryItem.fromJson(Map<String, dynamic> json) {
    return CompanySummaryItem(
      company: json['company'] as String? ?? '',
      totalJobs: json['total_jobs'] as int? ?? 0,
      totalApplications: json['total_applications'] as int? ?? 0,
      offeredCount: json['offered_count'] as int? ?? 0,
      rejectedCount: json['rejected_count'] as int? ?? 0,
      pendingCount: json['pending_count'] as int? ?? 0,
    );
  }
}

class UserProfileItem {
  const UserProfileItem({
    required this.role,
    required this.name,
    required this.fullName,
    required this.username,
    required this.email,
    this.phone = '',
    this.branch = '',
    this.cgpa = 0,
    this.year = 0,
    this.graduationYear = 0,
  });

  final String role;
  final String name;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String branch;
  final double cgpa;
  final int year;
  final int graduationYear;

  bool get isStudent => role == 'student';

  factory UserProfileItem.fromJson(Map<String, dynamic> json) {
    return UserProfileItem(
      role: json['role'] as String? ?? 'student',
      name: (json['name'] as String?) ??
          (json['full_name'] as String?) ??
          (json['username'] as String?) ??
          '',
      fullName: (json['full_name'] as String?) ??
          (json['name'] as String?) ??
          (json['username'] as String?) ??
          '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0,
      year: json['year'] as int? ?? 0,
      graduationYear: json['graduation_year'] as int? ?? 0,
    );
  }
}

class LandingHeroStats {
  const LandingHeroStats({
    required this.upcomingDrives,
    required this.activeRoles,
    required this.interviewSlots,
    required this.offerCalls,
  });

  final int upcomingDrives;
  final int activeRoles;
  final int interviewSlots;
  final int offerCalls;

  factory LandingHeroStats.fromJson(Map<String, dynamic> json) {
    return LandingHeroStats(
      upcomingDrives: (json['upcoming_drives'] as num?)?.toInt() ?? 0,
      activeRoles: (json['active_roles'] as num?)?.toInt() ?? 0,
      interviewSlots: (json['interview_slots'] as num?)?.toInt() ?? 0,
      offerCalls: (json['offer_calls'] as num?)?.toInt() ?? 0,
    );
  }
}

class LandingOutcomeStats {
  const LandingOutcomeStats({
    required this.studentsPlaced,
    required this.placementRate,
    required this.highestPackageLpa,
    required this.averagePackageLpa,
    required this.companiesVisited,
  });

  final int studentsPlaced;
  final int placementRate;
  final int highestPackageLpa;
  final double averagePackageLpa;
  final int companiesVisited;

  factory LandingOutcomeStats.fromJson(Map<String, dynamic> json) {
    return LandingOutcomeStats(
      studentsPlaced: (json['students_placed'] as num?)?.toInt() ?? 0,
      placementRate: (json['placement_rate'] as num?)?.toInt() ?? 0,
      highestPackageLpa: (json['highest_package_lpa'] as num?)?.toInt() ?? 0,
      averagePackageLpa: (json['average_package_lpa'] as num?)?.toDouble() ?? 0,
      companiesVisited: (json['companies_visited'] as num?)?.toInt() ?? 0,
    );
  }
}

class LandingCompanyItem {
  const LandingCompanyItem({
    required this.company,
    required this.jobCount,
    required this.applicantCount,
    required this.highestPackageLpa,
  });

  final String company;
  final int jobCount;
  final int applicantCount;
  final int highestPackageLpa;

  factory LandingCompanyItem.fromJson(Map<String, dynamic> json) {
    return LandingCompanyItem(
      company: json['company'] as String? ?? '',
      jobCount: (json['job_count'] as num?)?.toInt() ?? 0,
      applicantCount: (json['applicant_count'] as num?)?.toInt() ?? 0,
      highestPackageLpa: (json['highest_package_lpa'] as num?)?.toInt() ?? 0,
    );
  }
}

class LandingSummaryData {
  const LandingSummaryData({
    required this.hero,
    required this.outcomes,
    required this.featuredCompanies,
  });

  final LandingHeroStats hero;
  final LandingOutcomeStats outcomes;
  final List<LandingCompanyItem> featuredCompanies;

  factory LandingSummaryData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> companies =
        json['featured_companies'] as List<dynamic>? ?? const [];
    return LandingSummaryData(
      hero: LandingHeroStats.fromJson(
        json['hero'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      outcomes: LandingOutcomeStats.fromJson(
        json['outcomes'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      featuredCompanies: companies
          .whereType<Map<String, dynamic>>()
          .map(LandingCompanyItem.fromJson)
          .toList(growable: false),
    );
  }
}
