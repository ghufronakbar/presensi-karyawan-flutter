import 'package:flutter/material.dart';

class AttendanceCalendarResponse {
  final List<AttendanceRecord> masuk;
  final List<AttendanceRecord> keluar;

  AttendanceCalendarResponse({
    required this.masuk,
    required this.keluar,
  });

  factory AttendanceCalendarResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarResponse(
      masuk: (json['masuk'] as List?)
              ?.map((e) => AttendanceRecord.fromJson(e))
              .toList() ??
          [],
      keluar: (json['keluar'] as List?)
              ?.map((e) => AttendanceRecord.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime time;
  final String type;
  final String status;
  final int lateTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? attachment;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.time,
    required this.type,
    required this.status,
    required this.lateTime,
    required this.createdAt,
    required this.updatedAt,
    this.attachment,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      lateTime: json['lateTime'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      attachment: json['attachment'],
    );
  }

  // Get color based on status
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'telat':
        return Colors.orange;
      case 'ijin':
        return Colors.blue;
      case 'sakit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get text to display on calendar
  String getCalendarText() {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return '$timeStr\n${status.toUpperCase()}';
  }
}

enum AttendanceType {
  masuk,
  keluar,
}

extension AttendanceTypeExtension on AttendanceType {
  String get label {
    switch (this) {
      case AttendanceType.masuk:
        return 'Masuk';
      case AttendanceType.keluar:
        return 'Keluar';
    }
  }
} 