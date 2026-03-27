import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/api_models.dart';

class ApiService {
  const ApiService();

  static const String _apiBaseFromEnv = String.fromEnvironment('API_BASE_URL');
  static const String _defaultLanBaseUrl = 'http://172.50.10.122:8000/api';

  static String get _baseUrl {
    final String envUrl = _normalizeBaseUrl(_apiBaseFromEnv);
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _defaultLanBaseUrl;
    }
    return 'http://127.0.0.1:8000/api';
  }

  static String _normalizeBaseUrl(String rawUrl) {
    final String trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.replaceAll(RegExp(r'\s+'), '');
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$_baseUrl/$path').replace(queryParameters: queryParameters);
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            _uri('login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception(
        'Connection timed out. Check API_BASE_URL and ensure backend is reachable from this device.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Network error: ${e.message}. Check API_BASE_URL and backend server status.',
      );
    }
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login failed');
    }
    return LoginResponse.fromJson(data);
  }

  Future<LandingSummaryData> fetchLandingSummary() async {
    final response = await http.get(_uri('landing-summary/'));
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load landing summary');
    }
    return LandingSummaryData.fromJson(data);
  }

  Future<List<JobItem>> fetchJobs() async {
    final response = await http.get(_uri('jobs/'));
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(JobItem.fromJson)
        .toList(growable: false);
  }

  Future<List<JobItem>> fetchJobsForStudent(int studentId) async {
    final response = await http.get(_uri('jobs/', {'student_id': '$studentId'}));
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(JobItem.fromJson)
        .toList(growable: false);
  }

  Future<String> applyJob({
    required int studentId,
    required int jobId,
  }) async {
    final response = await http.post(
      _uri('apply/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId, 'job_id': jobId}),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? data['message'] ?? 'Failed to apply');
    }
    return data['message'] as String? ?? 'Application submitted';
  }

  Future<List<ApplicationItem>> fetchMyApplications(int studentId) async {
    final response = await http.get(
      _uri('my-applications/', {'student_id': '$studentId'}),
    );
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(ApplicationItem.fromJson)
        .toList(growable: false);
  }

  Future<String> respondToOffer({
    required int studentId,
    required int applicationId,
    required String decision,
  }) async {
    final response = await http.post(
      _uri('my-applications/$applicationId/respond/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId, 'decision': decision}),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to update offer response');
    }
    return data['message'] as String? ?? 'Updated successfully';
  }

  Future<List<BookmarkItem>> fetchBookmarks(int studentId) async {
    final response = await http.get(
      _uri('bookmarks/', {'student_id': '$studentId'}),
    );
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(BookmarkItem.fromJson)
        .toList(growable: false);
  }

  Future<bool> toggleBookmark({
    required int studentId,
    required int jobId,
  }) async {
    final response = await http.post(
      _uri('toggle-bookmark/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId, 'job_id': jobId}),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        data['error'] ?? data['message'] ?? 'Failed to update bookmark',
      );
    }
    return data['bookmarked'] as bool? ?? false;
  }

  Future<StudentDashboardData> fetchStudentDashboard(int studentId) async {
    final response = await http.get(
      _uri('student-dashboard/', {'student_id': '$studentId'}),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load dashboard');
    }
    return StudentDashboardData.fromJson(data);
  }

  Future<UserProfileItem> fetchProfile({
    required String role,
    int? studentId,
    String username = '',
  }) async {
    final Map<String, String> query = <String, String>{'role': role};
    if (role == 'student' && studentId != null) {
      query['student_id'] = '$studentId';
    }
    if (role == 'admin' && username.trim().isNotEmpty) {
      query['username'] = username.trim();
    }
    final response = await http.get(_uri('profile/', query));
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load profile');
    }
    return UserProfileItem.fromJson(data);
  }

  Future<UserProfileItem> updateProfile({
    required String role,
    int? studentId,
    required String name,
    required String email,
    String phone = '',
    String branch = '',
    double? cgpa,
    int? year,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'role': role,
      'name': name,
      'email': email,
    };
    if (role == 'student') {
      body['student_id'] = studentId;
      body['phone'] = phone;
      body['branch'] = branch;
      body['cgpa'] = cgpa;
      body['year'] = year;
    }
    final response = await http.patch(
      _uri('profile/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to save profile');
    }
    return UserProfileItem.fromJson(data);
  }

  Future<AdminDashboardData> fetchAdminDashboard() async {
    final response = await http.get(_uri('admin/dashboard/'));
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load admin dashboard');
    }
    return AdminDashboardData.fromJson(data);
  }

  Future<List<JobItem>> fetchAdminJobs() async {
    final response = await http.get(_uri('admin/jobs/'));
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(JobItem.fromJson)
        .toList(growable: false);
  }

  Future<JobItem> createAdminJob({
    required String title,
    required String company,
    required String location,
    required String description,
    required int packageLpa,
    required String deadline,
  }) async {
    final response = await http.post(
      _uri('admin/jobs/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'company': company,
        'location': location,
        'description': description,
        'package': packageLpa,
        'deadline': deadline,
      }),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 201) {
      throw Exception(
        data['error'] ??
            data.values.join(', ').replaceAll('[', '').replaceAll(']', ''),
      );
    }
    return JobItem.fromJson(data);
  }

  Future<String> deleteAdminJob(int jobId) async {
    final response = await http.delete(_uri('admin/jobs/$jobId/'));
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to delete job');
    }
    return data['message'] as String? ?? 'Job deleted';
  }

  Future<List<AdminApplicantItem>> fetchAdminApplicants({
    String search = '',
  }) async {
    final Map<String, String>? query = search.trim().isEmpty
        ? null
        : {'search': search.trim()};
    final response = await http.get(_uri('admin/applicants/', query));
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminApplicantItem.fromJson)
        .toList(growable: false);
  }

  Future<AdminApplicationDetail> fetchAdminApplicationDetail(
    int applicationId,
  ) async {
    final response = await http.get(_uri('admin/applications/$applicationId/'));
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load applicant profile');
    }
    return AdminApplicationDetail.fromJson(data);
  }

  Future<AdminApplicantItem> updateApplicationStatus({
    required int applicationId,
    required String status,
  }) async {
    final response = await http.patch(
      _uri('admin/applications/$applicationId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to update status');
    }
    return AdminApplicantItem.fromJson(data);
  }

  Future<List<CompanySummaryItem>> fetchCompanySummaries() async {
    final response = await http.get(_uri('admin/companies/'));
    final List<dynamic> data = _decodeJsonArray(response);
    return data
        .whereType<Map<String, dynamic>>()
        .map(CompanySummaryItem.fromJson)
        .toList(growable: false);
  }

  Map<String, dynamic> _decodeJsonObject(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  List<dynamic> _decodeJsonArray(http.Response response) {
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) return decoded;
    return <dynamic>[];
  }
}
