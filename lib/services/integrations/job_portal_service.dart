export 'linkedin_integration.dart';
export 'indeed_integration.dart';
export 'base_integration.dart';
import '../../models/job_application_model.dart';
import 'base_integration.dart';

class JobPortalService {
  final Map<String, JobPortalIntegration> _integrations = {};

  void registerIntegration(JobPortalIntegration integration) {
    _integrations[integration.portalName] = integration;
  }

  void removeIntegration(String portalName) {
    _integrations.remove(portalName);
  }

  Future<JobApplication> importApplication(String portalName, Map<String, dynamic> applicationData) async {
    final integration = _integrations[portalName];
    if (integration == null) {
      throw Exception('No integration found for portal: $portalName');
    }
    return await integration.parseApplication(applicationData);
  }

  List<String> get availablePortals => _integrations.keys.toList();

  bool hasIntegration(String portalName) => _integrations.containsKey(portalName);

  Future<bool> validateIntegration(String portalName) async {
    final integration = _integrations[portalName];
    if (integration == null) {
      return false;
    }
    return await integration.validateCredentials();
  }
}