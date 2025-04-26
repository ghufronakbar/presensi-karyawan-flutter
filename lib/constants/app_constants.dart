class AppConstants {
  // App information
  static const String appName = 'Presensi Harta Samudera Ambon';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String idKey = 'id';
  static const String nameKey = 'name';
  static const String emailKey = 'email';
  static const String roleKey = 'role';
  static const String imageKey = 'image';
  static const String staffNumberKey = 'staff_number';
  static const String positionKey = 'position';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Durations
  static const int splashDuration = 2000; // milliseconds
  static const int animationDuration = 300; // milliseconds
  static const int toastDuration = 3000; // milliseconds
  static const int sessionTimeout = 3600; // seconds (1 hour)

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int otpLength = 6;

  // File size limits
  static const int maxProfilePhotoSize = 2 * 1024 * 1024; // 2MB
  static const int maxAttachmentSize = 5 * 1024 * 1024; // 5MB

  // Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';

  // Messages
  static const String genericErrorMessage =
      'Terjadi kesalahan. Silakan coba lagi.';
  static const String networkErrorMessage = 'Koneksi internet tidak tersedia.';
  static const String sessionExpiredMessage =
      'Sesi Anda telah berakhir. Silakan login kembali.';

  // Other
  static const List<String> supportedLanguages = ['id', 'en'];
}
