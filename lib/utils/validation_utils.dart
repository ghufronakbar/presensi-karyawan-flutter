import '../constants/app_constants.dart';

class ValidationUtils {
  /// Validate email with regex
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(value)) {
      return 'Email tidak valid';
    }
    
    return null;
  }
  
  /// Validate password with minimum length
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password minimal ${AppConstants.minPasswordLength} karakter';
    }
    
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password maksimal ${AppConstants.maxPasswordLength} karakter';
    }
    
    return null;
  }
  
  /// Validate confirm password matching
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Konfirmasi password tidak sama';
    }
    
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    return null;
  }
  
  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    final phonePattern = RegExp(r'^[0-9]{10,13}$');
    if (!phonePattern.hasMatch(value)) {
      return 'Nomor telepon tidak valid';
    }
    
    return null;
  }
  
  /// Validate number
  static String? validateNumber(String? value, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    final numberPattern = RegExp(r'^[0-9]+$');
    if (!numberPattern.hasMatch(value)) {
      return '$fieldName harus berupa angka';
    }
    
    return null;
  }
  
  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    
    return null;
  }
  
  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, [String fieldName = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    
    return null;
  }
  
  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    final namePattern = RegExp(r'^[a-zA-Z\s]+$');
    if (!namePattern.hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf dan spasi';
    }
    
    return null;
  }
  
  /// Validate date format (dd/MM/yyyy)
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal tidak boleh kosong';
    }
    
    final datePattern = RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/\d{4}$');
    if (!datePattern.hasMatch(value)) {
      return 'Format tanggal tidak valid (dd/MM/yyyy)';
    }
    
    // Check for valid date (e.g., not 31/02/2023)
    final parts = value.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
      if (day > (isLeapYear ? 29 : 28)) {
        return 'Tanggal tidak valid untuk bulan yang dipilih';
      }
    } else if ([4, 6, 9, 11].contains(month) && day > 30) {
      return 'Tanggal tidak valid untuk bulan yang dipilih';
    }
    
    return null;
  }
  
  /// Validate file size
  static String? validateFileSize(int fileSize, int maxSize, [String fieldName = 'File']) {
    if (fileSize > maxSize) {
      final sizeInMB = maxSize / (1024 * 1024);
      return '$fieldName tidak boleh lebih dari ${sizeInMB.toStringAsFixed(0)} MB';
    }
    
    return null;
  }
} 