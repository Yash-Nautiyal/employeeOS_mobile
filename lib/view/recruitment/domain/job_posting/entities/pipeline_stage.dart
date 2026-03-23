// ignore_for_file: deprecated_member_use

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
        PipelineStageType.statusOnly => cs.primary.withOpacity(0.1),
        PipelineStageType.interview => cs.onSurface.withOpacity(0.08),
        PipelineStageType.submission => cs.secondary.withOpacity(0.08),
        PipelineStageType.assessment => cs.error.withOpacity(0.08),
      };

  Color resolvedAccent(ColorScheme cs) => switch (this) {
        PipelineStageType.statusOnly => cs.primary,
        PipelineStageType.interview => cs.onSurface,
        PipelineStageType.submission => cs.secondary,
        PipelineStageType.assessment => cs.error,
      };

  String get icon => switch (this) {
        PipelineStageType.statusOnly =>
          'assets/icons/common/duotone/ic-solar-flag-bold-duotone.svg',
        PipelineStageType.interview =>
          'assets/icons/common/duotone/ic-solar-users-group-duotone.svg',
        PipelineStageType.submission =>
          'assets/icons/common/duotone/ic-solar-file-send-bold-duotone.svg',
        PipelineStageType.assessment =>
          'assets/icons/common/duotone/ic-solar-clipboard-duotone.svg',
      };

  String get iconOutline => switch (this) {
        PipelineStageType.statusOnly =>
          'assets/icons/common/outline/ic-solar-flag-outline.svg',
        PipelineStageType.interview =>
          'assets/icons/common/outline/ic-solar-users-group-rounded-outline.svg',
        PipelineStageType.submission =>
          'assets/icons/common/outline/ic-solar-file-send-outline.svg',
        PipelineStageType.assessment =>
          'assets/icons/common/outline/ic-solar-clipboard-outline.svg',
      };
}
