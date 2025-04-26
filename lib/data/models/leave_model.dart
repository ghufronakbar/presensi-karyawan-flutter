class Leave {
  final String id;
  final String userId;
  final String type;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectionReason;
  final String? attachment;
  final int durationDays;
  final String? createdAt;
  final String? updatedAt;

  Leave({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.attachment,
    required this.durationDays,
    this.createdAt,
    this.updatedAt,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    // Handle both API formats (from README and current implementation)
    final String type = json['type'] ?? '';
    
    // Handle different date formats
    String startDate = json['start_date'] ?? json['date'] ?? '';
    String endDate = json['end_date'] ?? json['date'] ?? '';
    
    // Handle duration calculation if not provided
    int durationDays = json['duration_days'] ?? 1;
    
    return Leave(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? '',
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      approvedBy: json['approved_by'] ?? json['approvedBy'],
      approvedAt: json['approved_at'] ?? json['approvedAt'],
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      attachment: json['attachment'],
      durationDays: durationDays,
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['type'] = type;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['reason'] = reason;
    data['status'] = status;
    if (approvedBy != null) data['approved_by'] = approvedBy;
    if (approvedAt != null) data['approved_at'] = approvedAt;
    if (rejectionReason != null) data['rejection_reason'] = rejectionReason;
    if (attachment != null) data['attachment'] = attachment;
    data['duration_days'] = durationDays;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    return data;
  }

  Leave copyWith({
    String? id,
    String? userId,
    String? type,
    String? startDate,
    String? endDate,
    String? reason,
    String? status,
    String? approvedBy,
    String? approvedAt,
    String? rejectionReason,
    String? attachment,
    int? durationDays,
    String? createdAt,
    String? updatedAt,
  }) {
    return Leave(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachment: attachment ?? this.attachment,
      durationDays: durationDays ?? this.durationDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 