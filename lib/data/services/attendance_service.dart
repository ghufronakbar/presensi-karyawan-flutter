import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final Dio _dio = ApiConfig.dio;

  /// Get attendance history with optional date range
  Future<Map<String, dynamic>> getAttendanceHistory({
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final response = await _dio.get(
        ApiConstants.attendanceHistory,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> attendanceData = response.data['data'];
        final List<Attendance> attendances =
            attendanceData.map((item) => Attendance.fromJson(item)).toList();

        return {
          'success': true,
          'data': attendances,
          'meta': response.data['meta'],
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to get attendance history',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message':
              e.response!.data['message'] ?? 'Failed to get attendance history',
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

  /// Get attendance details by ID
  Future<Map<String, dynamic>> getAttendanceDetails(String id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.attendanceHistory}',
      );

      if (response.statusCode == 200) {
        final attendanceData = response.data['data'];

        final attendance = Attendance.fromJson(attendanceData);

        return {
          'success': true,
          'data': attendance,
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to get attendance details',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message':
              e.response!.data['message'] ?? 'Failed to get attendance details',
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

  /// Check in
  Future<Map<String, dynamic>> scanAttendance({
    required String qrCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.attendanceScan,
        data: {
          'qrCode': qrCode,
        },
      );

      if (response.statusCode == 200) {
        final attendanceData = response.data['data'];
        final attendance = Attendance.fromJson(attendanceData);

        return {
          'success': true,
          'data': attendance,
          'message': response.data['message'] ?? 'Check-in successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Check-in failed',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Check-in failed',
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

  /// Check out
  Future<Map<String, dynamic>> checkOut({
    required String qrCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.attendanceScan,
        data: {
          'qrCode': qrCode,
        },
      );

      if (response.statusCode == 200) {
        final attendanceData = response.data['data'];
        final attendance = Attendance.fromJson(attendanceData);

        return {
          'success': true,
          'data': attendance,
          'message': response.data['message'] ?? 'Check-out successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Check-out failed',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Check-out failed',
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
