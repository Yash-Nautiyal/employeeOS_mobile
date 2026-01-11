import 'package:equatable/equatable.dart';
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';

class KanbanState extends Equatable {
  final bool isLoading;
  final List<KanbanColumn> columns;
  final String? error;

  const KanbanState({
    required this.isLoading,
    required this.columns,
    this.error,
  });

  factory KanbanState.initial() =>
      const KanbanState(isLoading: true, columns: [], error: null);

  KanbanState copyWith({
    bool? isLoading,
    List<KanbanColumn>? columns,
    String? error,
  }) {
    return KanbanState(
      isLoading: isLoading ?? this.isLoading,
      columns: columns ?? this.columns,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, columns, error];
}
