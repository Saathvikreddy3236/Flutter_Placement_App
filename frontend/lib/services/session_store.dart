class SessionStore {
  static int? studentId;
  static String studentName = 'Student';
  static String userRole = '';
  static String username = '';
  static String email = '';

  static bool get isLoggedIn => userRole.isNotEmpty;

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
  }

  static void updateProfile({
    required String name,
    required String usernameValue,
    required String emailValue,
  }) {
    studentName = name;
    username = usernameValue;
    email = emailValue;
  }

  static void clear() {
    studentId = null;
    studentName = 'Student';
    userRole = '';
    username = '';
    email = '';
  }
}
