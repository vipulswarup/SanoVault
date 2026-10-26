class PatientCaseSummary {
  const PatientCaseSummary({
    required this.text,
    required this.generatedAt,
    required this.stale,
  });
  final String text;
  final String generatedAt;
  final bool stale;
  factory PatientCaseSummary.fromJson(Map<String, dynamic> json) =>
      PatientCaseSummary(
        text: json['text'] as String? ?? '',
        generatedAt: json['generatedAt'] as String? ?? '',
        stale: json['stale'] == true,
      );
}

class PatientTopic {
  const PatientTopic({
    required this.tag,
    required this.count,
    required this.weight,
  });
  final String tag;
  final int count;
  final double weight;
  factory PatientTopic.fromJson(Map<String, dynamic> json) => PatientTopic(
    tag: json['tag'] as String,
    count: (json['count'] as num).toInt(),
    weight: (json['weight'] as num).toDouble().clamp(0, 1),
  );
}

class PatientTimelineEntry {
  const PatientTimelineEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.detail,
    required this.kind,
    this.recordId,
    this.dateIsUpload = false,
  });
  final String id, date, title, detail, kind;
  final String? recordId;
  final bool dateIsUpload;
  factory PatientTimelineEntry.fromJson(Map<String, dynamic> json) =>
      PatientTimelineEntry(
        id: json['id'] as String,
        date: json['date'] as String? ?? '',
        title: json['title'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        kind: json['kind'] as String,
        recordId: json['recordId'] as String?,
        dateIsUpload: json['dateIsUpload'] == true,
      );
}

class PatientPathologyEntry {
  const PatientPathologyEntry({
    required this.label,
    required this.latest,
    required this.date,
    required this.status,
    required this.trend,
    required this.recordId,
    this.previous,
    this.previousDate,
    this.reference,
  });
  final String label, latest, date, status, trend, recordId;
  final String? previous, previousDate, reference;
  factory PatientPathologyEntry.fromJson(Map<String, dynamic> json) =>
      PatientPathologyEntry(
        label: json['label'] as String,
        latest: json['latest'] as String,
        date: json['date'] as String,
        status: json['status'] as String,
        trend: json['trend'] as String,
        recordId: json['recordId'] as String,
        previous: json['previous'] as String?,
        previousDate: json['previousDate'] as String?,
        reference: json['reference'] as String?,
      );
}

class PatientOverviewData {
  PatientOverviewData._(
    this.json,
    this.patientId,
    this.name,
    this.tags,
    this.timeline,
    this.pathology,
    this.caseSummary,
    this.hasEvidence,
  );
  final Map<String, dynamic> json;
  final String patientId, name;
  final List<PatientTopic> tags;
  final List<PatientTimelineEntry> timeline;
  final List<PatientPathologyEntry> pathology;
  final PatientCaseSummary? caseSummary;
  final bool hasEvidence;
  factory PatientOverviewData.fromJson(Map<String, dynamic> json) {
    final patient = Map<String, dynamic>.from(json['patient'] as Map);
    List<T> rows<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List? ?? [])
            .whereType<Map>()
            .map((row) => parse(Map<String, dynamic>.from(row)))
            .toList();
    return PatientOverviewData._(
      json,
      patient['id'] as String,
      patient['name'] as String? ?? '',
      rows('tags', PatientTopic.fromJson),
      rows('timeline', PatientTimelineEntry.fromJson),
      rows('pathology', PatientPathologyEntry.fromJson),
      json['caseSummary'] is Map
          ? PatientCaseSummary.fromJson(
              Map<String, dynamic>.from(json['caseSummary'] as Map),
            )
          : null,
      json['hasEvidence'] == true,
    );
  }
}
