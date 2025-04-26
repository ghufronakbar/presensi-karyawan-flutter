class Attendance {
  final String id;
  final String? userId;
  final String date;
  final String? clockIn;
  final String? clockOut;
  final String status; // 'active', 'completed'
  final String location;
  final bool isLate;
  final bool isEarlyCheckOut;
  final bool isAbsent;

  Attendance({
    required this.id,
    this.userId,
    required this.date,
    required this.clockIn,
    this.clockOut,
    required this.status,
    required this.location,
    this.isLate = false,
    this.isEarlyCheckOut = false,
    this.isAbsent = false,
  });

  String? get checkInTime => clockIn;
  String? get checkOutTime => clockOut;

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      status: json['status'],
      location: json['location'] ?? '',
      isLate: json['is_late'] ?? false,
      isEarlyCheckOut: json['is_early_check_out'] ?? false,
      isAbsent: json['is_absent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'status': status,
      'location': location,
      'is_late': isLate,
      'is_early_check_out': isEarlyCheckOut,
      'is_absent': isAbsent,
    };
  }
} 