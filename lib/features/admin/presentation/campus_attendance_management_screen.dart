import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../../core/services/auth_service.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/leave_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/image_crop_utils.dart';
import '../../../core/widgets/user_profile_avatar_button.dart';
import '../../enrollment/presentation/staff_biometric_enrollment_screen.dart';
import 'admin_broadcast_message_dialog.dart';
import 'admin_leave_approval_screen.dart';

class CampusAttendanceManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onEnrollStaff;
  final VoidCallback? onLeaveApprovals;
  final VoidCallback? onBroadcast;

  const CampusAttendanceManagementScreen({
    super.key,
    this.onBack,
    this.onLogoutPressed,
    this.onEnrollStaff,
    this.onLeaveApprovals,
    this.onBroadcast,
  });

  @override
  State<CampusAttendanceManagementScreen> createState() =>
      _CampusAttendanceManagementScreenState();
}

class _CampusAttendanceManagementScreenState
    extends State<CampusAttendanceManagementScreen> {
  String _selectedCategory = 'all'; // 'all', 'teaching', 'non-technical'
  String _selectedStatus = 'all'; // 'all', 'verified', 'flagged'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, StaffAttendanceRecord> _localEdits = {};

  final List<StaffAttendanceRecord> _records = [
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-8841',
      name: 'Dr. Rajesh Sharma',
      designation: 'Head of Department',
      department: 'Computer Science',
      category: 'teaching',
      checkInTime: '08:55 AM',
      location: 'Turing Block',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-9102',
      name: 'Dr. Ananya Pandey',
      designation: 'Associate Professor',
      department: 'Mechanical Engg',
      category: 'teaching',
      checkInTime: '09:02 AM',
      location: 'LT-04 Hall',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-7719',
      name: 'Prof. Vikram Malhotra',
      designation: 'Assistant Professor',
      department: 'Electronics & Comm',
      category: 'teaching',
      checkInTime: '09:14 AM',
      location: 'North Annex',
      isInsideGeofence: false,
      wifiNetwork: 'Mobile Cellular',
      status: AttendanceStatus.flagged,
      method: 'GPS Out of Bounds',
      anomalyNote: 'Ingress logged 420m outside campus perimeter.',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-4011',
      name: 'Suresh Kumar',
      designation: 'Senior Lab Technician',
      department: 'Physics Lab',
      category: 'non-technical',
      checkInTime: '08:40 AM',
      location: 'Science Block B',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Staff-WPA3',
      status: AttendanceStatus.verified,
      method: 'Turnstile RFID',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-5120',
      name: 'Meena Kumari',
      designation: 'Administrative Officer',
      department: 'Dean Office',
      category: 'non-technical',
      checkInTime: '08:50 AM',
      location: 'Admin Building',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Admin-Secure',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-6330',
      name: 'Dr. Harish Chandra',
      designation: 'Professor',
      department: 'Civil Engineering',
      category: 'teaching',
      checkInTime: '09:30 AM',
      location: 'Gate-1 Barrier',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.flagged,
      method: 'Late Ingress',
      anomalyNote: 'Arrived after grace window (Threshold: 09:15 AM).',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-1102',
      name: 'Dr. Priya Iyer',
      designation: 'Professor & Dean R&D',
      department: 'Computer Science',
      category: 'teaching',
      checkInTime: '08:35 AM',
      location: 'Ramanujan Block',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-2215',
      name: 'Dr. Amitav Ghosh',
      designation: 'Associate Professor',
      department: 'Electrical Engg',
      category: 'teaching',
      checkInTime: '08:48 AM',
      location: 'Faraday Hall',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-3342',
      name: 'Dr. Sneha Kulkarni',
      designation: 'Assistant Professor',
      department: 'AI & Data Science',
      category: 'teaching',
      checkInTime: '08:52 AM',
      location: 'Ada Lovelace Hub',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-4451',
      name: 'Prof. Rohit Verma',
      designation: 'Associate Professor',
      department: 'Information Technology',
      category: 'teaching',
      checkInTime: '09:05 AM',
      location: 'Turing Block',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-5563',
      name: 'Dr. Kavita Nair',
      designation: 'Head of Department',
      department: 'Chemistry',
      category: 'teaching',
      checkInTime: '08:44 AM',
      location: 'Science Block A',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-6674',
      name: 'Dr. Alok Mukhopadhyay',
      designation: 'Professor',
      department: 'Mathematics',
      category: 'teaching',
      checkInTime: '08:58 AM',
      location: 'Aryabhata Wing',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-7785',
      name: 'Dr. Sunita Sen',
      designation: 'Associate Professor',
      department: 'Physics',
      category: 'teaching',
      checkInTime: '09:01 AM',
      location: 'Science Block B',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-8896',
      name: 'Prof. Neha Gupta',
      designation: 'Assistant Professor',
      department: 'Electronics & Comm',
      category: 'teaching',
      checkInTime: '08:46 AM',
      location: 'North Annex',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-9907',
      name: 'Dr. Manoj Joshi',
      designation: 'Associate Professor',
      department: 'Mechanical Engg',
      category: 'teaching',
      checkInTime: '09:18 AM',
      location: 'Workshop Block',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.flagged,
      method: 'Late Ingress',
      anomalyNote: 'Ingress logged at 09:18 AM (Threshold: 09:15 AM).',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-1218',
      name: 'Prof. Tarun Deshmukh',
      designation: 'Assistant Professor',
      department: 'Civil Engineering',
      category: 'teaching',
      checkInTime: '08:50 AM',
      location: 'Visvesvaraya Hall',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-2329',
      name: 'Dr. Ritu Saxena',
      designation: 'Associate Professor',
      department: 'Humanities & Management',
      category: 'teaching',
      checkInTime: '08:42 AM',
      location: 'Chanakya Block',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-3430',
      name: 'Prof. Deepak Chawla',
      designation: 'Assistant Professor',
      department: 'Computer Science',
      category: 'teaching',
      checkInTime: '09:04 AM',
      location: 'Computing Lab 3',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-4541',
      name: 'Dr. Swati Bhattacharya',
      designation: 'Professor',
      department: 'Biotechnology',
      category: 'teaching',
      checkInTime: '08:53 AM',
      location: 'Bio-Tech Complex',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Face & GPS',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-FAC-2024-5652',
      name: 'Prof. Manish Tiwari',
      designation: 'Assistant Professor',
      department: 'Electrical Engg',
      category: 'teaching',
      checkInTime: '09:22 AM',
      location: 'South Perimeter',
      isInsideGeofence: false,
      wifiNetwork: 'Mobile Cellular',
      status: AttendanceStatus.flagged,
      method: 'GPS Out of Bounds',
      anomalyNote: 'Ingress logged 310m outside campus perimeter.',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-6763',
      name: 'Rameshwar Prasad',
      designation: 'Systems Administrator',
      department: 'Central IT & Networks',
      category: 'non-technical',
      checkInTime: '08:30 AM',
      location: 'Server Room HQ',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Staff-WPA3',
      status: AttendanceStatus.verified,
      method: 'Turnstile RFID',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-7874',
      name: 'Sunita Rao',
      designation: 'Chief Librarian',
      department: 'Central Library',
      category: 'non-technical',
      checkInTime: '08:45 AM',
      location: 'Central Library',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Admin-Secure',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-8985',
      name: 'Vijay Singh',
      designation: 'Senior Estate Manager',
      department: 'Campus Maintenance',
      category: 'non-technical',
      checkInTime: '08:20 AM',
      location: 'Facilities HQ',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Staff-WPA3',
      status: AttendanceStatus.verified,
      method: 'Turnstile RFID',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-9096',
      name: 'Anita Roy',
      designation: 'Finance & Accounts Officer',
      department: 'Accounts Dept',
      category: 'non-technical',
      checkInTime: '08:55 AM',
      location: 'Admin Building',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Admin-Secure',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-1317',
      name: 'Arvind Rathore',
      designation: 'Academic Registrar',
      department: 'Registrar Office',
      category: 'non-technical',
      checkInTime: '08:38 AM',
      location: 'Main Secretariat',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Admin-Secure',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-2428',
      name: 'Pooja Mehra',
      designation: 'HR Executive',
      department: 'Personnel Department',
      category: 'non-technical',
      checkInTime: '08:50 AM',
      location: 'Admin Building',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Admin-Secure',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-3539',
      name: 'Gopal Yadav',
      designation: 'Head Workshop Technician',
      department: 'Central Workshop',
      category: 'non-technical',
      checkInTime: '08:15 AM',
      location: 'Central Workshop',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Staff-WPA3',
      status: AttendanceStatus.verified,
      method: 'Turnstile RFID',
    ),
    StaffAttendanceRecord(
      id: 'SKIT-STAFF-2024-4640',
      name: 'Vandana Sharma',
      designation: 'Student Welfare Coordinator',
      department: 'Student Affairs',
      category: 'non-technical',
      checkInTime: '08:48 AM',
      location: 'Student Centre',
      isInsideGeofence: true,
      wifiNetwork: 'SKIT-Campus-5G',
      status: AttendanceStatus.verified,
      method: 'Biometric Face',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEnrollment() {
    if (widget.onEnrollStaff != null) {
      widget.onEnrollStaff!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffBiometricEnrollmentScreen(
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  void _openLeaveApprovals() {
    if (widget.onLeaveApprovals != null) {
      widget.onLeaveApprovals!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminLeaveApprovalScreen(
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  void _openBroadcast() {
    if (widget.onBroadcast != null) {
      widget.onBroadcast!();
    } else {
      showAdminBroadcastDialog(context);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Admin Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to end your administrator session? You will be returned to the campus portal login.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogCtx, true),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      AuthService().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Admin logged out successfully. Returning to login.'),
              ),
            ],
          ),
        ),
      );
      if (widget.onLogoutPressed != null) {
        widget.onLogoutPressed!();
      } else if (widget.onBack != null) {
        widget.onBack!();
      }
    }
  }

  void _openEditFacultyDialog(StaffAttendanceRecord record) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _EditFacultyDialog(
          record: record,
          onSave: (updatedRecord) {
            setState(() {
              _localEdits[updatedRecord.id] = updatedRecord;
              final idx = _records.indexWhere((r) => r.id == updatedRecord.id);
              if (idx != -1) {
                _records[idx] = updatedRecord;
              }
            });

            if (Firebase.apps.isNotEmpty) {
              _updateFirestoreFaculty(updatedRecord);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primaryContainer,
                behavior: SnackBarBehavior.floating,
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Faculty details for ${updatedRecord.name} updated successfully.',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateFirestoreFaculty(StaffAttendanceRecord record) async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      final docById = await usersCollection.doc(record.id).get();
      if (docById.exists) {
        await usersCollection.doc(record.id).set({
          'name': record.name,
          'designation': record.designation,
          'department': record.department,
          'cabin': record.location,
          'cabinNumber': record.location.replaceAll('Cabin ', '').trim(),
          'scheduledShift': record.checkInTime,
          'role': record.category == 'teaching' ? 'faculty' : 'staff',
          'status':
              record.status == AttendanceStatus.verified ? 'active' : 'flagged',
          'anomalyNote': record.anomalyNote,
          'wifiNetwork': record.wifiNetwork,
          if (record.photoBase64 != null) ...{
            'photoBase64':
                record.photoBase64!.isNotEmpty ? record.photoBase64 : null,
            'facePhotoBase64':
                record.photoBase64!.isNotEmpty ? record.photoBase64 : null,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      final queryByEmpId = await usersCollection
          .where('employeeId', isEqualTo: record.id)
          .limit(1)
          .get();
      if (queryByEmpId.docs.isNotEmpty) {
        for (final doc in queryByEmpId.docs) {
          await doc.reference.set({
            'name': record.name,
            'designation': record.designation,
            'department': record.department,
            'cabin': record.location,
            'cabinNumber': record.location.replaceAll('Cabin ', '').trim(),
            'scheduledShift': record.checkInTime,
            'role': record.category == 'teaching' ? 'faculty' : 'staff',
            'status': record.status == AttendanceStatus.verified
                ? 'active'
                : 'flagged',
            'anomalyNote': record.anomalyNote,
            'wifiNetwork': record.wifiNetwork,
            if (record.photoBase64 != null) ...{
              'photoBase64':
                  record.photoBase64!.isNotEmpty ? record.photoBase64 : null,
              'facePhotoBase64':
                  record.photoBase64!.isNotEmpty ? record.photoBase64 : null,
            },
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } else {
        await usersCollection.doc(record.id).set({
          'name': record.name,
          'employeeId': record.id,
          'designation': record.designation,
          'department': record.department,
          'cabin': record.location,
          'scheduledShift': record.checkInTime,
          'role': record.category == 'teaching' ? 'faculty' : 'staff',
          'status': record.status == AttendanceStatus.verified
              ? 'active'
              : 'flagged',
          'anomalyNote': record.anomalyNote,
          'wifiNetwork': record.wifiNetwork,
          if (record.photoBase64 != null) ...{
            'photoBase64':
                record.photoBase64!.isNotEmpty ? record.photoBase64 : null,
            'facePhotoBase64':
                record.photoBase64!.isNotEmpty ? record.photoBase64 : null,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore faculty update skipped/error: $e');
    }
  }

  List<StaffAttendanceRecord> _mapUsersToRecords(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return _records.map((r) => _localEdits[r.id] ?? r).toList();
    }
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final role = data['role']?.toString().toLowerCase() ?? 'faculty';
      final statusStr = data['status']?.toString().toLowerCase() ?? 'active';
      final isVerified = statusStr == 'active' || statusStr == 'available';
      final empId = data['employeeId']?.toString() ?? doc.id;

      if (_localEdits.containsKey(empId)) {
        return _localEdits[empId]!;
      }

      return StaffAttendanceRecord(
        id: empId,
        name: data['name']?.toString() ?? 'Faculty Member',
        designation: data['designation']?.toString() ??
            (role == 'admin' ? 'Administrator' : 'Faculty'),
        department: data['department']?.toString() ?? 'General',
        category: role == 'admin' ? 'non-technical' : 'teaching',
        checkInTime:
            data['scheduledShift']?.toString().split('–').first.trim() ??
                '08:30 AM',
        location: data['cabinNumber'] != null
            ? 'Cabin ${data['cabinNumber']}'
            : (data['cabin']?.toString() ?? 'Campus HQ'),
        isInsideGeofence: true,
        wifiNetwork: 'SKIT-Campus-5G',
        status:
            isVerified ? AttendanceStatus.verified : AttendanceStatus.flagged,
        method: data['biometricStatus'] == 'enrolled'
            ? 'Face Biometric Enrolled'
            : 'Firestore Cloud Auth',
        anomalyNote:
            isVerified ? null : 'Pending administrative verification.',
        photoBase64: data['photoBase64']?.toString(),
      );
    }).toList();
  }  void _showRecordDetails(StaffAttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (record.photoBase64 != null &&
                      record.photoBase64!.isNotEmpty) ...[
                    ClipOval(
                      child: Image.memory(
                        base64Decode(record.photoBase64!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ] else ...[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: record.status == AttendanceStatus.verified
                            ? const Color(0xFFEEF2FF)
                            : const Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: record.status == AttendanceStatus.verified
                              ? const Color(0xFFC7D2FE)
                              : const Color(0xFFFECACA),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          record.name
                              .split(' ')
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .take(2)
                              .join(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: record.status == AttendanceStatus.verified
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.name,
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${record.designation} • ${record.department}',
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusPill(record.status, record.method),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),
              _buildDetailRow('Staff ID', record.id),
              _buildDetailRow('Check-in Time', record.checkInTime),
              _buildDetailRow('Assigned Venue', record.location),
              _buildDetailRow(
                'Geofence State',
                record.isInsideGeofence
                    ? 'Verified inside campus boundary'
                    : 'Flagged: Outside perimeter',
              ),
              _buildDetailRow('Wi-Fi Enclave', record.wifiNetwork),
              if (record.anomalyNote != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          record.anomalyNote!,
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF991B1B),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openEditFacultyDialog(record);
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Edit Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showAdminBroadcastDialog(
                          context,
                          prefillRecipient: '${record.name} (${record.id})',
                          prefillTitle: 'Notice for ${record.name}',
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send Notice'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    tooltip: 'Close',
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(AttendanceStatus status, String method) {
    final isVerified = status == AttendanceStatus.verified;
    final bg = isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final border = isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);
    final color = isVerified ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final icon = isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Flagged',
            style: AppTypography.codeSm.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.2),
          child: Divider(height: 1.2, thickness: 1.2, color: Color(0xFFE2E8F0)),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CAMPUS ERP ADMIN',
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 1.0,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Live Campus Attendance',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${LeaveService().getPendingApplications().length}'),
              isLabelVisible: LeaveService().getPendingApplications().isNotEmpty,
              backgroundColor: const Color(0xFFDC2626),
              child: const Icon(Icons.approval_outlined, size: 21, color: Color(0xFF475569)),
            ),
            onPressed: _openLeaveApprovals,
            tooltip: 'Leave & Sanction Approvals',
          ),
          IconButton(
            icon: const Icon(Icons.campaign_outlined, size: 22, color: Color(0xFF475569)),
            onPressed: _openBroadcast,
            tooltip: 'Send Campus Announcement / Broadcast',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFDC2626)),
            onPressed: _handleLogout,
            tooltip: 'Admin Logout',
          ),
          UserProfileAvatarButton(
            onLogout: _handleLogout,
            size: 30,
            padding: const EdgeInsets.only(right: 12.0),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firebase.apps.isNotEmpty
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                List<StaffAttendanceRecord> records =
                    _records.map((r) => _localEdits[r.id] ?? r).toList();

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  records = _mapUsersToRecords(snapshot.data!.docs);
                }

                final totalFaculty = records.length;
                final presentToday = records
                    .where((r) => r.status == AttendanceStatus.verified)
                    .length;
                final flaggedCount = records
                    .where((r) => r.status == AttendanceStatus.flagged)
                    .length;
                final complianceStr = totalFaculty > 0
                    ? '${(presentToday / totalFaculty * 100).toStringAsFixed(1)}% Compliance'
                    : '100% Compliance';

                final filtered = records.where((record) {
                  if (_selectedCategory != 'all' &&
                      record.category != _selectedCategory) {
                    return false;
                  }
                  if (_selectedStatus == 'verified' &&
                      record.status != AttendanceStatus.verified) {
                    return false;
                  }
                  if (_selectedStatus == 'flagged' &&
                      record.status != AttendanceStatus.flagged) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    return record.name.toLowerCase().contains(q) ||
                        record.id.toLowerCase().contains(q) ||
                        record.department.toLowerCase().contains(q);
                  }
                  return true;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Telemetry Header
                    _buildTelemetryHeader(),
                    const SizedBox(height: 16),

                    // 4 Metric Bento Cards
                    _buildMetricBentoCards(
                      totalFaculty: totalFaculty,
                      presentToday: presentToday,
                      flaggedCount: flaggedCount,
                      complianceStr: complianceStr,
                    ),
                    const SizedBox(height: 16),

                    // Search & Filter Bar
                    _buildSearchAndFilters(totalFaculty: totalFaculty),
                    const SizedBox(height: 16),

                    // Real-Time Telemetry Roster
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'REAL-TIME TELEMETRY ROSTER (FIRESTORE LIVE)',
                                  style: AppTypography.labelSm.copyWith(
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                                  ),
                                  child: Text(
                                    '${filtered.length} Live Records',
                                    style: AppTypography.codeSm.copyWith(
                                      color: const Color(0xFF059669),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _openBroadcast,
                                  icon: const Icon(Icons.campaign_outlined, size: 16),
                                  label: const Text('Broadcast'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF334155),
                                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    textStyle: AppTypography.labelSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _openEnrollment,
                                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                                  label: const Text('+ Enroll Staff'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    textStyle: AppTypography.labelSm.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (filtered.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 36.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                            ),
                            child: Center(
                              child: Text(
                                'No staff records found.',
                                style: AppTypography.bodySm.copyWith(color: const Color(0xFF64748B)),
                              ),
                            ),
                          )
                        else
                          ...filtered.map(_buildStaffCard),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Feed • Gate Sensors (09/09 Hubs Active)',
                    style: AppTypography.labelSm.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'GPS: 200m',
              style: AppTypography.codeSm.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _handleLogout,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout_rounded, size: 13, color: Color(0xFFDC2626)),
                  const SizedBox(width: 4),
                  Text(
                    'Admin Logout',
                    style: AppTypography.labelSm.copyWith(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBentoCards({
    required int totalFaculty,
    required int presentToday,
    required int flaggedCount,
    required String complianceStr,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMetricCard(
              width: cardWidth,
              label: 'Total Faculty',
              value: '$totalFaculty',
              subtext: 'Registered Staff',
              icon: Icons.groups_rounded,
            ),
            _buildMetricCard(
              width: cardWidth,
              label: 'Present Today',
              value: '$presentToday',
              subtext: complianceStr,
              badgeColor: const Color(0xFF10B981),
            ),
            _buildMetricCard(
              width: cardWidth,
              label: 'On Leave',
              value: '${LeaveService().getPendingApplications().length + 2}',
              subtext:
                  '${LeaveService().getPendingApplications().length} Pending Review',
              icon: Icons.event_busy_rounded,
              onTap: _openLeaveApprovals,
            ),
            _buildMetricCard(
              width: cardWidth,
              label: 'Flagged / Anomalies',
              value: '$flaggedCount',
              subtext: 'Requires Clearance',
              badgeColor: const Color(0xFFDC2626),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required double width,
    required String label,
    required String value,
    required String subtext,
    IconData? icon,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    final card = Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Icon(icon, size: 16, color: const Color(0xFF475569)),
                )
              else if (badgeColor != null)
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badgeColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtext,
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }

  Widget _buildSearchAndFilters({required int totalFaculty}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Search by Staff ID, Name, Dept...',
              hintStyle: AppTypography.bodySm.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category & Status Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('all', 'All Staff ($totalFaculty)'),
                const SizedBox(width: 8),
                _buildFilterChip('teaching', 'Teaching Faculty'),
                const SizedBox(width: 8),
                _buildFilterChip('non-technical', 'Non-Technical Staff'),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      icon: const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'verified',
                          child: Text('Verified Only'),
                        ),
                        DropdownMenuItem(
                          value: 'flagged',
                          child: Text('Flagged / Late'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffAttendanceRecord record) {
    final isVerified = record.status == AttendanceStatus.verified;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFFECACA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRecordDetails(record),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Initials or Photo Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isVerified
                        ? const Color(0xFFEEF2FF)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isVerified
                          ? const Color(0xFFC7D2FE)
                          : const Color(0xFFFECACA),
                      width: 1.2,
                    ),
                  ),
                  child: record.photoBase64 != null &&
                          record.photoBase64!.isNotEmpty
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(record.photoBase64!),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(
                              child: Text(
                                record.name
                                    .split(' ')
                                    .map((e) => e.isNotEmpty ? e[0] : '')
                                    .take(2)
                                    .join(),
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isVerified
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            record.name
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join(),
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isVerified
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${record.department} • ${record.location}',
                        style: AppTypography.bodySm.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                _buildStatusPill(record.status, record.method),
                const SizedBox(width: 4),

                // 1-Tap Edit Faculty Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: const Color(0xFF4F46E5),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  onPressed: () => _openEditFacultyDialog(record),
                  tooltip: 'Edit Faculty Details',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AttendanceStatus { verified, flagged }

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
  final AttendanceStatus status;
  final String method;
  final String? anomalyNote;
  final String? photoBase64;

  StaffAttendanceRecord({
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
    this.photoBase64,
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
    AttendanceStatus? status,
    String? method,
    String? anomalyNote,
    String? photoBase64,
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
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}

class _EditFacultyDialog extends StatefulWidget {
  final StaffAttendanceRecord record;
  final ValueChanged<StaffAttendanceRecord> onSave;

  const _EditFacultyDialog({
    required this.record,
    required this.onSave,
  });

  @override
  State<_EditFacultyDialog> createState() => _EditFacultyDialogState();
}

class _EditFacultyDialogState extends State<_EditFacultyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _designationController;
  late final TextEditingController _departmentController;
  late final TextEditingController _locationController;
  late final TextEditingController _shiftController;
  late final TextEditingController _wifiController;
  late final TextEditingController _notesController;
  late String _category;
  late AttendanceStatus _status;
  String? _photoBase64;
  Uint8List? _photoBytes;
  bool _isPhotoLoading = false;

  final List<String> _designationPresets = [
    'Head of Department',
    'Professor & HOD',
    'Professor',
    'Associate Professor',
    'Assistant Professor',
    'Senior Lecturer',
    'Senior Lab Technician',
    'Administrative Officer',
  ];

  final List<String> _departmentPresets = [
    'Computer Science',
    'Mechanical Engg',
    'Electronics & Comm',
    'Civil Engineering',
    'Physics Lab',
    'Dean Office',
    'Administration',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.record.name);
    _designationController =
        TextEditingController(text: widget.record.designation);
    _departmentController =
        TextEditingController(text: widget.record.department);
    _locationController = TextEditingController(text: widget.record.location);
    _shiftController = TextEditingController(text: widget.record.checkInTime);
    _wifiController = TextEditingController(text: widget.record.wifiNetwork);
    _notesController =
        TextEditingController(text: widget.record.anomalyNote ?? '');
    _category = widget.record.category;
    _status = widget.record.status;
    _photoBase64 = widget.record.photoBase64;
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        _photoBytes = base64Decode(_photoBase64!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _shiftController.dispose();
    _wifiController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isPhotoLoading = true);

    if (CameraService().isRunningInTest) {
      await Future.delayed(const Duration(milliseconds: 50));
      final sampleImg = img.Image(width: 64, height: 64);
      for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
          sampleImg.setPixelRgb(x, y, 120, 150, 220);
        }
      }
      final bytes = Uint8List.fromList(img.encodeJpg(sampleImg));
      if (mounted) {
        setState(() {
          _isPhotoLoading = false;
          _photoBytes = bytes;
          _photoBase64 = base64Encode(bytes);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty biometric photo captured.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final result = await showModalBottomSheet<EnrollmentPhotoResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BiometricCameraEnrollmentModal(),
    );

    if (result != null && mounted) {
      setState(() {
        _isPhotoLoading = false;
        _photoBytes = result.bytes;
        _photoBase64 = base64Encode(result.bytes);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faculty biometric photo captured.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      setState(() => _isPhotoLoading = false);
    }
  }

  Future<void> _choosePhoto() async {
    setState(() => _isPhotoLoading = true);

    XFile? pickedFile;
    if (!CameraService().isRunningInTest) {
      try {
        pickedFile = await CameraService().pickOrCapturePhoto(
          source: ImageSource.gallery,
        );
      } catch (e) {
        debugPrint('[EditFaculty] Gallery pick error: $e');
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (pickedFile == null) {
      if (mounted) {
        setState(() => _isPhotoLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No photo was selected.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      final raw = await pickedFile.readAsBytes();
      final cropped = ImageCropUtils.cropToCircularGrid(raw);
      final bytes = cropped.circularPngBytes;

      if (mounted) {
        setState(() {
          _isPhotoLoading = false;
          _photoBytes = bytes;
          _photoBase64 = base64Encode(bytes);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty profile photo updated from gallery.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPhotoLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _photoBytes = null;
      _photoBase64 = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Faculty photo removed.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final updated = widget.record.copyWith(
      name: _nameController.text.trim(),
      designation: _designationController.text.trim(),
      department: _departmentController.text.trim(),
      category: _category,
      location: _locationController.text.trim(),
      checkInTime: _shiftController.text.trim(),
      wifiNetwork: _wifiController.text.trim().isNotEmpty
          ? _wifiController.text.trim()
          : widget.record.wifiNetwork,
      status: _status,
      anomalyNote: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      method: _status == AttendanceStatus.verified
          ? (_notesController.text.trim().isNotEmpty
              ? 'Admin Verified'
              : widget.record.method)
          : 'Flagged by Admin',
      photoBase64: _photoBase64,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Faculty Details',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Staff ID: ${widget.record.id}',
                          style: AppTypography.codeSm.copyWith(
                            color: AppColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Faculty Photo Reticle & Management Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: (_photoBytes != null ||
                                          (_photoBase64 != null &&
                                              _photoBase64!.isNotEmpty))
                                      ? AppColors.success
                                      : AppColors.secondary
                                          .withValues(alpha: 0.4),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: RadialGradient(
                                          center: Alignment.center,
                                          radius: 0.85,
                                          colors: [
                                            Color(0xFF1E293B),
                                            Color(0xFF0F172A),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_photoBytes != null)
                                      Image.memory(
                                        _photoBytes!,
                                        fit: BoxFit.cover,
                                        width: 104,
                                        height: 104,
                                        errorBuilder: (_, _, _) =>
                                            _buildAvatarPlaceholder(),
                                      )
                                    else if (_photoBase64 != null &&
                                        _photoBase64!.isNotEmpty)
                                      Image.memory(
                                        base64Decode(_photoBase64!),
                                        fit: BoxFit.cover,
                                        width: 104,
                                        height: 104,
                                        errorBuilder: (_, _, _) =>
                                            _buildAvatarPlaceholder(),
                                      )
                                    else
                                      _buildAvatarPlaceholder(),
                                    CustomPaint(
                                      painter: EnrollmentReticlePainter(
                                        isCaptured: _photoBytes != null ||
                                            (_photoBase64 != null &&
                                                _photoBase64!.isNotEmpty),
                                      ),
                                    ),
                                    if (_photoBytes != null ||
                                        (_photoBase64 != null &&
                                            _photoBase64!.isNotEmpty))
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: AppColors.success,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.verified,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (_photoBytes != null ||
                                      (_photoBase64 != null &&
                                          _photoBase64!.isNotEmpty))
                                  ? 'Faculty Photo Attached'
                                  : 'No Profile Photo Assigned',
                              style: AppTypography.labelSm.copyWith(
                                color: (_photoBytes != null ||
                                        (_photoBase64 != null &&
                                            _photoBase64!.isNotEmpty))
                                    ? AppColors.success
                                    : AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      _isPhotoLoading ? null : _takePhoto,
                                  icon: _isPhotoLoading
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt, size: 16),
                                  label: const Text('Take Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed:
                                      _isPhotoLoading ? null : _choosePhoto,
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Choose Photo'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                if (_photoBytes != null ||
                                    (_photoBase64 != null &&
                                        _photoBase64!.isNotEmpty))
                                  TextButton.icon(
                                    onPressed:
                                        _isPhotoLoading ? null : _clearPhoto,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 15,
                                      color: AppColors.error,
                                    ),
                                    label: const Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      Text(
                        'Full Name *',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Dr. Rajesh Sharma',
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter faculty name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Designation
                      Text(
                        'Academic Designation *',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _designationController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Professor & HOD',
                          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter academic designation';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _designationPresets.map((preset) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ActionChip(
                                label: Text(
                                  preset,
                                  style: AppTypography.labelSm.copyWith(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  setState(() {
                                    _designationController.text = preset;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Department
                      Text(
                        'Department / Division *',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _departmentController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Computer Science',
                          prefixIcon: const Icon(Icons.domain_outlined, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter department';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _departmentPresets.map((preset) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ActionChip(
                                label: Text(
                                  preset,
                                  style: AppTypography.labelSm.copyWith(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  setState(() {
                                    _departmentController.text = preset;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Text(
                        'Staff Category',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Teaching Faculty'),
                            selected: _category == 'teaching',
                            onSelected: (val) {
                              if (val) setState(() => _category = 'teaching');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Non-Technical Staff'),
                            selected: _category == 'non-technical',
                            onSelected: (val) {
                              if (val) setState(() => _category = 'non-technical');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Venue / Cabin & Check-In Shift
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Office Cabin / Hall',
                                  style: AppTypography.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _locationController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Turing Block #302',
                                    prefixIcon: const Icon(Icons.room_outlined, size: 20),
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLow,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scheduled Shift / In-Time',
                                  style: AppTypography.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _shiftController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 08:30 AM',
                                    prefixIcon: const Icon(Icons.schedule_outlined, size: 20),
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLow,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Clearance / Attendance Status
                      Text(
                        'Administrative Clearance Status',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            avatar: Icon(
                              Icons.verified,
                              size: 16,
                              color: _status == AttendanceStatus.verified
                                  ? AppColors.onSuccessContainer
                                  : AppColors.secondary,
                            ),
                            label: const Text('Verified / Clear'),
                            selected: _status == AttendanceStatus.verified,
                            selectedColor: AppColors.successContainer,
                            onSelected: (val) {
                              if (val) setState(() => _status = AttendanceStatus.verified);
                            },
                          ),
                          ChoiceChip(
                            avatar: Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: _status == AttendanceStatus.flagged
                                  ? AppColors.onErrorContainer
                                  : AppColors.secondary,
                            ),
                            label: const Text('Flagged / Review'),
                            selected: _status == AttendanceStatus.flagged,
                            selectedColor: AppColors.errorContainer,
                            onSelected: (val) {
                              if (val) setState(() => _status = AttendanceStatus.flagged);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Wi-Fi Enclave
                      Text(
                        'Assigned Wi-Fi Enclave',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _wifiController,
                        decoration: InputDecoration(
                          hintText: 'e.g. SKIT-Campus-5G',
                          prefixIcon: const Icon(Icons.wifi, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Administrative Anomaly / Notes
                      Text(
                        'Administrative Notes / Remarks',
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Approved excursion / Grace entry authorized.',
                          prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face_retouching_natural,
            size: 34,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 2),
          Text(
            'Frontal View',
            style: AppTypography.codeSm.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
