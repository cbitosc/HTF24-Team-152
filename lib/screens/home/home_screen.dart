import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart' as colors;
import '../../core/constants/app_strings.dart' as strings;
import '../../core/utils/search_delegate.dart';
import '../../models/job_application_model.dart';
import '../../providers/application_provider.dart';
import '../../services/integrations/portal_manager.dart';
import '../../widgets/application_card.dart';
import '../applications/add_application_screen.dart';
import '../applications/application_detail_screen.dart';
import '../settings/portal_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';
  String? _selectedPortalFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ApplicationProvider>(context, listen: false)
            .loadApplications());
  }

  void _deleteApplication(JobApplication application) async {
    if (application.id == null) return;

    try {
      await Provider.of<ApplicationProvider>(context, listen: false)
          .deleteApplication(application.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(strings.AppStrings.deleteSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(strings.AppStrings.error)),
        );
      }
    }
  }

  Widget _buildFilterChips() {
    final statuses = ['All', ...ApplicationStatus.getAllStatuses()];
    final portalManager = PortalManager();
    final availablePortals = portalManager.availablePortals;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...statuses.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: _selectedFilter == status,
                  label: Text(status),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = status;
                      _selectedPortalFilter = null;
                    });
                  },
                ),
              )),
          if (availablePortals.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: VerticalDivider(width: 1),
            ),
            ...availablePortals.map((portal) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedPortalFilter == portal,
                    label: Text('From $portal'),
                    onSelected: (selected) {
                      setState(() {
                        _selectedPortalFilter = selected ? portal : null;
                        _selectedFilter = 'All';
                      });
                    },
                  ),
                )),
          ],
        ],
      ),
    );
  }

  List<JobApplication> _filterApplications(List<JobApplication> applications) {
    return applications.where((app) {
      if (_selectedPortalFilter != null) {
        return app.jobPortalSource == _selectedPortalFilter;
      }
      if (_selectedFilter == 'All') {
        return true;
      }
      return app.status == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(strings.AppStrings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final applications =
                  Provider.of<ApplicationProvider>(context, listen: false)
                      .applications;
              final selected = await showSearch(
                context: context,
                delegate: ApplicationSearchDelegate(
                  applications: applications,
                  onDelete: _deleteApplication,
                ),
              );
              if (selected != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ApplicationDetailScreen(application: selected),
                  ),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PortalSettingsScreen(),
                    ),
                  );
                  break;
                case 'import':
                  _showImportDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Job Portal Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download, size: 20),
                    SizedBox(width: 8),
                    Text('Import Applications'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.applications.isEmpty) {
            return const Center(
              child: Text(strings.AppStrings.noApplications),
            );
          }

          final filteredApplications =
              _filterApplications(provider.applications);

          return Column(
            children: [
              _buildStatusOverview(provider.statusCounts),
              const Divider(),
              _buildFilterChips(),
              const SizedBox(height: 8),
              Expanded(
                child: filteredApplications.isEmpty
                    ? const Center(
                        child:
                            Text('No applications match the selected filter'),
                      )
                    : ListView.builder(
                        itemCount: filteredApplications.length,
                        itemBuilder: (context, index) {
                          final application = filteredApplications[index];
                          return ApplicationCard(
                            application: application,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ApplicationDetailScreen(
                                    application: application,
                                  ),
                                ),
                              );
                            },
                            onDelete: () => _deleteApplication(application),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddApplicationScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Application'),
      ),
    );
  }

  Widget _buildStatusOverview(Map<String, int> statusCounts) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ApplicationStatus.getAllStatuses().map((status) {
          return _buildStatusCard(status, statusCounts[status] ?? 0);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusCard(String status, int count) {
    Color statusColor;
    switch (status) {
      case ApplicationStatus.applied:
        statusColor = colors.AppColors.applied;
        break;
      case ApplicationStatus.interviewing:
        statusColor = colors.AppColors.interviewing;
        break;
      case ApplicationStatus.offered:
        statusColor = colors.AppColors.offered;
        break;
      case ApplicationStatus.rejected:
        statusColor = colors.AppColors.rejected;
        break;
      default:
        statusColor = colors.AppColors.primary;
    }

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 80,
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog() {
    final portalManager = PortalManager();
    final availablePortals = portalManager.availablePortals;

    if (availablePortals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure job portal settings first'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Applications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import applications from:'),
            const SizedBox(height: 16),
            ...availablePortals.map((portal) => ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: Text(portal),
                  onTap: () async {
                    Navigator.pop(context);
                    // Here you would implement the actual import logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Importing from $portal...'),
                      ),
                    );
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
