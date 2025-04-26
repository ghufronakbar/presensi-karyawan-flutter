import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/constants.dart';
import '../../../data/providers/leave_provider.dart';
import '../../../utils/notification_utils.dart';
import '../../../data/services/profile_service.dart';
import '../../widgets/app_button.dart';

class LeaveFormScreen extends StatefulWidget {
  const LeaveFormScreen({Key? key}) : super(key: key);

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _dateController = TextEditingController();
  
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _selectedLeaveType;
  File? _attachmentFile;
  String? _attachmentUrl;
  
  final ProfileService _profileService = ProfileService();
  final List<String> _leaveTypes = ['Sakit', 'Cuti'];

  @override
  void dispose() {
    _reasonController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)), // Allow backdated leaves
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickAttachment() async {
    if (_isUploadingImage) return;

    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image == null) return;
      
      setState(() {
        _attachmentFile = File(image.path);
        _isUploadingImage = true;
      });

      final result = await _profileService.uploadImage(image.path);
      
      setState(() {
        _isUploadingImage = false;
      });
      
      if (result['success']) {
        setState(() {
          _attachmentUrl = result['url'];
        });
        NotificationUtils.showSuccessToast('Lampiran berhasil diunggah');
      } else {
        NotificationUtils.showErrorToast(
          result['message'] ?? 'Gagal mengunggah lampiran',
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      NotificationUtils.showErrorToast('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate attachment for Sakit type
    if (_selectedLeaveType == 'Sakit' && _attachmentUrl == null) {
      NotificationUtils.showErrorToast('Lampiran wajib untuk cuti sakit');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = Provider.of<LeaveProvider>(context, listen: false);
      
      final result = await provider.requestLeave(
        type: _selectedLeaveType!,
        startDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        reason: _reasonController.text,
        attachment: _attachmentUrl,
      );
      
      if (result['success']) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      NotificationUtils.showErrorToast('Gagal mengajukan cuti: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Cuti'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeaveTypeField(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildReasonField(),
              const SizedBox(height: 16),
              _buildAttachmentField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeaveTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Cuti',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          hint: const Text('Pilih jenis cuti'),
          value: _selectedLeaveType,
          onChanged: (value) {
            setState(() {
              _selectedLeaveType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih jenis cuti';
            }
            return null;
          },
          items: _leaveTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            hintText: 'DD/MM/YYYY',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih tanggal';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alasan Cuti',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            hintText: 'Tulis alasan cuti...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alasan tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Lampiran',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedLeaveType == 'Sakit')
              Text(
                '(Wajib)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (_attachmentFile != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.file(
                        _attachmentFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachmentFile = null;
                            _attachmentUrl = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: _attachmentFile != null
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
                  children: [
                    if (_attachmentFile == null)
                      Expanded(
                        child: Text(
                          'Unggah bukti dokumen',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: _isUploadingImage ? null : _pickAttachment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _attachmentFile != null
                            ? Colors.grey.shade200
                            : AppColors.primary,
                        foregroundColor: _attachmentFile != null
                            ? Colors.black87
                            : Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      icon: _isUploadingImage
                          ? Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(2),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              _attachmentFile != null
                                  ? Icons.edit
                                  : Icons.attachment,
                              size: 20,
                            ),
                      label: Text(
                        _attachmentFile != null ? 'Ubah' : 'Pilih File',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_selectedLeaveType == 'Sakit' && _attachmentUrl == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Lampiran wajib untuk cuti sakit',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return AppButton(
      label: 'Ajukan Cuti',
      isFullWidth: true,
      isLoading: _isLoading,
      onPressed: _submitLeave,
    );
  }
} 