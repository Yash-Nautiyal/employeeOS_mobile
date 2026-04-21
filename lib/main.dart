import 'dart:async';

import 'package:employeeos/core/auth/auth_error_handler.dart';
import 'package:employeeos/core/network/remote_data_exception.dart';
import 'package:employeeos/core/routing/app_router.dart';
import 'package:employeeos/core/theme/app_theme.dart';
import 'package:employeeos/core/theme/bloc/theme_bloc.dart';
import 'package:employeeos/core/user/user_account_sync_service.dart';
import 'package:employeeos/core/user/user_creation_service.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/core/auth/data/auth_repository.dart';
import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (AuthErrorHandler.handleUnhandledError(error, stack)) {
        return true;
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
          RepositoryProvider<UserAccountSyncService>(
            create: (context) => UserAccountSyncService(
              context.read<AuthRepository>(),
              context.read<UserInfoService>(),
            ),
          ),
          RepositoryProvider<UserCreationService>(
            create: (context) => UserCreationService(
              context.read<AuthRepository>(),
              context.read<UserInfoService>(),
            ),
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
      return;
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
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouterFactory.create(context.read<AuthBloc>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) => AnimatedTheme(
        data: buildTheme(
          preset: state.preset,
          brightness: state.brightness,
        ),
        duration: const Duration(milliseconds: 100),
        child: MaterialApp.router(
          title: 'EmployeeOS',
          debugShowCheckedModeBanner: false,
          theme: state.themeData,
          routerConfig: _router,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
