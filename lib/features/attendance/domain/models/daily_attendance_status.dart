enum DutyStatus {
  onDuty,
  completed,
  absent,
  onLeave,
}

class DailyAttendanceStatus {
  final String date;
  final DutyStatus status;
  final String checkInTime;
  final String expectedCheckOutTime;
  final String? actualCheckOutTime;
  final bool isOnTime;
  final String turnstileGate;
  final bool isSynced;
  final double shiftProgressPercentage;
  final String dutyHoursCompleted;
  final String dutyHoursRequired;

  const DailyAttendanceStatus({
    required this.date,
    this.status = DutyStatus.onDuty,
    this.checkInTime = '08:55 AM',
    this.expectedCheckOutTime = '04:30 PM',
    this.actualCheckOutTime,
    this.isOnTime = true,
    this.turnstileGate = 'Gate A-12 Turnstile',
    this.isSynced = true,
    this.shiftProgressPercentage = 0.438,
    this.dutyHoursCompleted = '3.5 Hrs',
    this.dutyHoursRequired = '8.0 Hrs',
  });

  DailyAttendanceStatus copyWith({
    String? date,
    DutyStatus? status,
    String? checkInTime,
    String? expectedCheckOutTime,
    String? actualCheckOutTime,
    bool? isOnTime,
    String? turnstileGate,
    bool? isSynced,
    double? shiftProgressPercentage,
    String? dutyHoursCompleted,
    String? dutyHoursRequired,
  }) {
    return DailyAttendanceStatus(
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      expectedCheckOutTime: expectedCheckOutTime ?? this.expectedCheckOutTime,
      actualCheckOutTime: actualCheckOutTime ?? this.actualCheckOutTime,
      isOnTime: isOnTime ?? this.isOnTime,
      turnstileGate: turnstileGate ?? this.turnstileGate,
      isSynced: isSynced ?? this.isSynced,
      shiftProgressPercentage:
          shiftProgressPercentage ?? this.shiftProgressPercentage,
      dutyHoursCompleted: dutyHoursCompleted ?? this.dutyHoursCompleted,
      dutyHoursRequired: dutyHoursRequired ?? this.dutyHoursRequired,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'status': status.name,
      'checkInTime': checkInTime,
      'expectedCheckOutTime': expectedCheckOutTime,
      'actualCheckOutTime': actualCheckOutTime,
      'isOnTime': isOnTime,
      'turnstileGate': turnstileGate,
      'isSynced': isSynced,
      'shiftProgressPercentage': shiftProgressPercentage,
      'dutyHoursCompleted': dutyHoursCompleted,
      'dutyHoursRequired': dutyHoursRequired,
    };
  }

  factory DailyAttendanceStatus.fromMap(Map<String, dynamic> map) {
    return DailyAttendanceStatus(
      date: map['date']?.toString() ?? '',
      status: DutyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DutyStatus.onDuty,
      ),
      checkInTime: map['checkInTime']?.toString() ?? '08:55 AM',
      expectedCheckOutTime:
          map['expectedCheckOutTime']?.toString() ?? '04:30 PM',
      actualCheckOutTime: map['actualCheckOutTime']?.toString(),
      isOnTime: map['isOnTime'] as bool? ?? true,
      turnstileGate: map['turnstileGate']?.toString() ?? 'Gate A-12 Turnstile',
      isSynced: map['isSynced'] as bool? ?? true,
      shiftProgressPercentage:
          (map['shiftProgressPercentage'] as num?)?.toDouble() ?? 0.0,
      dutyHoursCompleted: map['dutyHoursCompleted']?.toString() ?? '0.0 Hrs',
      dutyHoursRequired: map['dutyHoursRequired']?.toString() ?? '8.0 Hrs',
    );
  }
}
