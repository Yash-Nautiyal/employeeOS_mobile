import 'package:employeeos/view/hiring/data/datasources/hiring_remote_datasource.dart';
import 'package:employeeos/view/hiring/data/repositories/hiring_repository_impl.dart';
import 'package:employeeos/view/hiring/domain/usecases/get_hiring_dashboard.dart';
import 'package:employeeos/view/hiring/domain/usecases/get_hiring_hr_options.dart';
import 'package:employeeos/view/hiring/domain/usecases/get_hiring_job_options.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_bloc.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_event.dart';
import 'package:employeeos/view/hiring/presentation/pages/hiring_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HiringPage extends StatelessWidget {
  const HiringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = HiringRepositoryImpl(
      HiringRemoteDatasource(Supabase.instance.client),
    );

    return BlocProvider(
      create: (_) => HiringBloc(
        getHiringDashboard: GetHiringDashboard(repository),
        getHiringJobOptions: GetHiringJobOptions(repository),
        getHiringHrOptions: GetHiringHrOptions(repository),
      )..add(const HiringLoadRequested()),
      child: const HiringView(),
    );
  }
}
