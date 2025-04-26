import 'package:flutter/material.dart';
import 'package:presensi_karyawan/data/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:presensi_karyawan/ui/screens/login/login_screen.dart';
import '../../../constants/constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../utils/notification_utils.dart';
import '../../widgets/app_button.dart';
import 'edit_profile_screen.dart';
import '../change_password/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    // Load user profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    final user = profileProvider.user ?? authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(context),
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(user?.name ?? 'Karyawan'),
                  const SizedBox(height: 24),
                  _buildProfileInfo(user),
                  const SizedBox(height: 24),
                  _buildButtons(context, authProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(String name) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.user;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: user?.image != null && user!.image!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    user.image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 50,
                ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: AppTextStyles.heading4,
        ),
      ],
    );
  }

  Widget _buildProfileInfo(user) {
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
            _buildInfoItem('ID Karyawan', user?.staffNumber ?? '-'),
            _buildInfoItem('Posisi', user?.position ?? '-'),
            _buildInfoItem('Email', user?.email ?? '-', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (!isLast) const Divider(),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        AppButton(
          label: 'Edit Profil',
          isFullWidth: true,
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEditProfile(context),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Edit Password',
          onPressed: () => _navigateToEditPassword(context),
          icon: const Icon(Icons.password),
          isFullWidth: true,
          isOutlined: true,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Logout',
          isOutlined: true,
          isFullWidth: true,
          icon: const Icon(Icons.logout),
          onPressed: () => _handleLogout(context, authProvider),
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    ).then((_) {
      // Refresh profile data when returning from edit screen
      Provider.of<ProfileProvider>(context, listen: false).getUserProfile();
    });
  }

  void _navigateToEditPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => AuthService().logout().then((value) {
              if (value['success']) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              }
            }),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await authProvider.logout();

      if (success) {
        NotificationUtils.showSuccessToast('Berhasil logout');
      } else {
        NotificationUtils.showErrorToast(
          authProvider.errorMessage ?? 'Gagal logout',
        );
      }
    }
  }
}
