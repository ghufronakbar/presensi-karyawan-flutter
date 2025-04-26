import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../data/models/overview_model.dart';
import '../../../data/models/user_information_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/attendance_provider.dart';
import '../../../data/providers/overview_provider.dart';
import '../../../data/providers/user_information_provider.dart';
import '../../../config/routes_config.dart';
import '../profile/profile_screen.dart';
import '../attendance_calendar/attendance_calendar_screen.dart';
import '../leave_history/leave_history_screen.dart';
import '../scan_attendance/scan_attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeContent(),
    AttendanceCalendarScreen(),
    LeaveHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Check current attendance status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AttendanceProvider>(context, listen: false)
          .loadTodayAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Kehadiran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Cuti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OverviewProvider>(context, listen: false).getUserOverview();
      Provider.of<UserInformationProvider>(context, listen: false)
          .getUserInformation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final overviewProvider = Provider.of<OverviewProvider>(context);
    final userInfoProvider = Provider.of<UserInformationProvider>(context);

    final user = authProvider.user;
    final overview = overviewProvider.userOverview;
    final userInfo = userInfoProvider.userInformation;

    final bool isLoading =
        overviewProvider.isLoading || userInfoProvider.isLoading;

    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  overviewProvider.getUserOverview(),
                  userInfoProvider.getUserInformation(),
                ]);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(context, user?.name ?? 'Karyawan',
                        user?.position ?? 'Karyawan', user?.image),
                    const SizedBox(height: 20),
                      _buildAttendanceStatusCard(context, overview?.attendance ?? AttendanceOverview(monthlyTotal: 0, attendanceMasuk: '-', attendanceKeluar: '-', lateCount: 0)),
                    const SizedBox(height: 20),
                    if (userInfo != null) _buildWorkTimeCard(context, userInfo),
                    const SizedBox(height: 20),
                    if (overview != null)
                      _buildLeaveBalanceCard(context, overview.leave, userInfo),
                    const SizedBox(height: 20),
                    _buildQuickAction(context, attendanceProvider),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, String name, String position, String? image) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (image != null)
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(image),
              ),
            if (image == null)
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.heading5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.editProfile);
              },
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatusCard(
      BuildContext context, AttendanceOverview attendanceOverview) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Kehadiran Hari Ini',
              style: AppTextStyles.heading6,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Masuk',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        attendanceOverview.attendanceMasuk ?? '-',
                        style: AppTextStyles.heading6.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pulang',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        attendanceOverview.attendanceKeluar ?? '-',
                        style: AppTextStyles.heading6.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanAttendanceScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Absen",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkTimeCard(BuildContext context, UserInformation userInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jam Kerja',
              style: AppTextStyles.heading6,
            ),
            const SizedBox(height: 16),
            _buildTimeInfo(
              context,
              title: 'Jam Masuk',
              time: userInfo.startTime,
              icon: Icons.access_time,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildTimeInfo(
              context,
              title: 'Batas Masuk',
              time: userInfo.endTime,
              icon: Icons.timer_outlined,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildTimeInfo(
              context,
              title: 'Jam Pulang',
              time: userInfo.dismissalTime,
              icon: Icons.access_time_filled,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(
    BuildContext context, {
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaveBalanceCard(
    BuildContext context,
    LeaveOverview leave,
    UserInformation? userInfo,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sisa Cuti',
                  style: AppTextStyles.heading6,
                ),
                if (leave.pending > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pending: ${leave.pending}',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLeaveProgress(
              context,
              title: 'Cuti Tahunan',
              used: leave.workLeave.used,
              total: userInfo?.maxWorkLeave ?? leave.workLeave.limit,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildLeaveProgress(
              context,
              title: 'Cuti Sakit',
              used: leave.sickLeave.used,
              total: userInfo?.maxSickLeave ?? leave.sickLeave.limit,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.leaveForm);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.event_available,
                        color: Colors.teal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ajukan Cuti',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveProgress(
    BuildContext context, {
    required String title,
    required int used,
    required int total,
    required Color color,
  }) {
    final double percentage = total > 0 ? (used / total * 100) : 0;
    final int remaining = total - used;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$used/$total hari',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sisa: $remaining hari',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, AttendanceProvider provider) {
    bool hasCheckedIn = provider.hasCheckedIn;
    bool hasCheckedOut = provider.hasCheckedOut;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Kehadiran',
              style: AppTextStyles.heading6,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceSummaryItem(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Kehadiran Bulan Ini',
                    value: Provider.of<OverviewProvider>(context)
                            .userOverview
                            ?.attendance
                            .monthlyTotal
                            .toString() ??
                        '0',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAttendanceSummaryItem(
                    context,
                    icon: Icons.timer_off_outlined,
                    title: 'Keterlambatan',
                    value: Provider.of<OverviewProvider>(context)
                            .userOverview
                            ?.attendance
                            .lateCount
                            .toString() ??
                        '0',
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
