import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../models/attendance_calendar_model.dart';

class AttendanceCalendarService {
  final Dio _dio = ApiConfig.dio;

  Future<Map<String, dynamic>> getAttendanceCalendar() async {
    try {
      final response = await _dio.get(
        ApiConstants.attendanceHistory,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final calendarData = response.data['data'];
        final attendanceCalendar =
            AttendanceCalendarResponse.fromJson(calendarData);

        return {
          'success': true,
          'data': attendanceCalendar,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ??
              'Failed to get attendance calendar data',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ??
              'Failed to get attendance calendar data',
        };
      } else {
        return {
          'success': false,
          'message': 'Connection error. Please check your internet connection.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }
}
