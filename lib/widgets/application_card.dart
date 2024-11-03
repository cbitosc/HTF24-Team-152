import 'package:flutter/material.dart';
import '../models/job_application_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart' as date_utils;

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (application.status) {
      case ApplicationStatus.applied:
        return AppColors.applied;
      case ApplicationStatus.interviewing:
        return AppColors.interviewing;
      case ApplicationStatus.offered:
        return AppColors.offered;
      case ApplicationStatus.rejected:
        return AppColors.rejected;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                application.company,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (application.jobPortalSource != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.jobPortalSource!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(application.position),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    application.status,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  date_utils.DateUtils.getRelativeTime(
                      application.applicationDate),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          color: Colors.grey,
        ),
      ),
    );
  }
}
