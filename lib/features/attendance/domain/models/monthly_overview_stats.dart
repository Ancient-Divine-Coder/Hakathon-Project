class MonthlyOverviewStats {
  final String monthLabel;
  final String attendanceRate;
  final String attendanceRateCaption;
  final int daysPresent;
  final int totalWorkingDays;
  final double leavesTaken;
  final String onTimeScore;
  final String cycleEndsLabel;

  const MonthlyOverviewStats({
    this.monthLabel = 'Oct 2024',
    this.attendanceRate = '96.2%',
    this.attendanceRateCaption = '+1.4% vs last mo.',
    this.daysPresent = 21,
    this.totalWorkingDays = 22,
    this.leavesTaken = 1.0,
    this.onTimeScore = '98%',
    this.cycleEndsLabel = 'Cycle Ends: 31 Oct',
  });

  MonthlyOverviewStats copyWith({
    String? monthLabel,
    String? attendanceRate,
    String? attendanceRateCaption,
    int? daysPresent,
    int? totalWorkingDays,
    double? leavesTaken,
    String? onTimeScore,
    String? cycleEndsLabel,
  }) {
    return MonthlyOverviewStats(
      monthLabel: monthLabel ?? this.monthLabel,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      attendanceRateCaption:
          attendanceRateCaption ?? this.attendanceRateCaption,
      daysPresent: daysPresent ?? this.daysPresent,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      leavesTaken: leavesTaken ?? this.leavesTaken,
      onTimeScore: onTimeScore ?? this.onTimeScore,
      cycleEndsLabel: cycleEndsLabel ?? this.cycleEndsLabel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthLabel': monthLabel,
      'attendanceRate': attendanceRate,
      'attendanceRateCaption': attendanceRateCaption,
      'daysPresent': daysPresent,
      'totalWorkingDays': totalWorkingDays,
      'leavesTaken': leavesTaken,
      'onTimeScore': onTimeScore,
      'cycleEndsLabel': cycleEndsLabel,
    };
  }

  factory MonthlyOverviewStats.fromMap(Map<String, dynamic> map) {
    return MonthlyOverviewStats(
      monthLabel: map['monthLabel']?.toString() ?? 'Oct 2024',
      attendanceRate: map['attendanceRate']?.toString() ?? '0%',
      attendanceRateCaption: map['attendanceRateCaption']?.toString() ?? '',
      daysPresent: (map['daysPresent'] as num?)?.toInt() ?? 0,
      totalWorkingDays: (map['totalWorkingDays'] as num?)?.toInt() ?? 0,
      leavesTaken: (map['leavesTaken'] as num?)?.toDouble() ?? 0.0,
      onTimeScore: map['onTimeScore']?.toString() ?? '0%',
      cycleEndsLabel: map['cycleEndsLabel']?.toString() ?? '',
    );
  }
}
