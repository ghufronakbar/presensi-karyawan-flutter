import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../utils/notification_utils.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  
  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  AuthProvider() {
    _init();
  }
  
  Future<void> _init() async {
    _setLoading(true);
    
    try {
      final bool isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
        
        if (_user != null) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _status = AuthStatus.loading;
    
    try {
      final result = await _authService.login(email, password);
      if (result['success']) {
        _user = result['user'];
        _status = AuthStatus.authenticated;
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> logout() async {
    _setLoading(true);
    
    try {
      final result = await _authService.logout();
      
      _user = null;
      _status = AuthStatus.unauthenticated;
      
      return result['success'];
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> refreshUserData() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Handle error silently
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