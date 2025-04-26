import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../constants/api_constants.dart';
import '../../utils/storage_utils.dart';
import '../../constants/app_constants.dart';
import '../models/user_model.dart';

class ProfileService {
  final Dio _dio = ApiConfig.dio;

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final userData = response.data['data'];
        final user = User.fromJson(userData);

        // Update user data in storage
        await StorageUtils.setObjectData(AppConstants.idKey, user.id);
        await StorageUtils.setObjectData(AppConstants.nameKey, user.name);
        await StorageUtils.setObjectData(AppConstants.emailKey, user.email);
        await StorageUtils.setObjectData(AppConstants.roleKey, user.role);
        await StorageUtils.setObjectData(AppConstants.imageKey, user.image ?? '');
        await StorageUtils.setObjectData(AppConstants.staffNumberKey, user.staffNumber);
        await StorageUtils.setObjectData(AppConstants.positionKey, user.position);

        return {
          'success': true,
          'data': user,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get user profile',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to get user profile',
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

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? image,
    String? position,
  }) async {
    try {
      Map<String, dynamic> data = {
        'name': name,
        'email': email,
      };

      if (image != null) data['image'] = image;
      if (position != null) data['position'] = position;

      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data['data'];
        final user = User.fromJson(userData);

        // Update user data in storage
        await StorageUtils.setObjectData(AppConstants.idKey, user.id);
        await StorageUtils.setObjectData(AppConstants.nameKey, user.name);
        await StorageUtils.setObjectData(AppConstants.emailKey, user.email);
        await StorageUtils.setObjectData(AppConstants.roleKey, user.role);
        await StorageUtils.setObjectData(AppConstants.imageKey, user.image ?? '');
        await StorageUtils.setObjectData(AppConstants.staffNumberKey, user.staffNumber);
        await StorageUtils.setObjectData(AppConstants.positionKey, user.position);

        return {
          'success': true,
          'data': user,
          'message': response.data['message'] ?? 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update profile',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to update profile',
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

  /// Upload image
  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      
      FormData formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.uploadImage,
        data: formData,
      );

      if (response.statusCode == 200) {
        final imageUrl = response.data['data']['url'];
        
        return {
          'success': true,
          'url': imageUrl,
          'message': response.data['message'] ?? 'Image uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to upload image',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to upload image',
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

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to change password',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to change password',
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

  /// Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.uploadImage,
        data: formData,
      );

      if (response.statusCode == 200) {
        final userData = response.data['data'];
        final user = User.fromJson(userData);

        // Update user data in storage
        await StorageUtils.setObjectData(AppConstants.idKey, user.id);
        await StorageUtils.setObjectData(AppConstants.nameKey, user.name);
        await StorageUtils.setObjectData(AppConstants.emailKey, user.email);
        await StorageUtils.setObjectData(AppConstants.roleKey, user.role);
        await StorageUtils.setObjectData(AppConstants.imageKey, user.image ?? '');
        await StorageUtils.setObjectData(AppConstants.staffNumberKey, user.staffNumber);
        await StorageUtils.setObjectData(AppConstants.positionKey, user.position);

        return {
          'success': true,
          'data': user,
          'message': response.data['message'] ?? 'Profile photo uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to upload profile photo',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response!.data['message'] ?? 'Failed to upload profile photo',
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