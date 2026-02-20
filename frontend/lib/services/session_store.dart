class SessionStore {
  static int? studentId;
  static String studentName = 'Student';
  static String userRole = '';

  static bool get isLoggedIn => userRole.isNotEmpty;

  static void setSession({
    int? id,
    required String name,
    required String role,
  }) {
    studentId = id;
    studentName = name;
    userRole = role;
  }

  static void clear() {
    studentId = null;
    studentName = 'Student';
    userRole = '';
  }
}
