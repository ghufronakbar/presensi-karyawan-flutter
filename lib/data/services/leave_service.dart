import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../models/leave_model.dart';

class LeaveService {
  final Dio _dio = ApiConfig.dio;

  /// Get leave history with optional date range
  Future<Map<String, dynamic>> getLeaveHistory({
    String? startDate,
    String? endDate,
    String? status,
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

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        ApiConstants.leaveHistory,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> leaveData = response.data['data'];
        final List<Leave> leaves = leaveData
            .map((item) => Leave.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': leaves,
          'meta': response.data['meta'] ?? {
            'current_page': 1,
            'last_page': 1,
            'total': leaves.length,
          },
          'message': response.data['message'] ?? 'Leaves fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get leave history',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to get leave history',
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

  /// Get leave details by ID
  Future<Map<String, dynamic>> getLeaveDetails(String id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.leaveDetails}/$id',
      );

      if (response.statusCode == 200) {
        final leaveData = response.data['data'];
        final leave = Leave.fromJson(leaveData);

        return {
          'success': true,
          'data': leave,
          'message': response.data['message'] ?? 'Leave details fetched successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get leave details',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to get leave details',
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

  /// Request leave
  Future<Map<String, dynamic>> requestLeave({
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachment,
  }) async {
    try {
      Map<String, dynamic> data = {
        'type': type,
        'reason': reason,
        'date': startDate,
      };

      if (attachment != null) {
        data['attachment'] = attachment;
      }

      final response = await _dio.post(
        ApiConstants.leaveRequest,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final leaveData = response.data['data'];
        final leave = Leave.fromJson(leaveData);

        return {
          'success': true,
          'data': leave,
          'message': response.data['message'] ?? 'Leave request submitted',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit leave request',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to submit leave request',
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

  /// Cancel leave request
  Future<Map<String, dynamic>> cancelLeaveRequest(String id) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.leaveCancel}/$id',
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Leave request canceled',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to cancel leave request',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to cancel leave request',
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