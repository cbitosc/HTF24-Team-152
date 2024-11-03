import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_application_model.dart';
import '../../providers/application_provider.dart';
import '../../core/constants/app_colors.dart' as colors;
import '../../core/constants/app_strings.dart' as strings;
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_chip.dart';

class AddApplicationScreen extends StatefulWidget {
  final JobApplication? application;

  const AddApplicationScreen({
    super.key, 
    this.application,
  });

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _company;
  late String _position;
  late String _status;
  String? _notes;
  late DateTime _applicationDate;

  @override
  void initState() {
    super.initState();
    _company = widget.application?.company ?? '';
    _position = widget.application?.position ?? '';
    _status = widget.application?.status ?? ApplicationStatus.applied;
    _notes = widget.application?.notes;
    _applicationDate = widget.application?.applicationDate ?? DateTime.now();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        final application = JobApplication(
          id: widget.application?.id,
          company: _company,
          position: _position,
          status: _status,
          applicationDate: _applicationDate,
          notes: _notes?.isNotEmpty == true ? _notes : null,
        );

        if (widget.application == null) {
          await Provider.of<ApplicationProvider>(context, listen: false)
              .addApplication(application);
        } else {
          await Provider.of<ApplicationProvider>(context, listen: false)
              .updateApplication(application);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(strings.AppStrings.savedSuccess),
              backgroundColor: colors.AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(strings.AppStrings.error),
              backgroundColor: colors.AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _applicationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: colors.AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: colors.AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _applicationDate) {
      setState(() {
        _applicationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.application == null
                ? strings.AppStrings.addApplication
                : strings.AppStrings.editApplication,
          ),
          backgroundColor: colors.AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInput(
                    label: strings.AppStrings.company,
                    initialValue: _company,
                    validator: (value) => value?.isEmpty ?? true 
                        ? strings.AppStrings.companyRequired 
                        : null,
                    onSaved: (value) => _company = value!,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: strings.AppStrings.position,
                    initialValue: _position,
                    validator: (value) => value?.isEmpty ?? true 
                        ? strings.AppStrings.positionRequired 
                        : null,
                    onSaved: (value) => _position = value!,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.AppColors.primary.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          strings.AppStrings.status,
                          style: TextStyle(
                            color: colors.AppColors.text.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _status,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 2,
                            style: const TextStyle(
                              color: colors.AppColors.text,
                              fontSize: 16,
                            ),
                            items: ApplicationStatus.getAllStatuses()
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    StatusChip(
                                      status: value,
                                      fontSize: 12,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _status = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.AppColors.primary.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.AppStrings.applicationDate,
                                style: TextStyle(
                                  color: colors.AppColors.text.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_applicationDate.day}/${_applicationDate.month}/${_applicationDate.year}',
                                style: const TextStyle(
                                  color: colors.AppColors.text,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: colors.AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    label: strings.AppStrings.notes,
                    initialValue: _notes,
                    maxLines: 5,
                    onSaved: (value) => _notes = value,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: strings.AppStrings.save,
                    onPressed: _submitForm,
                    isLoading: _isLoading,
                  ),
                  if (widget.application != null) ...[
                    const SizedBox(height: 12),
                    CustomButton(
                      text: strings.AppStrings.cancel,
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
