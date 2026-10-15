class StaffBiometricProfile {
  final String employeeId;
  final String staffName;
  final String department;
  final String designation;
  final bool isPhotoEnrolled;
  final double qualityScore;
  final DateTime? enrolledAt;
  final String? photoBase64OrUrl;

  const StaffBiometricProfile({
    required this.employeeId,
    required this.staffName,
    required this.department,
    required this.designation,
    this.isPhotoEnrolled = false,
    this.qualityScore = 0.0,
    this.enrolledAt,
    this.photoBase64OrUrl,
  });

  StaffBiometricProfile copyWith({
    String? employeeId,
    String? staffName,
    String? department,
    String? designation,
    bool? isPhotoEnrolled,
    double? qualityScore,
    DateTime? enrolledAt,
    String? photoBase64OrUrl,
  }) {
    return StaffBiometricProfile(
      employeeId: employeeId ?? this.employeeId,
      staffName: staffName ?? this.staffName,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      isPhotoEnrolled: isPhotoEnrolled ?? this.isPhotoEnrolled,
      qualityScore: qualityScore ?? this.qualityScore,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      photoBase64OrUrl: photoBase64OrUrl ?? this.photoBase64OrUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'staffName': staffName,
      'department': department,
      'designation': designation,
      'isPhotoEnrolled': isPhotoEnrolled,
      'qualityScore': qualityScore,
      'enrolledAt': enrolledAt?.toIso8601String(),
      'photoBase64OrUrl': photoBase64OrUrl,
    };
  }

  factory StaffBiometricProfile.fromMap(
    Map<String, dynamic> map, [
    String? employeeId,
  ]) {
    DateTime? parsedEnrolledAt;
    if (map['enrolledAt'] != null) {
      parsedEnrolledAt = DateTime.tryParse(map['enrolledAt'].toString());
    }

    return StaffBiometricProfile(
      employeeId: employeeId ?? map['employeeId']?.toString() ?? '',
      staffName: map['staffName']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      designation: map['designation']?.toString() ?? '',
      isPhotoEnrolled: map['isPhotoEnrolled'] as bool? ?? false,
      qualityScore: (map['qualityScore'] as num?)?.toDouble() ?? 0.0,
      enrolledAt: parsedEnrolledAt,
      photoBase64OrUrl: map['photoBase64OrUrl']?.toString(),
    );
  }
}
