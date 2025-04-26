import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/constants.dart';

class NotificationUtils {
  /// Show a toast message
  static void showToast({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_SHORT,
    Color backgroundColor = AppColors.textPrimary,
    Color textColor = AppColors.textOnPrimary,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
  
  /// Show a success toast message
  static void showSuccessToast(String message) {
    showToast(
      message: message,
      backgroundColor: AppColors.success,
      length: Toast.LENGTH_LONG,
    );
  }
  
  /// Show an error toast message
  static void showErrorToast(String message) {
    showToast(
      message: message,
      backgroundColor: AppColors.error,
      length: Toast.LENGTH_LONG,
    );
  }
  
  /// Show an info toast message
  static void showInfoToast(String message) {
    showToast(
      message: message,
      backgroundColor: AppColors.info,
      length: Toast.LENGTH_LONG,
    );
  }
  
  /// Show a warning toast message
  static void showWarningToast(String message) {
    showToast(
      message: message,
      backgroundColor: AppColors.warning,
      textColor: AppColors.textPrimary,
      length: Toast.LENGTH_LONG,
    );
  }
  
  /// Show a snackbar message
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color backgroundColor = AppColors.textPrimary,
    Color textColor = AppColors.textOnPrimary,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Shows a success snackbar with green background
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Shows an error snackbar with red background
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Shows an info snackbar with blue background
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show a warning snackbar message
  static void showWarningSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message: message,
      duration: duration,
      backgroundColor: AppColors.warning,
      textColor: AppColors.textPrimary,
      action: action,
    );
  }
}

enum NotificationType { success, error, info, warning }

void showNotification(
  BuildContext context,
  String message, {
  NotificationType type = NotificationType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  Color backgroundColor;
  Color textColor = Colors.white;
  IconData icon;

  switch (type) {
    case NotificationType.success:
      backgroundColor = Colors.green;
      icon = Icons.check_circle;
      break;
    case NotificationType.error:
      backgroundColor = Colors.red;
      icon = Icons.error;
      break;
    case NotificationType.warning:
      backgroundColor = Colors.orange;
      icon = Icons.warning;
      break;
    case NotificationType.info:
    default:
      backgroundColor = AppColors.primary;
      icon = Icons.info;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
} 