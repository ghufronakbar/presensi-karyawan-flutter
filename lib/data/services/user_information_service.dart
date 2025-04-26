import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../models/user_information_model.dart';

class UserInformationService {
  final Dio _dio = ApiConfig.dio;

  /// Get user information data
  Future<Map<String, dynamic>> getUserInformation() async {
    try {
      final response = await _dio.get(ApiConstants.userInformation);      

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final informationData = response.data['data'];
        final userInformation = UserInformation.fromJson(informationData);

        return {
          'success': true,
          'data': userInformation,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get user information',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to get user information',
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