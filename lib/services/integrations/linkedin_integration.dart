import '../../models/job_application_model.dart';
import 'base_integration.dart';

class LinkedInIntegration implements JobPortalIntegration {
  final String apiKey;
  final String apiSecret;

  LinkedInIntegration({
    required this.apiKey,
    required this.apiSecret,
  });

  @override
  String get portalName => 'LinkedIn';

  @override
  Future<JobApplication> parseApplication(Map<String, dynamic> data) async {
    return JobApplication(
      company: data['company'] ?? '',
      position: data['position'] ?? '',
      status: ApplicationStatus.applied,
      applicationDate: DateTime.now(),
      jobPortalSource: portalName,
      jobPortalUrl: data['jobUrl'],
      jobPortalId: data['jobId'],
      additionalData: {
        'linkedInCompanyId': data['companyId'],
        'applicationMethod': data['applicationMethod'],
      },
    );
  }

  @override
  Future<bool> validateCredentials() async {
    return apiKey.isNotEmpty && apiSecret.isNotEmpty;
  }
}