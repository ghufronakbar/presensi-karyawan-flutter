import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../utils/storage_utils.dart';
import '../constants/app_constants.dart';

class ApiConfig {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_authInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    return dio;
  }

  static Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageUtils.getSecureData(AppConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken =
                await StorageUtils.getSecureData(AppConstants.tokenKey);

            if (refreshToken != null && refreshToken.isNotEmpty) {
              // Try to refresh the token
              final response = await Dio()
                  .get('${ApiConstants.baseUrl}${ApiConstants.checkAuth}',
                      options: Options(headers: {
                        'Authorization': 'Bearer $refreshToken',
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                      }));

              if (response.statusCode == 200) {
                final newToken = response.data['data']['token'];

                await StorageUtils.setSecureData(
                    AppConstants.tokenKey, newToken);

                // Retry the original request with new token
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';

                final retryResponse = await _dio!.fetch(options);
                return handler.resolve(retryResponse);
              }
            }

            // If refresh token fails or doesn't exist, clear storage and redirect to login
            await StorageUtils.clearSecureData();
          } catch (e) {
            await StorageUtils.clearSecureData();            
          }
        }
        return handler.next(error);
      },
    );
  }
}
