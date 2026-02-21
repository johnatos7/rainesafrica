class ReturnReasonEntity {
  final String reasonId;
  final String title;
  final List<PreferredOutcomeEntity> preferredOutcomes;
  final List<SubReasonEntity>? subReasons;

  const ReturnReasonEntity({
    required this.reasonId,
    required this.title,
    required this.preferredOutcomes,
    this.subReasons,
  });

  factory ReturnReasonEntity.fromJson(Map<String, dynamic> json) {
    return ReturnReasonEntity(
      reasonId: json['reason_id'] as String,
      title: json['title'] as String,
      preferredOutcomes:
          (json['preferred_outcomes'] as List<dynamic>)
              .map((outcome) => PreferredOutcomeEntity.fromJson(outcome))
              .toList(),
      subReasons:
          json['sub_reasons'] != null
              ? (json['sub_reasons'] as List<dynamic>)
                  .map((subReason) => SubReasonEntity.fromJson(subReason))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason_id': reasonId,
      'title': title,
      'preferred_outcomes': preferredOutcomes.map((e) => e.toJson()).toList(),
      'sub_reasons': subReasons?.map((e) => e.toJson()).toList(),
    };
  }
}

class PreferredOutcomeEntity {
  final String outcomeId;
  final String title;

  const PreferredOutcomeEntity({required this.outcomeId, required this.title});

  factory PreferredOutcomeEntity.fromJson(Map<String, dynamic> json) {
    return PreferredOutcomeEntity(
      outcomeId: json['outcome_id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'outcome_id': outcomeId, 'title': title};
  }
}

class SubReasonEntity {
  final int subReasonId;
  final String title;

  const SubReasonEntity({required this.subReasonId, required this.title});

  factory SubReasonEntity.fromJson(Map<String, dynamic> json) {
    return SubReasonEntity(
      subReasonId: json['sub_reason_id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sub_reason_id': subReasonId, 'title': title};
  }
}
