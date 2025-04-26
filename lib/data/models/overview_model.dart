import 'user_model.dart';

class UserOverview {
  final User user;
  final AttendanceOverview attendance;
  final LeaveOverview leave;

  UserOverview({
    required this.user,
    required this.attendance,
    required this.leave,
  });

  factory UserOverview.fromJson(Map<String, dynamic> json) {
    return UserOverview(
      user: User.fromJson(json['user'] ?? {}),
      attendance: AttendanceOverview.fromJson(json['attendance'] ?? {}),
      leave: LeaveOverview.fromJson(json['leave'] ?? {}),
    );
  }
}

class AttendanceOverview {
  final int monthlyTotal;
  final String? attendanceMasuk;
  final String? attendanceKeluar;
  final int lateCount;

  AttendanceOverview({
    required this.monthlyTotal,
    required this.attendanceMasuk,
    required this.attendanceKeluar,
    required this.lateCount,
  });

  factory AttendanceOverview.fromJson(Map<String, dynamic> json) {
    return AttendanceOverview(
      monthlyTotal: json['monthlyTotal'] ?? 0,
      attendanceMasuk: json['attendanceMasuk'] ?? '-',
      attendanceKeluar: json['attendanceKeluar'] ?? '-',
      lateCount: json['lateCount'] ?? 0,
    );
  }
}

class LeaveOverview {
  final int pending;
  final LeaveTypeOverview workLeave;
  final LeaveTypeOverview sickLeave;

  LeaveOverview({
    required this.pending,
    required this.workLeave,
    required this.sickLeave,
  });

  factory LeaveOverview.fromJson(Map<String, dynamic> json) {
    return LeaveOverview(
      pending: json['pending'] ?? 0,
      workLeave: LeaveTypeOverview.fromJson(json['workLeave'] ?? {}),
      sickLeave: LeaveTypeOverview.fromJson(json['sickLeave'] ?? {}),
    );
  }
}

class LeaveTypeOverview {
  final int limit;
  final int used;
  final int remaining;

  LeaveTypeOverview({
    required this.limit,
    required this.used,
    required this.remaining,
  });

  factory LeaveTypeOverview.fromJson(Map<String, dynamic> json) {
    return LeaveTypeOverview(
      limit: json['limit'] ?? 0,
      used: json['used'] ?? 0,
      remaining: json['remaining'] ?? 0,
    );
  }
} 