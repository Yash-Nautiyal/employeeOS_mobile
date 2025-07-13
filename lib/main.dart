import 'dart:ui';
import 'package:employeeos/core/theme/app_theme.dart';
import 'package:employeeos/core/theme/bloc/theme_bloc.dart';
import 'package:employeeos/view/layout/presentation/pages/layout.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformDispatcher.instance.onPlatformConfigurationChanged = () {};
  final themeBloc = await ThemeBloc.create();
  await FastCachedImageConfig.init(
      clearCacheAfter: const Duration(days: 7), subDir: 'employeeos');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeBloc),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) => AnimatedTheme(
        data: buildTheme(
          preset: state.preset,
          brightness: state.brightness,
        ),
        duration: const Duration(milliseconds: 100),
        child: MaterialApp(
          title: 'EmployeeOS',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,

          home: const Layout(), // your root screen
        ),
      ),
    );
  }
}
