import 'package:flutter/material.dart';
import 'package:presensi_karyawan/ui/screens/change_password/change_password_screen.dart';
import 'package:presensi_karyawan/ui/screens/profile/edit_profile_screen.dart';
import '../ui/screens/login/login_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/leave_history/leave_history_screen.dart';
import '../ui/screens/leave_details/leave_details_screen.dart';
import '../ui/screens/leave_form/leave_form_screen.dart';
import '../ui/screens/scan_attendance/scan_attendance_screen.dart';
import '../ui/screens/attendance_calendar/attendance_calendar_screen.dart';

class Routes {
  // Route names
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String editProfile = '/edit-profile';
  static const String attendanceCalendar = '/attendance-calendar';
  static const String leaveHistory = '/leave-history';
  static const String leaveDetails = '/leave-details';
  static const String leaveForm = '/leave-form';
  static const String scanAttendance = '/scan-attendance';
  static const String attendanceSuccess = '/attendance-success';

  // Initial route
  static const String initialRoute = login;

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case attendanceCalendar:
        return MaterialPageRoute(
            builder: (_) => const AttendanceCalendarScreen());
      case leaveHistory:
        return MaterialPageRoute(builder: (_) => const LeaveHistoryScreen());
      case leaveDetails:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        final String leaveId = args['leaveId'] as String;
        return MaterialPageRoute(
            builder: (_) => LeaveDetailsScreen(leaveId: leaveId));
      case leaveForm:
        return MaterialPageRoute(builder: (_) => const LeaveFormScreen());
      case scanAttendance:
        return MaterialPageRoute(builder: (_) => const ScanAttendanceScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
