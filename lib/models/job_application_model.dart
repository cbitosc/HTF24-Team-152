class JobApplication {
  final int? id;
  final String company;
  final String position;
  final String status;
  final DateTime applicationDate;
  final String? notes;
  final String? jobPortalSource; // e.g., 'LinkedIn', 'Indeed'
  final String? jobPortalUrl; // Original job posting URL
  final String? jobPortalId; // Job ID from the portal
  final Map<String, dynamic>? additionalData; // For portal-specific data

  JobApplication({
    this.id,
    required this.company,
    required this.position,
    required this.status,
    required this.applicationDate,
    this.notes,
    this.jobPortalSource,
    this.jobPortalUrl,
    this.jobPortalId,
    this.additionalData,
  });

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'] as int?,
      company: map['company'] as String,
      position: map['position'] as String,
      status: map['status'] as String,
      applicationDate: DateTime.parse(map['applicationDate'] as String),
      notes: map['notes'] as String?,
      jobPortalSource: map['jobPortalSource'] as String?,
      jobPortalUrl: map['jobPortalUrl'] as String?,
      jobPortalId: map['jobPortalId'] as String?,
      additionalData: map['additionalData'] != null
          ? Map<String, dynamic>.from(map['additionalData'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'company': company,
      'position': position,
      'status': status,
      'applicationDate': applicationDate.toIso8601String(),
      'notes': notes,
      'jobPortalSource': jobPortalSource,
      'jobPortalUrl': jobPortalUrl,
      'jobPortalId': jobPortalId,
      'additionalData': additionalData,
    };
  }
}

class ApplicationStatus {
  static const String applied = 'Applied';
  static const String interviewing = 'Interview';
  static const String offered = 'Offered';
  static const String rejected = 'Rejected';

  static List<String> getAllStatuses() {
    return [applied, interviewing, offered, rejected];
  }
}
