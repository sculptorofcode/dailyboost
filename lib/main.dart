import 'package:dailyboost/core/navigation/app_navigation.dart';
import 'package:dailyboost/core/utils/play_services_utils.dart';
import 'package:dailyboost/core/widgets/exit_confirmation_wrapper.dart';
import 'package:dailyboost/features/quotes/data/repositories/quote_repository.dart';
import 'package:dailyboost/features/quotes/logic/bloc/favorites/favorites_bloc.dart';
import 'package:dailyboost/features/quotes/logic/bloc/home/home_bloc.dart';
import 'package:dailyboost/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/constants.dart';
import 'features/auth/logic/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // First check if Google Play Services is available
  bool playServicesAvailable = false;
  try {
    playServicesAvailable = await PlayServicesUtils.checkPlayServices();
    debugPrint("Google Play Services available: $playServicesAvailable");

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    debugPrint("Supabase initialized successfully");
  } catch (e) {
    debugPrint("Error checking Play Services availability: $e");
  }

  // Initialize Firebase with proper error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
    // Continue app initialization even if Firebase fails
    // This prevents app crashes on devices without Google Play Services
  }
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox<String>('favorite_quotes');
  await Hive.openBox<String>('cached_quotes');
  await Hive.openBox<String>('frequent_quotes');
  await Hive.openBox<String>('app_settings');

  // Initialize QuoteRepository
  final quoteRepository = QuoteRepository();
  await quoteRepository.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<FavoritesBloc>(create: (_) => FavoritesBloc()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(            title: AppConstants.appName,
            theme: AppTheme.getTheme(false),
            darkTheme: AppTheme.getTheme(true),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              return ExitConfirmationWrapper(child: child);
            },
            // Let the AppNavigator handle the navigation
            home: const AppNavigator(),
          );
        },
      ),
    );
  }
}
