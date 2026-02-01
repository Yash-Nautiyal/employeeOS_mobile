import 'dart:ui';
import 'package:employeeos/core/theme/app_theme.dart';
import 'package:employeeos/core/theme/bloc/theme_bloc.dart';
import 'package:employeeos/view/auth/presentation/bloc/auth_bloc.dart';
import 'package:employeeos/view/auth/presentation/pages/auth_view.dart';
import 'package:employeeos/view/home/presentation/pages/home_view.dart';
import 'package:employeeos/view/layout/presentation/pages/layout.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformDispatcher.instance.onPlatformConfigurationChanged = () {};
  await dotenv.load(fileName: '.env');
  await supabase.Supabase.initialize(
    url: dotenv.env['VITE_SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['VITE_SUPABASE_ANON_KEY'] ?? '',
  );
  final themeBloc = await ThemeBloc.create();
  await FastCachedImageConfig.init(
      clearCacheAfter: const Duration(days: 7), subDir: 'employeeos');
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeBloc),
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return const Layout();
              } else if (authState is Unauthenticated) {
                return const HomeView();
              }
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            },
          ),
        ),
      ),
    );
  }
}
