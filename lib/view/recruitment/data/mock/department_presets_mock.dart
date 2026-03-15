import 'package:employeeos/view/recruitment/domain/entities/pipeline_stage.dart';

/// Mock department preset pipelines and stage pool (no backend).
/// When HR selects a department, the preset is loaded; they can then add/delete/reorder.

const String _shortlist = 'Shortlist';
const String _telephone = 'Telephone';
const String _taskSubmit = 'Task Submit';
const String _technical = 'Technical';
const String _onboarding = 'Onboarding';
const String _assessment = 'Assessment';

int _idCounter = 0;
String nextPipelineStageId() => 'stage-${_idCounter++}';

PipelineStage _stage(String id, String name, PipelineStageType type) {
  return PipelineStage(id: id, name: name, type: type);
}

/// All department names (built-in presets + custom added via Add Department).
List<String> getAllDepartmentNames() {
  return [..._presets.keys, ..._customPresets.keys];
}

/// Preset pipeline for a department. Returns a new list each time (caller can mutate).
List<PipelineStage> getPresetForDepartment(String departmentName) {
  var list = _presets[departmentName];
  list ??= _customPresets[departmentName];
  if (list == null) return [];
  return list.map((s) => s.copyWith(id: nextPipelineStageId())).toList();
}

/// All departments that have a preset (built-in only).
List<String> get departmentNamesWithPresets => _presets.keys.toList();

/// Custom departments added via Add Department page (mutable).
final Map<String, List<PipelineStage>> _customPresets = {};

/// Register a new department and its pipeline (from Add Department page).
void addDepartment(String name, List<PipelineStage> pipeline) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return;
  if (_presets.containsKey(trimmed) || _customPresets.containsKey(trimmed)) {
    return;
  }
  _customPresets[trimmed] =
      pipeline.map((s) => s.copyWith(id: nextPipelineStageId())).toList();
}

/// Stage pool: stages that can be inserted into a pipeline (for "Add from pool").
/// Use [PipelineStage.copyWith(id: nextPipelineStageId())] when adding to pipeline.
List<PipelineStage> getStagePool() {
  return [
    _stage('pool-shortlist', _shortlist, PipelineStageType.statusOnly),
    _stage('pool-telephone', _telephone, PipelineStageType.interview),
    _stage('pool-task-submit', _taskSubmit, PipelineStageType.submission),
    _stage('pool-technical', _technical, PipelineStageType.interview),
    _stage('pool-onboarding', _onboarding, PipelineStageType.interview),
    _stage('pool-assessment', _assessment, PipelineStageType.assessment),
  ];
}

List<PipelineStage> _list(
  PipelineStage a,
  PipelineStage b,
  PipelineStage c, [
  PipelineStage? d,
  PipelineStage? e,
]) {
  return [a, b, c, if (d != null) d, if (e != null) e];
}

final Map<String, List<PipelineStage>> _presets = {
  'Engineering': _list(
    _stage('e1', _shortlist, PipelineStageType.statusOnly),
    _stage('e2', _telephone, PipelineStageType.interview),
    _stage('e3', _taskSubmit, PipelineStageType.submission),
    _stage('e4', _technical, PipelineStageType.interview),
    _stage('e5', _onboarding, PipelineStageType.interview),
  ),
  'Marketing': _list(
    _stage('m1', _shortlist, PipelineStageType.statusOnly),
    _stage('m2', _telephone, PipelineStageType.interview),
    _stage('m3', _technical, PipelineStageType.interview),
    _stage('m4', _onboarding, PipelineStageType.interview),
  ),
  'Tech': _list(
    _stage('t1', _shortlist, PipelineStageType.statusOnly),
    _stage('t2', _telephone, PipelineStageType.interview),
    _stage('t3', _taskSubmit, PipelineStageType.submission),
    _stage('t4', _technical, PipelineStageType.interview),
    _stage('t5', _onboarding, PipelineStageType.interview),
  ),
  'Product': _list(
    _stage('p1', _shortlist, PipelineStageType.statusOnly),
    _stage('p2', _telephone, PipelineStageType.interview),
    _stage('p3', _technical, PipelineStageType.interview),
    _stage('p4', _onboarding, PipelineStageType.interview),
  ),
  'Design': _list(
    _stage('d1', _shortlist, PipelineStageType.statusOnly),
    _stage('d2', _telephone, PipelineStageType.interview),
    _stage('d3', _taskSubmit, PipelineStageType.submission),
    _stage('d4', _onboarding, PipelineStageType.interview),
  ),
  'Operations': _list(
    _stage('o1', _shortlist, PipelineStageType.statusOnly),
    _stage('o2', _telephone, PipelineStageType.interview),
    _stage('o3', _onboarding, PipelineStageType.interview),
  ),
  'HR': _list(
    _stage('h1', _shortlist, PipelineStageType.statusOnly),
    _stage('h2', _telephone, PipelineStageType.interview),
    _stage('h3', _technical, PipelineStageType.interview),
    _stage('h4', _onboarding, PipelineStageType.interview),
  ),
  'Sales': _list(
    _stage('s1', _shortlist, PipelineStageType.statusOnly),
    _stage('s2', _telephone, PipelineStageType.interview),
    _stage('s3', _onboarding, PipelineStageType.interview),
  ),
  'Support': _list(
    _stage('u1', _shortlist, PipelineStageType.statusOnly),
    _stage('u2', _telephone, PipelineStageType.interview),
    _stage('u3', _onboarding, PipelineStageType.interview),
  ),
};
