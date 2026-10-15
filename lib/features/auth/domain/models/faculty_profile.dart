class FacultyProfile {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String department;
  final String designation;
  final String roleTag;
  final String scheduledShift;
  final String block;
  final String cabinNumber;
  final String seniorityInfo;
  final String? avatarUrl;
  final bool isVerified;
  final String assignedGeofence;
  final String biometricStatus;
  final String syncStatus;

  const FacultyProfile({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    this.roleTag = 'HOD',
    this.scheduledShift = '08:30 – 16:30 IST',
    this.block = 'Turing Wing, 4th Floor',
    this.cabinNumber = 'TW-402',
    this.seniorityInfo = 'Senior Faculty Council (12 Yrs)',
    this.avatarUrl,
    this.isVerified = true,
    this.assignedGeofence = 'Turing Wing - Block 4',
    this.biometricStatus = 'Active (Iris + Facial)',
    this.syncStatus = 'Cloud ERP Active',
  });

  FacultyProfile copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? email,
    String? department,
    String? designation,
    String? roleTag,
    String? scheduledShift,
    String? block,
    String? cabinNumber,
    String? seniorityInfo,
    String? avatarUrl,
    bool? isVerified,
    String? assignedGeofence,
    String? biometricStatus,
    String? syncStatus,
  }) {
    return FacultyProfile(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      roleTag: roleTag ?? this.roleTag,
      scheduledShift: scheduledShift ?? this.scheduledShift,
      block: block ?? this.block,
      cabinNumber: cabinNumber ?? this.cabinNumber,
      seniorityInfo: seniorityInfo ?? this.seniorityInfo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      assignedGeofence: assignedGeofence ?? this.assignedGeofence,
      biometricStatus: biometricStatus ?? this.biometricStatus,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'department': department,
      'designation': designation,
      'roleTag': roleTag,
      'scheduledShift': scheduledShift,
      'block': block,
      'cabinNumber': cabinNumber,
      'seniorityInfo': seniorityInfo,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'assignedGeofence': assignedGeofence,
      'biometricStatus': biometricStatus,
      'syncStatus': syncStatus,
    };
  }

  factory FacultyProfile.fromMap(Map<String, dynamic> map, [String? id]) {
    return FacultyProfile(
      id: id ?? map['id']?.toString() ?? '',
      employeeId: map['employeeId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      designation: map['designation']?.toString() ?? '',
      roleTag: map['roleTag']?.toString() ?? 'HOD',
      scheduledShift: map['scheduledShift']?.toString() ?? '08:30 – 16:30 IST',
      block: map['block']?.toString() ?? 'Turing Wing, 4th Floor',
      cabinNumber: map['cabinNumber']?.toString() ?? 'TW-402',
      seniorityInfo: map['seniorityInfo']?.toString() ?? 'Senior Faculty Council (12 Yrs)',
      avatarUrl: map['avatarUrl']?.toString(),
      isVerified: map['isVerified'] as bool? ?? true,
      assignedGeofence: map['assignedGeofence']?.toString() ?? 'Turing Wing - Block 4',
      biometricStatus: map['biometricStatus']?.toString() ?? 'Active (Iris + Facial)',
      syncStatus: map['syncStatus']?.toString() ?? 'Cloud ERP Active',
    );
  }

  /// Default demo profile for offline/preview mode
  static const FacultyProfile demoProfile = FacultyProfile(
    id: 'fac_rajesh_sharma',
    employeeId: 'SKIT-FAC-2024-8841',
    name: 'Dr. Rajesh Sharma',
    email: 'rajesh.sharma@skit.ac.in',
    department: 'Dept of Computer Science & Engineering',
    designation: 'Professor & Head of Department',
    roleTag: 'HOD',
    scheduledShift: '08:30 – 16:30 IST',
    block: 'Turing Wing, 4th Floor',
    cabinNumber: 'TW-402',
    seniorityInfo: 'Senior Faculty Council (12 Yrs)',
    isVerified: true,
    assignedGeofence: 'Turing Wing - Block 4',
    biometricStatus: 'Active (Iris + Facial)',
    syncStatus: 'Cloud ERP Active',
  );
}
