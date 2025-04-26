import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  Attendance? _todayAttendance;
  List<Attendance> _attendanceHistory = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;
  Map<String, dynamic>? _meta;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  List<Attendance> get attendances => _attendanceHistory;
  bool get hasMore => _hasMore;
  Map<String, dynamic>? get meta => _meta;
  bool get hasCheckedIn => _todayAttendance?.checkInTime != null;
  bool get hasCheckedOut => _todayAttendance?.checkOutTime != null;

  Future<void> loadTodayAttendance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAttendanceHistory({
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    if (refresh) {
      _attendanceHistory = [];
      _page = 1;
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _attendanceService.getAttendanceHistory(
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      if (result['success']) {
        if (page == 1 || refresh) {
          _attendanceHistory = result['data'];
        } else {
          _attendanceHistory.addAll(result['data']);
        }

        _meta = result['meta'];
        _hasMore =
            _meta != null && _meta!['current_page'] < _meta!['last_page'];
        _page = page + 1;
      } else {
        _error = result['message'];
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> scanAttendance(String qrCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if the user has already checked in today
      if (_todayAttendance == null || _todayAttendance!.checkInTime == null) {
        // Check in
        final result = await _attendanceService.scanAttendance(
          qrCode: qrCode,
        );

        if (result['success']) {
          _todayAttendance = result['data'];
          return result;
        } else {
          _error = result['message'];
          return result;
        }
      } else {
        // Already checked in and out
        return {
          'success': false,
          'message': 'Terjadi kesalahan. Silakan coba lagi.',
        };
      }
    } catch (e) {
      _error = e.toString();
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // For demo and testing purposes only
  Future<void> fetchAttendances() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, generate some mock data
      final List<Attendance> fetchedAttendances = List.generate(
        10,
        (index) {
          final date = DateTime.now().subtract(Duration(days: index));

          return Attendance(
            id: 'att_${DateTime.now().millisecondsSinceEpoch}_$index',
            userId: 'user_1',
            date: date.toString().split(' ')[0],
            clockIn: date.add(Duration(hours: 8)).toString(),
            clockOut: Random().nextBool()
                ? date.add(Duration(hours: 17)).toString()
                : null,
            status: 'active',
            location: 'Office',
            isLate: Random().nextBool(),
            isEarlyCheckOut: false,
            isAbsent: false,
          );
        },
      );

      _attendanceHistory = fetchedAttendances;
      _page = 1;
      _hasMore = true;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAttendances() async {
    if (_isLoading || !_hasMore) return;
    getAttendanceHistory(page: _page);
  }
}
