import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/api_models.dart';

class ApiService {
  const ApiService();

  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$_baseUrl/$path').replace(queryParameters: queryParameters);
  }

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      _uri('login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final Map<String, dynamic> data = _decodeJsonObject(response);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login failed');
    }
    return LoginResponse.fromJson(data);
  }

  Future<List<JobItem>> fetchJobs() async {
    final response = await http.get(_uri('jobs/'));
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
