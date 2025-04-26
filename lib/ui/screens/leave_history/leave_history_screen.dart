import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../constants/constants.dart';
import '../../../data/providers/leave_provider.dart';
import '../../../data/models/leave_model.dart';
import '../../../config/routes_config.dart';

// Define an enum for filter options
enum LeaveFilter {
  all,
  pending,
  approved,
  rejected,
}

extension LeaveFilterExtension on LeaveFilter {
  String get label {
    switch (this) {
      case LeaveFilter.all:
        return 'Semua';
      case LeaveFilter.pending:
        return 'Menunggu';
      case LeaveFilter.approved:
        return 'Diterima';
      case LeaveFilter.rejected:
        return 'Ditolak';
    }
  }
}

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({Key? key}) : super(key: key);

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> with SingleTickerProviderStateMixin {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  LeaveFilter _currentFilter = LeaveFilter.all;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaveHistory();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    
    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentFilter = LeaveFilter.all;
          break;
        case 1:
          _currentFilter = LeaveFilter.pending;
          break;
        case 2:
          _currentFilter = LeaveFilter.approved;
          break;
        case 3:
          _currentFilter = LeaveFilter.rejected;
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadLeaveHistory() {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    provider.getLeaveHistory();
  }

  // Filter leaves based on the current filter
  List<Leave> _getFilteredLeaves(List<Leave> leaves) {
    switch (_currentFilter) {
      case LeaveFilter.all:
        return leaves;
      case LeaveFilter.pending:
        return leaves.where((leave) => leave.status.toLowerCase() == 'pending').toList();
      case LeaveFilter.approved:
        return leaves.where((leave) => 
          leave.status.toLowerCase() == 'approved' || 
          leave.status.toLowerCase() == 'diterima'
        ).toList();
      case LeaveFilter.rejected:
        return leaves.where((leave) => 
          leave.status.toLowerCase() == 'rejected' || 
          leave.status.toLowerCase() == 'ditolak'
        ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Cuti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshLeaveHistory(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.white,
          unselectedLabelColor: const Color.fromARGB(255, 205, 202, 202),          
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Menunggu'),
            Tab(text: 'Diterima'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, _) {
          if (provider.leaves.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredLeaves = _getFilteredLeaves(provider.leaves);

          if (filteredLeaves.isEmpty) {
            return _buildEmptyState(provider.leaves.isEmpty);
          }

          return RefreshIndicator(
            onRefresh: _refreshLeaveHistory,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredLeaves.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredLeaves.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final leave = filteredLeaves[index];
                return _buildLeaveItem(leave);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.leaveForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isCompletelyEmpty 
                  ? 'Belum ada data cuti'
                  : 'Tidak ada data cuti ${_currentFilter.label.toLowerCase()}',
              style: AppTextStyles.heading6.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, Routes.leaveForm);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajukan Cuti'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshLeaveHistory() async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    await provider.getLeaveHistory(refresh: true);
  }

  Widget _buildLeaveItem(Leave leave) {
    // For single date leave, use the same date for both start and end
    final DateTime? startDate = DateTime.tryParse(leave.startDate);
    final DateTime? endDate =
        leave.endDate.isNotEmpty ? DateTime.tryParse(leave.endDate) : startDate;

    final String formattedStartDate =
        startDate != null ? _dateFormat.format(startDate) : leave.startDate;

    final String formattedEndDate = endDate != null
        ? _dateFormat.format(endDate)
        : (leave.endDate.isEmpty ? formattedStartDate : leave.endDate);

    // Get leave type label
    final String leaveType = _getLeaveTypeLabel(leave.type);

    // Format status label
    final String status = _getStatusLabel(leave.status);

    // Get status color
    final Color statusColor = _getStatusColor(leave.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.leaveDetails,
            arguments: {'leaveId': leave.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      leaveType,
                      style: AppTextStyles.heading6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      startDate == endDate || leave.endDate.isEmpty
                          ? formattedStartDate
                          : '$formattedStartDate - $formattedEndDate',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  if (leave.durationDays > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${leave.durationDays} hari',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // if (_canCancel(leave.status)) _buildCancelButton(leave),
            ],
          ),
        ),
      ),
    );
  }

  bool _canCancel(String status) {
    // Check if the leave can be canceled based on status
    return ['pending', 'Pending', 'PENDING'].contains(status);
  }

  String _getStatusLabel(String status) {
    // Format the status label
    switch (status.toLowerCase()) {
      case 'approved':
      case 'diterima':
        return 'DITERIMA';
      case 'pending':
        return 'MENUNGGU';
      case 'rejected':
      case 'ditolak':
        return 'DITOLAK';      
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    // Get status color based on the status
    switch (status.toLowerCase()) {
      case 'approved':
      case 'diterima':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
      case 'ditolak':
        return AppColors.error;
      case 'canceled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildCancelButton(Leave leave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _showCancelConfirmation(leave),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text('Batalkan'),
        ),
      ],
    );
  }

  void _showCancelConfirmation(Leave leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text(
            'Apakah Anda yakin ingin membatalkan pengajuan cuti ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelLeave(leave.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _cancelLeave(String leaveId) async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    await provider.cancelLeaveRequest(leaveId);
  }

  String _getLeaveTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'annual':
      case 'cuti':
        return 'Cuti Tahunan';
      case 'sick':
      case 'sakit':
        return 'Cuti Sakit';
      case 'maternity':
        return 'Cuti Melahirkan';
      case 'marriage':
        return 'Cuti Pernikahan';
      case 'bereavement':
        return 'Cuti Kedukaan';
      case 'unpaid':
        return 'Cuti Tanpa Bayaran';
      default:
        return type;
    }
  }
}
