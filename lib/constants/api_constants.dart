class ApiConstants {
  // Base URL
  static const String baseUrl =
      'https://presensi-harta-samudera-ambon.vercel.app/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String checkAuth = '/auth/check';  

  // Attendance endpoints
  static const String attendanceHistory = '/user/attendance';  
  static const String attendanceScan = '/user/attendance';

  // Leave endpoints
  static const String leaveRequest = '/user/leave';
  static const String leaveHistory = '/user/leave';
  static const String leaveDetails = '/user/leave';
  static const String leaveCancel = '/user/leave/cancel';

  // Profile endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/profile';

  // Overview endpoint
  static const String overview = '/user/overview';

  // User information endpoint
  static const String userInformation = '/user/information';

  // Image endpoints
  static const String uploadImage = '/image';
}
