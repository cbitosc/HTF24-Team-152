import '../../models/job_application_model.dart';

abstract class JobPortalIntegration {
  Future<JobApplication> parseApplication(Map<String, dynamic> data);
  Future<bool> validateCredentials();
  String get portalName;
}