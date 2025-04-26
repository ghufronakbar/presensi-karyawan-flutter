import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';
import '../../utils/notification_utils.dart';

enum LeaveStatus { initial, loading, success, error }

class LeaveProvider with ChangeNotifier {
  final LeaveService _leaveService = LeaveService();
  
  LeaveStatus _status = LeaveStatus.initial;
  List<Leave> _leaves = [];
  Leave? _currentLeave;
  String? _errorMessage;
  bool _isLoading = false;
  Map<String, dynamic>? _meta;
  
  // Getters
  LeaveStatus get status => _status;
  List<Leave> get leaves => _leaves;
  Leave? get currentLeave => _currentLeave;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get meta => _meta;
  
  Future<void> getLeaveHistory({
    String? startDate,
    String? endDate,
    String? status,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (refresh) {
      _leaves = [];
    }
    
    _setLoading(true);
    
    try {
      final result = await _leaveService.getLeaveHistory(
        startDate: startDate,
        endDate: endDate,
        status: status,
        page: page,
        limit: limit,
      );
      
      if (result['success']) {
        if (page == 1 || refresh) {
          _leaves = result['data'];
        } else {
          _leaves.addAll(result['data']);
        }
        
        _meta = result['meta'];
        _status = LeaveStatus.success;                
      } else {
        _status = LeaveStatus.error;
        _errorMessage = result['message'];
        NotificationUtils.showErrorToast(_errorMessage ?? 'Failed to get leave history');
      }
    } catch (e) {
      _status = LeaveStatus.error;
      _errorMessage = e.toString();
      NotificationUtils.showErrorToast(_errorMessage ?? 'Failed to get leave history');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Leave?> getLeaveDetails(String id) async {
    _setLoading(true);
    
    try {
      final result = await _leaveService.getLeaveDetails(id);
      
      if (result['success']) {
        _currentLeave = result['data'];
        return _currentLeave;
      } else {
        _errorMessage = result['message'];
        NotificationUtils.showErrorToast(_errorMessage ?? 'Failed to get leave details');
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      NotificationUtils.showErrorToast(_errorMessage ?? 'Failed to get leave details');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Map<String, dynamic>> requestLeave({
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
    String? attachment,
  }) async {
    _setLoading(true);
    
    try {
      final result = await _leaveService.requestLeave(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        attachment: attachment,
      );
      
      if (result['success']) {
        // Add the new leave to the list
        final newLeave = result['data'];
        _leaves.insert(0, newLeave);
        notifyListeners();
        
        if (result['message'] != null) {
          NotificationUtils.showSuccessToast(result['message']);
        }
      } else {
        NotificationUtils.showErrorToast(result['message'] ?? 'Failed to submit leave request');
      }
      
      return result;
    } catch (e) {
      final errorMessage = e.toString();
      NotificationUtils.showErrorToast(errorMessage);
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Map<String, dynamic>> cancelLeaveRequest(String id) async {
    _setLoading(true);
    
    try {
      final result = await _leaveService.cancelLeaveRequest(id);
      
      if (result['success']) {
        // Update status of the leave to canceled
        final index = _leaves.indexWhere((leave) => leave.id == id);
        
        if (index != -1) {
          final updatedLeave = _leaves[index].copyWith(status: 'Canceled');
          _leaves[index] = updatedLeave;
          
          if (_currentLeave?.id == id) {
            _currentLeave = updatedLeave;
          }
          
          notifyListeners();
        }
        
        if (result['message'] != null) {
          NotificationUtils.showSuccessToast(result['message']);
        }
      } else {
        NotificationUtils.showErrorToast(result['message'] ?? 'Failed to cancel leave request');
      }
      
      return result;
    } catch (e) {
      final errorMessage = e.toString();
      NotificationUtils.showErrorToast(errorMessage);
      
      return {
        'success': false,
        'message': errorMessage,
      };
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