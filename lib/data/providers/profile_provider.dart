import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  ProfileStatus _status = ProfileStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  String? _uploadedImageUrl;
  
  // Getters
  ProfileStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get uploadedImageUrl => _uploadedImageUrl;
  
  Future<void> getUserProfile() async {
    _setLoading(true);
    
    try {
      final result = await _profileService.getUserProfile();
      
      if (result['success']) {
        _user = result['data'];
        _status = ProfileStatus.success;
      } else {
        _status = ProfileStatus.error;
        _errorMessage = result['message'];
      }
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? image,
  }) async {
    _setLoading(true);
    
    try {
      final result = await _profileService.updateProfile(
        name: name,
        email: email,
        image: image ?? _uploadedImageUrl,
        position: _user?.position,
      );
      
      if (result['success']) {
        _user = result['data'];
        _status = ProfileStatus.success;
        _uploadedImageUrl = null; // Clear the uploaded image URL after successful profile update
      } else {
        _status = ProfileStatus.error;
        _errorMessage = result['message'];
      }
      
      return result;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> uploadImage(String filePath) async {
    _setLoading(true);
    
    try {
      final result = await _profileService.uploadImage(filePath);
      
      if (result['success']) {
        _uploadedImageUrl = result['url'];
      } else {
        _errorMessage = result['message'];
      }
      
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    
    try {
      final result = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    _setLoading(true);
    
    try {
      final result = await _profileService.uploadProfilePhoto(filePath);
      
      if (result['success']) {
        _user = result['data'];
        _status = ProfileStatus.success;
      } else {
        _status = ProfileStatus.error;
        _errorMessage = result['message'];
      }
      
      return result;
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
      
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }
  
  void updateUserData(User user) {
    _user = user;
    notifyListeners();
  }

  void setUploadedImageUrl(String url) {
    _uploadedImageUrl = url;
    notifyListeners();
  }

  void clearUploadedImageUrl() {
    _uploadedImageUrl = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 