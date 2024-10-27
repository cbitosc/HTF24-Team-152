
import 'package:flutter/material.dart';
import '../models/job_application_model.dart';
import '../core/constants/app_colors.dart' as colors;

class StatusChip extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusChip({
    super.key,
    required this.status,
    this.fontSize,
  });

  Color _getStatusColor() {
    switch (status) {
      case ApplicationStatus.applied:
        return colors.AppColors.applied;
      case ApplicationStatus.interviewing:
        return colors.AppColors.interviewing;
      case ApplicationStatus.offered:
        return colors.AppColors.offered;
      case ApplicationStatus.rejected:
        return colors.AppColors.rejected;
      default:
        return colors.AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
