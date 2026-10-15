class LeaveBalance {
  final String employeeId;
  final int academicYear;
  final double casualLeaveTotal;
  final double casualLeaveUsed;
  final double medicalLeaveTotal;
  final double medicalLeaveUsed;
  final double onDutyLeaveUsed;
  final double earnedLeaveTotal;
  final double earnedLeaveUsed;
  final double compOffBalance;

  const LeaveBalance({
    required this.employeeId,
    this.academicYear = 2024,
    this.casualLeaveTotal = 12.0,
    this.casualLeaveUsed = 3.0,
    this.medicalLeaveTotal = 10.0,
    this.medicalLeaveUsed = 1.0,
    this.onDutyLeaveUsed = 2.0,
    this.earnedLeaveTotal = 15.0,
    this.earnedLeaveUsed = 0.0,
    this.compOffBalance = 2.0,
  });

  double get casualLeaveRemaining => casualLeaveTotal - casualLeaveUsed;
  double get medicalLeaveRemaining => medicalLeaveTotal - medicalLeaveUsed;
  double get earnedLeaveRemaining => earnedLeaveTotal - earnedLeaveUsed;

  LeaveBalance copyWith({
    String? employeeId,
    int? academicYear,
    double? casualLeaveTotal,
    double? casualLeaveUsed,
    double? medicalLeaveTotal,
    double? medicalLeaveUsed,
    double? onDutyLeaveUsed,
    double? earnedLeaveTotal,
    double? earnedLeaveUsed,
    double? compOffBalance,
  }) {
    return LeaveBalance(
      employeeId: employeeId ?? this.employeeId,
      academicYear: academicYear ?? this.academicYear,
      casualLeaveTotal: casualLeaveTotal ?? this.casualLeaveTotal,
      casualLeaveUsed: casualLeaveUsed ?? this.casualLeaveUsed,
      medicalLeaveTotal: medicalLeaveTotal ?? this.medicalLeaveTotal,
      medicalLeaveUsed: medicalLeaveUsed ?? this.medicalLeaveUsed,
      onDutyLeaveUsed: onDutyLeaveUsed ?? this.onDutyLeaveUsed,
      earnedLeaveTotal: earnedLeaveTotal ?? this.earnedLeaveTotal,
      earnedLeaveUsed: earnedLeaveUsed ?? this.earnedLeaveUsed,
      compOffBalance: compOffBalance ?? this.compOffBalance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'academicYear': academicYear,
      'casualLeaveTotal': casualLeaveTotal,
      'casualLeaveUsed': casualLeaveUsed,
      'medicalLeaveTotal': medicalLeaveTotal,
      'medicalLeaveUsed': medicalLeaveUsed,
      'onDutyLeaveUsed': onDutyLeaveUsed,
      'earnedLeaveTotal': earnedLeaveTotal,
      'earnedLeaveUsed': earnedLeaveUsed,
      'compOffBalance': compOffBalance,
    };
  }

  factory LeaveBalance.fromMap(Map<String, dynamic> map, [String? employeeId]) {
    return LeaveBalance(
      employeeId: employeeId ?? map['employeeId']?.toString() ?? '',
      academicYear: (map['academicYear'] as num?)?.toInt() ?? 2024,
      casualLeaveTotal:
          (map['casualLeaveTotal'] as num?)?.toDouble() ?? 12.0,
      casualLeaveUsed: (map['casualLeaveUsed'] as num?)?.toDouble() ?? 0.0,
      medicalLeaveTotal:
          (map['medicalLeaveTotal'] as num?)?.toDouble() ?? 10.0,
      medicalLeaveUsed: (map['medicalLeaveUsed'] as num?)?.toDouble() ?? 0.0,
      onDutyLeaveUsed: (map['onDutyLeaveUsed'] as num?)?.toDouble() ?? 0.0,
      earnedLeaveTotal:
          (map['earnedLeaveTotal'] as num?)?.toDouble() ?? 15.0,
      earnedLeaveUsed: (map['earnedLeaveUsed'] as num?)?.toDouble() ?? 0.0,
      compOffBalance: (map['compOffBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
