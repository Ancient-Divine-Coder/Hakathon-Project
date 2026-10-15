import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum FacultyStatus {
  available,
  inClass,
  inMeeting,
  onDuty,
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
}

class FacultyDirectoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FacultyDirectoryScreen({super.key, this.onBack});

  @override
  State<FacultyDirectoryScreen> createState() => _FacultyDirectoryScreenState();
}

class _FacultyDirectoryScreenState extends State<FacultyDirectoryScreen> {
  String _selectedDepartment = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _departments = [
    'All',
    'Computer Science',
    'Mechanical Engg',
    'Electronics & Comm',
    'Civil Engineering',
    'Basic Sciences',
  ];

  final List<FacultyMember> _facultyList = const [
    FacultyMember(
      id: 'FAC-CS-101',
      name: 'Dr. Rajesh Sharma',
      designation: 'Head of Department & Professor',
      department: 'Computer Science',
      cabin: 'Turing Block #302',
      email: 'rajesh.sharma@skit.ac.in',
      phoneExtension: 'Ext. 4012',
      status: FacultyStatus.available,
      subjects: ['Distributed Systems', 'Cloud Computing', 'Data Structures'],
      officeHours: 'Mon - Fri, 02:00 PM - 04:00 PM',
    ),
    FacultyMember(
      id: 'FAC-ME-204',
      name: 'Dr. Ananya Pandey',
      designation: 'Associate Professor',
      department: 'Mechanical Engg',
      cabin: 'Newton Block #114',
      email: 'ananya.pandey@skit.ac.in',
      phoneExtension: 'Ext. 3120',
      status: FacultyStatus.inClass,
      subjects: ['Thermodynamics', 'Fluid Mechanics'],
      officeHours: 'Tue & Thu, 11:00 AM - 01:00 PM',
    ),
    FacultyMember(
      id: 'FAC-EC-319',
      name: 'Prof. Vikram Malhotra',
      designation: 'Assistant Professor',
      department: 'Electronics & Comm',
      cabin: 'Tesla Hall #208',
      email: 'vikram.m@skit.ac.in',
      phoneExtension: 'Ext. 2488',
      status: FacultyStatus.inMeeting,
      subjects: ['VLSI Design', 'Digital Signal Processing'],
      officeHours: 'Wed & Fri, 03:00 PM - 05:00 PM',
    ),
    FacultyMember(
      id: 'FAC-CS-108',
      name: 'Dr. Sunita Rao',
      designation: 'Professor',
      department: 'Computer Science',
      cabin: 'Turing Block #305',
      email: 'sunita.rao@skit.ac.in',
      phoneExtension: 'Ext. 4018',
      status: FacultyStatus.available,
      subjects: ['Artificial Intelligence', 'Natural Language Processing'],
      officeHours: 'Mon & Wed, 10:00 AM - 12:00 PM',
    ),
    FacultyMember(
      id: 'FAC-CE-411',
      name: 'Prof. Arvind Deshmukh',
      designation: 'Assistant Professor',
      department: 'Civil Engineering',
      cabin: 'Visvesvaraya Wing #102',
      email: 'arvind.d@skit.ac.in',
      phoneExtension: 'Ext. 5104',
      status: FacultyStatus.onDuty,
      subjects: ['Structural Analysis', 'Concrete Technology'],
      officeHours: 'Mon - Thu, 04:00 PM - 05:30 PM',
    ),
    FacultyMember(
      id: 'FAC-BS-502',
      name: 'Dr. Neha Kulkarni',
      designation: 'Associate Professor',
      department: 'Basic Sciences',
      cabin: 'Raman Block #210',
      email: 'neha.kulkarni@skit.ac.in',
      phoneExtension: 'Ext. 6022',
      status: FacultyStatus.available,
      subjects: ['Applied Physics', 'Quantum Optics'],
      officeHours: 'Daily, 01:30 PM - 03:00 PM',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  FacultyMember _mapDocToFaculty(Map<String, dynamic> data, String docId) {
    FacultyStatus status = FacultyStatus.available;
    final statusStr =
        (data['status'] ?? data['currentStatus'] ?? 'available')
            .toString()
            .toLowerCase();
    if (statusStr.contains('class') || statusStr.contains('lecture')) {
      status = FacultyStatus.inClass;
    } else if (statusStr.contains('meeting')) {
      status = FacultyStatus.inMeeting;
    } else if (statusStr.contains('duty') || statusStr.contains('on-duty')) {
      status = FacultyStatus.onDuty;
    }

    List<String> subjects = ['Distributed Systems', 'Cloud Computing'];
    if (data['subjects'] is List) {
      subjects =
          (data['subjects'] as List).map((e) => e.toString()).toList();
    } else if (data['department'] != null) {
      subjects = ['Advanced ${data['department']}', 'Core Systems'];
    }

    return FacultyMember(
      id: data['employeeId']?.toString() ?? docId,
      name: data['name']?.toString() ?? 'Faculty Member',
      designation: data['designation']?.toString() ?? 'Assistant Professor',
      department: data['department']?.toString() ?? 'Computer Science',
      cabin: data['cabin']?.toString() ?? 'Academic Block #101',
      email: data['email']?.toString() ?? 'faculty@campus.edu',
      phoneExtension: data['phoneExtension']?.toString() ?? 'Ext. 4012',
      status: status,
      subjects: subjects,
      officeHours: data['officeHours']?.toString() ??
          'Mon - Fri, 02:00 PM - 04:00 PM',
    );
  }

  List<FacultyMember> _filterFaculty(List<FacultyMember> list) {
    return list.where((faculty) {
      if (_selectedDepartment != 'All') {
        final deptFilter = _selectedDepartment.toLowerCase();
        final facultyDept = faculty.department.toLowerCase();
        final matches = facultyDept.contains(deptFilter) ||
            deptFilter.contains(facultyDept) ||
            facultyDept.contains(deptFilter.split(' ').first);
        if (!matches) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return faculty.name.toLowerCase().contains(query) ||
            faculty.id.toLowerCase().contains(query) ||
            faculty.department.toLowerCase().contains(query) ||
            faculty.cabin.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  void _showFacultyProfile(FacultyMember faculty) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        faculty.name
                            .split(' ')
                            .take(2)
                            .map((e) => e[0])
                            .join(),
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faculty.name,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${faculty.designation} • ${faculty.department}',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildStatusBadge(faculty.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildInfoRow('Staff ID', faculty.id),
                _buildInfoRow('Cabin / Venue', faculty.cabin),
                _buildInfoRow('Official Email', faculty.email),
                _buildInfoRow('Campus Phone', faculty.phoneExtension),
                _buildInfoRow('Office Hours', faculty.officeHours),
                const SizedBox(height: 12),
                Text(
                  'Subjects & Specializations',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: faculty.subjects.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(s, style: AppTypography.labelSm),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close Profile'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FacultyStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case FacultyStatus.available:
        bg = AppColors.successContainer;
        fg = AppColors.success;
        label = 'Available in Cabin';
        break;
      case FacultyStatus.inClass:
        bg = AppColors.primaryContainer;
        fg = AppColors.primary;
        label = 'In Lecture Hall';
        break;
      case FacultyStatus.inMeeting:
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        label = 'In Faculty Meeting';
        break;
      case FacultyStatus.onDuty:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.secondary;
        label = 'On Campus Duty';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.codeSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CAMPUS ROSTER',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Faculty & Staff Directory',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search faculty by name, ID, cabin...',
                    hintStyle: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Department Filter Horizontal List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _departments.map((dept) {
                      final isSelected = dept == _selectedDepartment;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(dept),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedDepartment = dept);
                          },
                          labelStyle: AppTypography.labelSm.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Live Faculty Stream from Firestore with fallback
                StreamBuilder<QuerySnapshot>(
                  stream: Firebase.apps.isNotEmpty
                      ? FirebaseFirestore.instance.collection('users').snapshots()
                      : null,
                  builder: (context, snapshot) {
                    List<FacultyMember> facultyList = _facultyList;

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final userDocs = snapshot.data!.docs;
                      final liveMembers = userDocs
                          .where((d) =>
                              (d.data() as Map<String, dynamic>)['role'] != 'admin')
                          .map((doc) => _mapDocToFaculty(
                              doc.data() as Map<String, dynamic>, doc.id))
                          .toList();

                      if (liveMembers.isNotEmpty) {
                        final existingIds = liveMembers.map((e) => e.id).toSet();
                        facultyList = [
                          ...liveMembers,
                          ..._facultyList
                              .where((f) => !existingIds.contains(f.id)),
                        ];
                      }
                    }

                    final filtered = _filterFaculty(facultyList);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Results Counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL FACULTY',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${filtered.length} Found',
                              style: AppTypography.codeSm.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Faculty Cards
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.person_search_outlined,
                                    size: 48,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No faculty members found',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filtered.map(_buildFacultyCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyCard(FacultyMember faculty) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showFacultyProfile(faculty),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  faculty.name
                      .split(' ')
                      .take(2)
                      .map((e) => e[0])
                      .join(),
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            faculty.name,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(faculty.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${faculty.designation} • ${faculty.department}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.secondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            faculty.cabin,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          faculty.phoneExtension,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
