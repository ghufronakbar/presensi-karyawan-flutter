import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../../utils/storage_utils.dart';
import '../../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiConfig.dio;

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['data']['token'];
        final userData = response.data['data'];

        // Save tokens and user data
        await StorageUtils.setSecureData(
            AppConstants.tokenKey, token.toString());
        await StorageUtils.setSecureData(
            AppConstants.idKey, userData['id'].toString());
        await StorageUtils.setObjectData(
            AppConstants.nameKey, userData['name'].toString());
        await StorageUtils.setObjectData(
            AppConstants.emailKey, userData['email'].toString());
        await StorageUtils.setObjectData(
            AppConstants.roleKey, userData['role'].toString());
        await StorageUtils.setObjectData(
            AppConstants.imageKey, userData['image'].toString());
        await StorageUtils.setObjectData(
            AppConstants.staffNumberKey, userData['staffNumber'].toString());
        await StorageUtils.setObjectData(
            AppConstants.positionKey, userData['position'].toString());

        return {
          'success': true,
          'user': User.fromJson(userData),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Login failed',
        };
      } else {
        return {
          'success': false,
          'message': 'Connection error. Please check your internet connection.',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again later.',
      };
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      // Clear tokens and user data
      await StorageUtils.clearSecureData();
      await StorageUtils.clearData();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      // Even if logout API fails, clear local data
      await StorageUtils.clearSecureData();
      await StorageUtils.clearData();

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final id = await StorageUtils.getObjectData(AppConstants.idKey);
      final name = await StorageUtils.getObjectData(AppConstants.nameKey);
      final email = await StorageUtils.getObjectData(AppConstants.emailKey);
      final role = await StorageUtils.getObjectData(AppConstants.roleKey);
      final image = await StorageUtils.getObjectData(AppConstants.imageKey);
      final staffNumber =
          await StorageUtils.getObjectData(AppConstants.staffNumberKey);
      final position =
          await StorageUtils.getObjectData(AppConstants.positionKey);
      if (name != null &&
          email != null &&
          role != null &&
          image != null &&
          staffNumber != null &&
          position != null) {
        return User(
          id: id.toString(),
          name: name.toString(),
          email: email.toString(),
          role: role.toString(),
          image: image.toString(),
          staffNumber: staffNumber.toString(),
          position: position.toString(),
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn =
          await StorageUtils.getSecureData(AppConstants.tokenKey);
      return isLoggedIn != null;
    } catch (e) {
      return false;
    }
  }

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken =
          await StorageUtils.getSecureData(AppConstants.tokenKey);

      if (refreshToken == null) {
        return {
          'success': false,
          'message': 'No refresh token found',
        };
      }

      final response = await _dio.get(
        ApiConstants.checkAuth,
        options: Options(headers: {
          'Authorization': 'Bearer $refreshToken',
        }),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];

        await StorageUtils.setSecureData(AppConstants.tokenKey, newToken);
        await StorageUtils.setSecureData(AppConstants.tokenKey, newToken);

        return {
          'success': true,
          'token': newToken,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Token refresh failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Token refresh failed',
      };
    }
  }
}
