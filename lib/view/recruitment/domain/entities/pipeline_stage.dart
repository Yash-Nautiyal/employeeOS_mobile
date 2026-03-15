import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Type of a pipeline stage (from Stage Action Types design).
enum PipelineStageType {
  statusOnly,
  interview,
  submission,
  assessment;

  String get displayName {
    switch (this) {
      case PipelineStageType.statusOnly:
        return 'Status only';
      case PipelineStageType.interview:
        return 'Interview';
      case PipelineStageType.submission:
        return 'Submission';
      case PipelineStageType.assessment:
        return 'Assessment';
    }
  }
}

/// A single stage in a recruitment pipeline (preset or job-specific).
class PipelineStage extends Equatable {
  const PipelineStage({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final PipelineStageType type;

  PipelineStage copyWith({String? id, String? name, PipelineStageType? type}) {
    return PipelineStage(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, name, type];
}

extension StageTypeX on PipelineStageType {
  Color resolvedColor(ColorScheme cs) => switch (this) {
        PipelineStageType.statusOnly => cs.primary.withValues(alpha: 0.15),
        PipelineStageType.interview => cs.tertiary.withValues(alpha: 0.15),
        PipelineStageType.submission => cs.secondary.withValues(alpha: 0.15),
        PipelineStageType.assessment => cs.error.withValues(alpha: 0.15),
      };

  Color resolvedAccent(ColorScheme cs) => switch (this) {
        PipelineStageType.statusOnly => cs.primary,
        PipelineStageType.interview => cs.tertiary,
        PipelineStageType.submission => cs.secondary,
        PipelineStageType.assessment => cs.error,
      };

  String get icon => switch (this) {
        PipelineStageType.statusOnly =>
          'assets/icons/common/solid/ic-solar-flag-bold.svg',
        PipelineStageType.interview =>
          'assets/icons/common/solid/ic-solar_users-group-rounded-bold.svg',
        PipelineStageType.submission =>
          'assets/icons/common/solid/ic-solar-file-send-bold.svg',
        PipelineStageType.assessment =>
          'assets/icons/common/solid/ic-solar-clipboard.svg',
      };
}
