import 'package:flutter/material.dart';
import '../models/overview_model.dart';
import '../services/overview_service.dart';

enum OverviewStatus { initial, loading, success, error }

class OverviewProvider with ChangeNotifier {
  final OverviewService _overviewService = OverviewService();
  
  OverviewStatus _status = OverviewStatus.initial;
  UserOverview? _userOverview;
  String? _errorMessage;
  bool _isLoading = false;
  
  // Getters
  OverviewStatus get status => _status;
  UserOverview? get userOverview => _userOverview;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  
  Future<void> getUserOverview() async {
    if (_isLoading) return;
    
    _setLoading(true);
    
    try {
      final result = await _overviewService.getUserOverview();
      
      if (result['data'] != null) {
        _userOverview = result['data'];
        _status = OverviewStatus.success;
      } else {
        _status = OverviewStatus.error;
        _errorMessage = result['message'];
      }
    } catch (e) {
      _status = OverviewStatus.error;
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