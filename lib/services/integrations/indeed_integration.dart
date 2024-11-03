import '../../models/job_application_model.dart';
import 'base_integration.dart';

class IndeedIntegration implements JobPortalIntegration {
  final String apiKey;

  IndeedIntegration({required this.apiKey});

  @override
  String get portalName => 'Indeed';

  @override
  Future<JobApplication> parseApplication(Map<String, dynamic> data) async {
    return JobApplication(
      company: data['company'] ?? '',
      position: data['position'] ?? '',
      status: ApplicationStatus.applied,
      applicationDate: DateTime.now(),
      jobPortalSource: portalName,
      jobPortalUrl: data['url'],
      jobPortalId: data['jobKey'],
      additionalData: {
        'indeedJobKey': data['jobKey'],
        'location': data['location'],
      },
    );
  }

  @override
  Future<bool> validateCredentials() async {
    return apiKey.isNotEmpty;
  }
}