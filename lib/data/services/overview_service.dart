import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../models/overview_model.dart';

class OverviewService {
  final Dio _dio = ApiConfig.dio;

  /// Get user overview data
  Future<Map<String, dynamic>> getUserOverview() async {
    try {
      final response = await _dio.get(ApiConstants.overview);
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final overviewData = response.data['data'];
        print("overview data from overview service : ${overviewData}");
        final userOverview = UserOverview.fromJson(overviewData);

        return {
          'success': true,
          'data': userOverview,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get overview data',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to get overview data',
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