import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../utils/notification_utils.dart';
import '../../widgets/app_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;
  bool _imageUploading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize form fields with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      _fetchUserProfile(profileProvider);
    });
  }

  Future<void> _fetchUserProfile(ProfileProvider provider) async {
    await provider.getUserProfile();
    final user = provider.user;
    
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: profileProvider.isLoading && !_isLoading && !_imageUploading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context, profileProvider),
    );
  }
  
  Widget _buildForm(BuildContext context, ProfileProvider profileProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePicture(profileProvider.user, profileProvider),
            const SizedBox(height: 24),
            _buildInputFields(),
            const SizedBox(height: 32),
            _buildSaveButton(context, profileProvider),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfilePicture(User? user, ProfileProvider profileProvider) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(
                  child: _getProfileImage(user, profileProvider),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _imageUploading ? null : _handleUploadPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _imageUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _imageUploading ? null : _handleUploadPhoto,
            child: const Text('Ubah Foto'),
          ),
        ],
      ),
    );
  }
  
  Widget _getProfileImage(User? user, ProfileProvider profileProvider) {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          _imageFile!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else if (profileProvider.uploadedImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          profileProvider.uploadedImageUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 50,
          ),
        ),
      );
    } else if (user?.image != null && user!.image!.isNotEmpty) {
      return ClipRRect(
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
      );
    } else {
      return const Icon(
        Icons.person,
        color: AppColors.primary,
        size: 50,
      );
    }
  }
  
  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama lengkap',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Email',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Masukkan email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Masukkan email yang valid';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildSaveButton(BuildContext context, ProfileProvider profileProvider) {
    return AppButton(
      label: 'Simpan Perubahan',
      isFullWidth: true,
      isLoading: _isLoading,
      onPressed: () => _handleSave(context, profileProvider),
    );
  }
  
  Future<void> _handleUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image == null) return;
      
      setState(() {
        _imageFile = File(image.path);
        _imageUploading = true;
      });

      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final result = await profileProvider.uploadImage(image.path);
      
      setState(() {
        _imageUploading = false;
      });
      
      if (!result['success']) {
        NotificationUtils.showErrorToast(
          result['message'] ?? 'Gagal mengupload gambar',
        );
      }
    } catch (e) {
      setState(() {
        _imageUploading = false;
      });
      NotificationUtils.showErrorToast('Gagal memilih gambar: ${e.toString()}');
    }
  }
  
  Future<void> _handleSave(BuildContext context, ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final result = await profileProvider.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (result['success']) {
      NotificationUtils.showSuccessToast('Profil berhasil diperbarui');
      Navigator.pop(context);
    } else {
      NotificationUtils.showErrorToast(
        result['message'] ?? 'Gagal memperbarui profil',
      );
    }
  }
} 