import 'dart:ui';

import 'package:analyzer/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/bindings/core_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/services/hive_service.dart';
import 'data/services/preferences_service.dart';
import 'presentation/screens/startup/startup_error_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Single funnel for uncaught async errors; plug a crash reporter in here.
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      'Uncaught error',
      name: 'main',
      error: error.runtimeType,
      stackTrace: stack,
    );
    return true;
  };

  try {
    await _bootstrap();
  } catch (e, st) {
    AppLogger.error(
      'Startup failed',
      name: 'main',
      error: e.runtimeType,
      stackTrace: st,
    );
    runApp(const StartupErrorApp());
    return;
  }

  runApp(const MyApp());
}

Future<void> _bootstrap() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Hive.initFlutter();
  await HiveService.init();
  await PreferencesService.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Personal Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: CoreBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
