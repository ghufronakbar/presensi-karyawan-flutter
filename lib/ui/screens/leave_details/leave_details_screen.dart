import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../data/providers/leave_provider.dart';
import '../../../data/models/leave_model.dart';
import '../../widgets/app_button.dart';

class LeaveDetailsScreen extends StatelessWidget {
  final String leaveId;

  const LeaveDetailsScreen({
    Key? key,
    required this.leaveId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cuti'),
        centerTitle: true,
      ),
      body: FutureBuilder<Leave?>(
        future: Provider.of<LeaveProvider>(context, listen: false)
            .getLeaveDetails(leaveId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Data cuti tidak ditemukan'),
            );
          }

          final leave = snapshot.data!;
          return _buildLeaveDetails(context, leave);
        },
      ),
    );
  }

  Widget _buildLeaveDetails(BuildContext context, Leave leave) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(leave),
          const SizedBox(height: 16),
          _buildDetailsCard(leave),
          const SizedBox(height: 16),
          if (leave.status == 'pending') _buildActionButtons(context, leave),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Leave leave) {
    Color statusColor;
    String statusText;

    switch (leave.status.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.success;
        statusText = 'Disetujui';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Ditolak';
        break;
      case 'pending':
      default:
        statusColor = AppColors.warning;
        statusText = 'Menunggu Persetujuan';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            leave.status.toLowerCase() == 'approved'
                ? Icons.check_circle
                : leave.status.toLowerCase() == 'rejected'
                    ? Icons.cancel
                    : Icons.access_time,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: AppTextStyles.bodyLarge.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Leave leave) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Jenis Cuti', leave.type),
          _buildDetailItem('Tanggal Mulai', leave.startDate),
          _buildDetailItem('Tanggal Selesai', leave.endDate),
          _buildDetailItem('Durasi', '${leave.durationDays} hari'),
          _buildDetailItem('Alasan', leave.reason, isLast: leave.attachment == null),
          if(leave.attachment != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Lampiran', "", isLast: true),
                Image.network(leave.attachment!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge,
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Leave leave) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Batalkan',
            isOutlined: true,
            onPressed: () => _showCancelConfirmation(context),
          ),
        ),
      ],
    );
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pengajuan Cuti'),
        content: const Text(
            'Apakah Anda yakin ingin membatalkan pengajuan cuti ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<LeaveProvider>(context, listen: false)
            .cancelLeaveRequest(leaveId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengajuan cuti berhasil dibatalkan')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membatalkan cuti: $e')),
          );
        }
      }
    }
  }
}
