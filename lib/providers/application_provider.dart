import 'package:flutter/foundation.dart';
import '../models/job_application_model.dart';
import '../core/utils/database_helper.dart';

class ApplicationProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<JobApplication> _applications = [];
  Map<String, int> _statusCounts = {};

  List<JobApplication> get applications => _applications;
  Map<String, int> get statusCounts => _statusCounts;

  Future<void> loadApplications() async {
    _applications = await _dbHelper.getAllApplications();
    _statusCounts = await _dbHelper.getStatusCounts();
    notifyListeners();
  }

  Future<void> addApplication(JobApplication application) async {
    await _dbHelper.insertApplication(application);
    await loadApplications();
  }

  Future<void> updateApplication(JobApplication application) async {
    if (application.id == null) {
      throw Exception('Cannot update application without an ID');
    }
    await _dbHelper.updateApplication(application);
    await loadApplications();
  }

  Future<void> deleteApplication(int id) async {
    await _dbHelper.deleteApplication(id);
    await loadApplications();
  }
}
