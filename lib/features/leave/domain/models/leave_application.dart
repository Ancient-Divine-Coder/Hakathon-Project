enum LeaveType {
  casual,
  medical,
  onDuty,
  earned,
  compensatory,
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.casual:
        return 'Casual Leave (CL)';
      case LeaveType.medical:
        return 'Medical / Sick Leave (ML)';
      case LeaveType.onDuty:
        return 'On Duty (OD)';
      case LeaveType.earned:
        return 'Earned Leave (EL)';
      case LeaveType.compensatory:
        return 'Compensatory Off (CO)';
    }
  }

  String get shortCode {
    switch (this) {
      case LeaveType.casual:
        return 'CL';
      case LeaveType.medical:
        return 'ML';
      case LeaveType.onDuty:
        return 'OD';
      case LeaveType.earned:
        return 'EL';
      case LeaveType.compensatory:
        return 'CO';
    }
  }
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

extension LeaveStatusExtension on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending Approval';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class LeaveApplication {
  final String id;
  final String employeeId;
  final String applicantName;
  final String department;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDays;
  final String reason;
  final LeaveStatus status;
  final DateTime appliedAt;
  final String? approvedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? attachmentUrl;

  const LeaveApplication({
    required this.id,
    required this.employeeId,
    required this.applicantName,
    required this.department,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = LeaveStatus.pending,
    required this.appliedAt,
    this.approvedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.attachmentUrl,
  });

  LeaveApplication copyWith({
    String? id,
    String? employeeId,
    String? applicantName,
    String? department,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    double? totalDays,
    String? reason,
    LeaveStatus? status,
    DateTime? appliedAt,
    String? approvedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    String? attachmentUrl,
  }) {
    return LeaveApplication(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      applicantName: applicantName ?? this.applicantName,
      department: department ?? this.department,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'applicantName': applicantName,
      'department': department,
      'leaveType': leaveType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'approvedBy': approvedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory LeaveApplication.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime parsedStart = DateTime.now();
    DateTime parsedEnd = DateTime.now();
    DateTime parsedApplied = DateTime.now();
    DateTime? parsedReviewed;

    if (map['startDate'] != null) {
      parsedStart =
          DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now();
    }
    if (map['endDate'] != null) {
      parsedEnd =
          DateTime.tryParse(map['endDate'].toString()) ?? DateTime.now();
    }
    if (map['appliedAt'] != null) {
      parsedApplied =
          DateTime.tryParse(map['appliedAt'].toString()) ?? DateTime.now();
    }
    if (map['reviewedAt'] != null) {
      parsedReviewed = DateTime.tryParse(map['reviewedAt'].toString());
    }

    return LeaveApplication(
      id: id ?? map['id']?.toString() ?? '',
      employeeId: map['employeeId']?.toString() ?? '',
      applicantName: map['applicantName']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == map['leaveType'],
        orElse: () => LeaveType.casual,
      ),
      startDate: parsedStart,
      endDate: parsedEnd,
      totalDays: (map['totalDays'] as num?)?.toDouble() ?? 1.0,
      reason: map['reason']?.toString() ?? '',
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LeaveStatus.pending,
      ),
      appliedAt: parsedApplied,
      approvedBy: map['approvedBy']?.toString(),
      reviewedAt: parsedReviewed,
      rejectionReason: map['rejectionReason']?.toString(),
      attachmentUrl: map['attachmentUrl']?.toString(),
    );
  }
}
