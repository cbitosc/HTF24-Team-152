import 'package:shared_preferences/shared_preferences.dart';
import 'job_portal_service.dart';

class PortalManager {
  static final PortalManager _instance = PortalManager._internal();
  final JobPortalService _jobPortalService = JobPortalService();
  SharedPreferences? _prefs;

  factory PortalManager() => _instance;

  PortalManager._internal();

  JobPortalService get jobPortalService => _jobPortalService;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeIntegrations();
  }

  Future<void> _initializeIntegrations() async {
    if (_prefs == null) return;

    final linkedInApiKey = _prefs!.getString('linkedin_api_key');
    final linkedInApiSecret = _prefs!.getString('linkedin_api_secret');
    final indeedApiKey = _prefs!.getString('indeed_api_key');

    _jobPortalService.removeIntegration('LinkedIn');
    _jobPortalService.removeIntegration('Indeed');

    if (linkedInApiKey != null && linkedInApiSecret != null) {
      _jobPortalService.registerIntegration(
        LinkedInIntegration(
          apiKey: linkedInApiKey,
          apiSecret: linkedInApiSecret,
        ),
      );
    }

    if (indeedApiKey != null) {
      _jobPortalService.registerIntegration(
        IndeedIntegration(apiKey: indeedApiKey),
      );
    }
  }

  Future<void> saveApiKeys({
    String? linkedInApiKey,
    String? linkedInApiSecret,
    String? indeedApiKey,
  }) async {
    if (_prefs == null) return;

    if (linkedInApiKey != null) {
      await _prefs!.setString('linkedin_api_key', linkedInApiKey);
    }
    if (linkedInApiSecret != null) {
      await _prefs!.setString('linkedin_api_secret', linkedInApiSecret);
    }
    if (indeedApiKey != null) {
      await _prefs!.setString('indeed_api_key', indeedApiKey);
    }

    await _initializeIntegrations();
  }

  Future<Map<String, String?>> getStoredApiKeys() async {
    if (_prefs == null) return {};

    return {
      'linkedin_api_key': _prefs!.getString('linkedin_api_key'),
      'linkedin_api_secret': _prefs!.getString('linkedin_api_secret'),
      'indeed_api_key': _prefs!.getString('indeed_api_key'),
    };
  }

  List<String> get availablePortals => _jobPortalService.availablePortals;

  Future<bool> validateIntegration(String portalName) {
    return _jobPortalService.validateIntegration(portalName);
  }
}
