import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

class FacultyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onDashboardPressed;
  final VoidCallback? onAttendancePressed;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onLeavePressed;

  const FacultyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onDashboardPressed,
    this.onAttendancePressed,
    this.onHistoryPressed,
    this.onLeavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: AppTypography.labelSm.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4F46E5),
        ),
        unselectedLabelStyle: AppTypography.labelSm.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
        onTap: (index) {
          if (index == currentIndex) return;
          switch (index) {
            case 0:
              onDashboardPressed?.call();
              break;
            case 1:
              onAttendancePressed?.call();
              break;
            case 2:
              onHistoryPressed?.call();
              break;
            case 3:
              onLeavePressed?.call();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg_outlined),
            activeIcon: Icon(Icons.how_to_reg),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_busy_outlined),
            activeIcon: Icon(Icons.event_busy),
            label: 'Leave',
          ),
        ],
      ),
    );
  }
}
