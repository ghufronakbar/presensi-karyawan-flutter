class Attendance {
  final String id;
  final String userId;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInNote;
  final String? checkOutNote;
  final String status;
  final bool isLate;
  final bool isEarlyCheckOut;
  final bool isAbsent;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInNote,
    this.checkOutNote,
    required this.status,
    required this.isLate,
    required this.isEarlyCheckOut,
    required this.isAbsent,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      checkInNote: json['check_in_note'],
      checkOutNote: json['check_out_note'],
      status: json['status'],
      isLate: json['is_late'] ?? false,
      isEarlyCheckOut: json['is_early_check_out'] ?? false,
      isAbsent: json['is_absent'] ?? false,
      note: json['note'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['date'] = date;
    if (checkInTime != null) data['check_in_time'] = checkInTime;
    if (checkOutTime != null) data['check_out_time'] = checkOutTime;
    if (checkInLocation != null) data['check_in_location'] = checkInLocation;
    if (checkOutLocation != null) data['check_out_location'] = checkOutLocation;
    if (checkInNote != null) data['check_in_note'] = checkInNote;
    if (checkOutNote != null) data['check_out_note'] = checkOutNote;
    data['status'] = status;
    data['is_late'] = isLate;
    data['is_early_check_out'] = isEarlyCheckOut;
    data['is_absent'] = isAbsent;
    if (note != null) data['note'] = note;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    return data;
  }

  Attendance copyWith({
    String? id,
    String? userId,
    String? date,
    String? checkInTime,
    String? checkOutTime,
    String? checkInLocation,
    String? checkOutLocation,
    String? checkInNote,
    String? checkOutNote,
    String? status,
    bool? isLate,
    bool? isEarlyCheckOut,
    bool? isAbsent,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      checkInNote: checkInNote ?? this.checkInNote,
      checkOutNote: checkOutNote ?? this.checkOutNote,
      status: status ?? this.status,
      isLate: isLate ?? this.isLate,
      isEarlyCheckOut: isEarlyCheckOut ?? this.isEarlyCheckOut,
      isAbsent: isAbsent ?? this.isAbsent,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 