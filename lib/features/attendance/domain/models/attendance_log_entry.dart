class AttendanceLogEntry {
  final String dateTitle;
  final String sessionSubtitle;
  final String inTime;
  final String outTime;
  final String totalHours;
  final String statusLabel;
  final String gateTurnstile;
  final bool isRegular;

  const AttendanceLogEntry({
    required this.dateTitle,
    required this.sessionSubtitle,
    required this.inTime,
    required this.outTime,
    required this.totalHours,
    required this.statusLabel,
    required this.gateTurnstile,
    this.isRegular = true,
  });

  AttendanceLogEntry copyWith({
    String? dateTitle,
    String? sessionSubtitle,
    String? inTime,
    String? outTime,
    String? totalHours,
    String? statusLabel,
    String? gateTurnstile,
    bool? isRegular,
  }) {
    return AttendanceLogEntry(
      dateTitle: dateTitle ?? this.dateTitle,
      sessionSubtitle: sessionSubtitle ?? this.sessionSubtitle,
      inTime: inTime ?? this.inTime,
      outTime: outTime ?? this.outTime,
      totalHours: totalHours ?? this.totalHours,
      statusLabel: statusLabel ?? this.statusLabel,
      gateTurnstile: gateTurnstile ?? this.gateTurnstile,
      isRegular: isRegular ?? this.isRegular,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateTitle': dateTitle,
      'sessionSubtitle': sessionSubtitle,
      'inTime': inTime,
      'outTime': outTime,
      'totalHours': totalHours,
      'statusLabel': statusLabel,
      'gateTurnstile': gateTurnstile,
      'isRegular': isRegular,
    };
  }

  factory AttendanceLogEntry.fromMap(Map<String, dynamic> map) {
    return AttendanceLogEntry(
      dateTitle: map['dateTitle']?.toString() ?? '',
      sessionSubtitle: map['sessionSubtitle']?.toString() ?? '',
      inTime: map['inTime']?.toString() ?? '',
      outTime: map['outTime']?.toString() ?? '',
      totalHours: map['totalHours']?.toString() ?? '',
      statusLabel: map['statusLabel']?.toString() ?? '',
      gateTurnstile: map['gateTurnstile']?.toString() ?? '',
      isRegular: map['isRegular'] as bool? ?? true,
    );
  }
}
