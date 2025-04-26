import 'package:flutter/material.dart';
import '../models/user_information_model.dart';
import '../services/user_information_service.dart';

enum UserInfoStatus { initial, loading, success, error }

class UserInformationProvider with ChangeNotifier {
  final UserInformationService _informationService = UserInformationService();
  
  UserInfoStatus _status = UserInfoStatus.initial;
  UserInformation? _userInformation;
  String? _errorMessage;
  bool _isLoading = false;
  
  // Getters
  UserInfoStatus get status => _status;
  UserInformation? get userInformation => _userInformation;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  
  Future<void> getUserInformation() async {
    if (_isLoading) return;
    
    _setLoading(true);
    
    try {
      final result = await _informationService.getUserInformation();            
      if (result['data'] != null) {
        _userInformation = result['data'];        
        _status = UserInfoStatus.success;
      } else {
        _status = UserInfoStatus.error;
        _errorMessage = result['message'];
      }
    } catch (e) {
      _status = UserInfoStatus.error;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
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