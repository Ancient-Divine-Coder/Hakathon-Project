enum StaffAttendanceStatus {
  verified,
  flagged,
}

class StaffAttendanceRecord {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String category;
  final String checkInTime;
  final String location;
  final bool isInsideGeofence;
  final String wifiNetwork;
  final StaffAttendanceStatus status;
  final String method;
  final String? anomalyNote;

  const StaffAttendanceRecord({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.category,
    required this.checkInTime,
    required this.location,
    required this.isInsideGeofence,
    required this.wifiNetwork,
    required this.status,
    required this.method,
    this.anomalyNote,
  });

  StaffAttendanceRecord copyWith({
    String? id,
    String? name,
    String? designation,
    String? department,
    String? category,
    String? checkInTime,
    String? location,
    bool? isInsideGeofence,
    String? wifiNetwork,
    StaffAttendanceStatus? status,
    String? method,
    String? anomalyNote,
  }) {
    return StaffAttendanceRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      category: category ?? this.category,
      checkInTime: checkInTime ?? this.checkInTime,
      location: location ?? this.location,
      isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
      wifiNetwork: wifiNetwork ?? this.wifiNetwork,
      status: status ?? this.status,
      method: method ?? this.method,
      anomalyNote: anomalyNote ?? this.anomalyNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'department': department,
      'category': category,
      'checkInTime': checkInTime,
      'location': location,
      'isInsideGeofence': isInsideGeofence,
      'wifiNetwork': wifiNetwork,
      'status': status.name,
      'method': method,
      'anomalyNote': anomalyNote,
    };
  }

  factory StaffAttendanceRecord.fromMap(
    Map<String, dynamic> map, [
    String? id,
  ]) {
    return StaffAttendanceRecord(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      designation: map['designation']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      category: map['category']?.toString() ?? 'teaching',
      checkInTime: map['checkInTime']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      isInsideGeofence: map['isInsideGeofence'] as bool? ?? false,
      wifiNetwork: map['wifiNetwork']?.toString() ?? '',
      status: StaffAttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StaffAttendanceStatus.verified,
      ),
      method: map['method']?.toString() ?? 'Face & GPS',
      anomalyNote: map['anomalyNote']?.toString(),
    );
  }
}
