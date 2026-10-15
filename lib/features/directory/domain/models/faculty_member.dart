enum FacultyStatus {
  inCabin,
  inClassroom,
  onLeave,
  offDuty,
}

extension FacultyStatusExtension on FacultyStatus {
  String get label {
    switch (this) {
      case FacultyStatus.inCabin:
        return 'In Cabin';
      case FacultyStatus.inClassroom:
        return 'In Lecture';
      case FacultyStatus.onLeave:
        return 'On Leave';
      case FacultyStatus.offDuty:
        return 'Off Campus';
    }
  }
}

class FacultyMember {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String cabin;
  final String email;
  final String phoneExtension;
  final FacultyStatus status;
  final List<String> subjects;
  final String officeHours;

  const FacultyMember({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.cabin,
    required this.email,
    required this.phoneExtension,
    required this.status,
    required this.subjects,
    required this.officeHours,
  });

  FacultyMember copyWith({
    String? id,
    String? name,
    String? designation,
    String? department,
    String? cabin,
    String? email,
    String? phoneExtension,
    FacultyStatus? status,
    List<String>? subjects,
    String? officeHours,
  }) {
    return FacultyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      cabin: cabin ?? this.cabin,
      email: email ?? this.email,
      phoneExtension: phoneExtension ?? this.phoneExtension,
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      officeHours: officeHours ?? this.officeHours,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'department': department,
      'cabin': cabin,
      'email': email,
      'phoneExtension': phoneExtension,
      'status': status.name,
      'subjects': subjects,
      'officeHours': officeHours,
    };
  }

  factory FacultyMember.fromMap(Map<String, dynamic> map, [String? id]) {
    final rawSubjects = map['subjects'];
    List<String> parsedSubjects = [];
    if (rawSubjects is List) {
      parsedSubjects = rawSubjects.map((e) => e.toString()).toList();
    }

    return FacultyMember(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      designation: map['designation']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      cabin: map['cabin']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phoneExtension: map['phoneExtension']?.toString() ?? '',
      status: FacultyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FacultyStatus.inCabin,
      ),
      subjects: parsedSubjects,
      officeHours: map['officeHours']?.toString() ?? '',
    );
  }
}
