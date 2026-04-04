import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const String _studentIdKey = 'student_id';
  static const String _studentNameKey = 'student_name';
  static const String _userRoleKey = 'user_role';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _lastRouteKey = 'last_route';

  static late SharedPreferences _prefs;

  static int? studentId;
  static String studentName = 'Student';
  static String userRole = '';
  static String username = '';
  static String email = '';
  static String lastRoute = '';

  static bool get isLoggedIn => userRole.isNotEmpty;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final int? storedStudentId = _prefs.getInt(_studentIdKey);
    studentId = storedStudentId == null || storedStudentId < 0
        ? null
        : storedStudentId;
    studentName = _prefs.getString(_studentNameKey) ?? 'Student';
    userRole = _prefs.getString(_userRoleKey) ?? '';
    username = _prefs.getString(_usernameKey) ?? '';
    email = _prefs.getString(_emailKey) ?? '';
    lastRoute = _prefs.getString(_lastRouteKey) ?? '';
  }

  static String get initialRoute {
    if (!isLoggedIn) {
      return '/';
    }
    if (lastRoute.isNotEmpty) {
      return lastRoute;
    }
    return userRole == 'admin' ? '/admin-dashboard' : '/student-dashboard';
  }

  static void setSession({
    int? id,
    required String name,
    required String role,
    String usernameValue = '',
    String emailValue = '',
  }) {
    studentId = id;
    studentName = name;
    userRole = role;
    username = usernameValue;
    email = emailValue;
    lastRoute = role == 'admin' ? '/admin-dashboard' : '/student-dashboard';

    _prefs.setInt(_studentIdKey, id ?? -1);
    _prefs.setString(_studentNameKey, studentName);
    _prefs.setString(_userRoleKey, userRole);
    _prefs.setString(_usernameKey, username);
    _prefs.setString(_emailKey, email);
    _prefs.setString(_lastRouteKey, lastRoute);
  }

  static void updateProfile({
    required String name,
    required String usernameValue,
    required String emailValue,
  }) {
    studentName = name;
    username = usernameValue;
    email = emailValue;

    _prefs.setString(_studentNameKey, studentName);
    _prefs.setString(_usernameKey, username);
    _prefs.setString(_emailKey, email);
  }

  static void rememberRoute(String? routeName) {
    if (!isLoggedIn || routeName == null || routeName.isEmpty) {
      return;
    }
    if (routeName == '/' || routeName == '/login') {
      return;
    }
    lastRoute = routeName;
    _prefs.setString(_lastRouteKey, lastRoute);
  }

  static void clear() {
    studentId = null;
    studentName = 'Student';
    userRole = '';
    username = '';
    email = '';
    lastRoute = '';

    _prefs.remove(_studentIdKey);
    _prefs.remove(_studentNameKey);
    _prefs.remove(_userRoleKey);
    _prefs.remove(_usernameKey);
    _prefs.remove(_emailKey);
    _prefs.remove(_lastRouteKey);
  }
}
