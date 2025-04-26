import 'package:flutter/material.dart';
import 'package:presensi_karyawan/utils/storage_utils.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../utils/validation_utils.dart';
import '../../../utils/notification_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = true;

  bool _autoValidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  void checkToken() async {
    setState(() {
      _isLoading = true;
    });
    final token = await StorageUtils.getSecureData(AppConstants.tokenKey);
    print("token: $token");
    if (token != null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildForm(authProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 100,
          width: 100,
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Silakan login untuk melanjutkan',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Email',
          hint: 'Masukkan email anda',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          isRequired: true,
          validator: ValidationUtils.validateEmail,
          focusNode: _emailFocusNode,
          textInputAction: TextInputAction.next,
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Password',
          hint: 'Masukkan password anda',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          isRequired: true,
          validator: ValidationUtils.validatePassword,
          focusNode: _passwordFocusNode,
          textInputAction: TextInputAction.done,
          onEditingComplete: () {
            _handleLogin(authProvider);
          },
        ),
        if (authProvider.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              authProvider.errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Login',
          isLoading: authProvider.isLoading,
          isFullWidth: true,
          onPressed: () => _handleLogin(authProvider),
        ),
      ],
    );
  }

  void _handleLogin(AuthProvider authProvider) async {
    // Clear previous errors
    authProvider.clearError();

    // Set autovalidate flag
    setState(() {
      _autoValidate = true;
    });

    // Validate form
    if (_formKey.currentState?.validate() == true) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Attempt login
      final success = await authProvider.login(email, password);

      if (success) {
        // Navigate to home screen or show success notification
        NotificationUtils.showSuccessToast('Login berhasil');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Show error notification
        NotificationUtils.showErrorToast(
            authProvider.errorMessage ?? 'Login gagal');
      }
    }
  }
}
