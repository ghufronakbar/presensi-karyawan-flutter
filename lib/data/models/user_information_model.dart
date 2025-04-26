class UserInformation {
  final String startTime;
  final String endTime;
  final String dismissalTime;
  final int maxWorkLeave;
  final int maxSickLeave;

  UserInformation({
    required this.startTime,
    required this.endTime,
    required this.dismissalTime,
    required this.maxWorkLeave,
    required this.maxSickLeave,
  });

  factory UserInformation.fromJson(Map<String, dynamic> json) {
    return UserInformation(
      startTime: json['startTime'] ?? '07:00',
      endTime: json['endTime'] ?? '08:00',
      dismissalTime: json['dismissalTime'] ?? '15:00',
      maxWorkLeave: json['maxWorkLeave'] ?? 12,
      maxSickLeave: json['maxSickLeave'] ?? 12,
    );
  }
} 