import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final Widget? icon;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: isOutlined 
          ? Colors.transparent 
          : (backgroundColor ?? AppColors.primary),
      foregroundColor: isOutlined 
          ? (textColor ?? AppColors.primary)
          : (textColor ?? Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutlined 
            ? BorderSide(color: backgroundColor ?? AppColors.primary)
            : BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: Size(isFullWidth ? double.infinity : 120, height),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading
          ? _buildLoadingIndicator()
          : _buildButtonContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon == null) {
      return Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isOutlined ? AppColors.primary : Colors.white,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isOutlined ? AppColors.primary : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 