import 'dart:async';

import 'package:employeeos/core/auth/auth_error_handler.dart';
import 'package:employeeos/core/network/remote_data_exception.dart';
import 'package:employeeos/core/theme/app_theme.dart';
import 'package:employeeos/core/theme/bloc/theme_bloc.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/core/auth/data/auth_repository.dart';
import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/view/home/presentation/pages/home_view.dart';
import 'package:employeeos/view/layout/presentation/pages/layout.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (AuthErrorHandler.handleUnhandledError(error, stack)) {
        return true; // Handled; error is not propagated.
      }
      if (error is RemoteDataException) {
        if (kDebugMode) {
          debugPrint('[RemoteDataException] ${error.message}');
        }
        return true;
      }
      FlutterError.presentError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
      // We reported it; prevent default handler from double-reporting.
      return true;
    };

    PlatformDispatcher.instance.onPlatformConfigurationChanged = () {};
    await dotenv.load(fileName: '.env');
    await supabase.Supabase.initialize(
      url: dotenv.env['VITE_SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['VITE_SUPABASE_ANON_KEY'] ?? '',
    );
    final themeBloc = await ThemeBloc.create();
    await FastCachedImageConfig.init(
      clearCacheAfter: const Duration(days: 7),
      subDir: 'employeeos',
    );
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (_) => AuthRepository(supabase.Supabase.instance.client),
          ),
          RepositoryProvider<UserInfoService>(
            create: (_) => UserInfoService(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: themeBloc),
            BlocProvider(
              create: (context) => AuthBloc(
                context.read<AuthRepository>(),
                context.read<UserInfoService>(),
              ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  }, (Object error, StackTrace stack) {
    if (AuthErrorHandler.handleUnhandledError(error, stack)) {
      return; // Handled; do not rethrow.
    }
    if (error is RemoteDataException) {
      if (kDebugMode) {
        debugPrint('[RemoteDataException] ${error.message}');
      }
      return;
    }
    FlutterError.presentError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  });
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
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Unauthenticated) {
                return const HomeView();
              }
              if (authState is Authenticated) {
                return const Layout();
              }
              return const Layout();
            },
          ),
        ),
      ),
    );
  }
}
