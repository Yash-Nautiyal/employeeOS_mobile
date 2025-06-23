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
  await FastCachedImageConfig.init(
      clearCacheAfter: const Duration(days: 7), subDir: 'employeeos');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) => AnimatedTheme(
          data: state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          duration: const Duration(milliseconds: 100),
          child: MaterialApp(
            title: 'EmployeeOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const Layout(), // your root screen
          ),
        ),
      ),
    );
  }
}
