import 'package:flutter/material.dart';
import '../models/attendance_calendar_model.dart';
import '../services/attendance_calendar_service.dart';

class AttendanceCalendarProvider with ChangeNotifier {
  final AttendanceCalendarService _calendarService =
      AttendanceCalendarService();

  bool _isLoading = false;
  String? _errorMessage;
  AttendanceCalendarResponse? _calendarData;
  AttendanceType _currentType = AttendanceType.masuk;
  DateTime _currentMonth = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AttendanceCalendarResponse? get calendarData => _calendarData;
  AttendanceType get currentType => _currentType;
  DateTime get currentMonth => _currentMonth;

  // Get the current displayed records based on selected type
  List<AttendanceRecord> get currentRecords {
    if (_calendarData == null) return [];

    return _currentType == AttendanceType.masuk
        ? _calendarData!.masuk
        : _calendarData!.keluar;
  }

  // Method to change the selected attendance type
  void setAttendanceType(AttendanceType type) {
    _currentType = type;
    notifyListeners();
  }

  // Method to set the current month
  void setCurrentMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month, 1);
    getAttendanceCalendar();
  }

  // Method to navigate to next month
  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    getAttendanceCalendar();
  }

  // Method to navigate to previous month
  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    getAttendanceCalendar();
  }

  // Get attendance calendar data for the current month and year
  Future<void> getAttendanceCalendar() async {
    _setLoading(true);

    try {
      final result = await _calendarService.getAttendanceCalendar();      

      if (result['data'] != null) {
        _calendarData = result['data'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Get records for a specific day
  List<AttendanceRecord> getRecordsForDay(DateTime day) {
    if (_calendarData == null) return [];

    final records = _currentType == AttendanceType.masuk
        ? _calendarData!.masuk
        : _calendarData!.keluar;

    return records
        .where((record) =>
            record.time.year == day.year &&
            record.time.month == day.month &&
            record.time.day == day.day)
        .toList();
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
