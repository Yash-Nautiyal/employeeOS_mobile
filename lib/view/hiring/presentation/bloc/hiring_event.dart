import 'package:equatable/equatable.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';

abstract class HiringEvent extends Equatable {
  const HiringEvent();

  @override
  List<Object?> get props => [];
}

class HiringLoadRequested extends HiringEvent {
  const HiringLoadRequested();
}

class HiringFiltersChanged extends HiringEvent {
  const HiringFiltersChanged(this.filters);
  final HiringFilterParams filters;

  @override
  List<Object?> get props => [filters];
}

class HiringFiltersClearRequested extends HiringEvent {
  const HiringFiltersClearRequested();
}

class HiringRefreshRequested extends HiringEvent {
  const HiringRefreshRequested();
}
