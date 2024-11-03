import 'package:flutter/material.dart';
import '../../models/job_application_model.dart';
import '../../widgets/application_card.dart';
import '../constants/app_strings.dart';

class ApplicationSearchDelegate extends SearchDelegate<JobApplication?> {
  final List<JobApplication> applications;
  final Function(JobApplication) onDelete;

  ApplicationSearchDelegate({
    required this.applications,
    required this.onDelete,
  });

  @override
  String get searchFieldLabel => 'Search applications...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredApplications = applications.where((application) {
      final lowercaseQuery = query.toLowerCase();
      return application.company.toLowerCase().contains(lowercaseQuery) ||
          application.position.toLowerCase().contains(lowercaseQuery) ||
          application.status.toLowerCase().contains(lowercaseQuery);
    }).toList();

    if (filteredApplications.isEmpty) {
      return const Center(
        child: Text(AppStrings.noApplications),
      );
    }

    return ListView.builder(
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final application = filteredApplications[index];
        return ApplicationCard(
          application: application,
          onTap: () => close(context, application),
          onDelete: () => onDelete(application),
        );
      },
    );
  }
}
