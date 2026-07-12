import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/services/notifications/notification_service.dart';
import 'core/services/notifications/notification_model.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_provider.dart';
import 'features/profile/data/profile_local_data_source.dart';
import 'features/profile/data/profile_model.dart';
import 'features/profile/data/profile_repository_impl.dart';
import 'features/profile/presentation/profile_provider.dart';
import 'features/steps/data/health_service.dart';
import 'features/steps/data/step_entry.dart';
import 'features/steps/data/step_local_data_source.dart';
import 'features/steps/data/step_repository_impl.dart';
import 'features/steps/presentation/step_provider.dart';
import 'features/water/data/water_entry.dart';
import 'features/water/data/water_local_data_source.dart';
import 'features/water/data/water_repository_impl.dart';
import 'features/water/presentation/water_provider.dart';
import 'features/bmi/data/bmi_entry.dart';
import 'features/bmi/data/bmi_local_data_source.dart';
import 'features/bmi/data/bmi_repository_impl.dart';
import 'features/bmi/presentation/bmi_provider.dart';
import 'features/sleep/data/sleep_record.dart';
import 'features/sleep/data/sleep_local_data_source.dart';
import 'features/sleep/data/sleep_repository_impl.dart';
import 'features/sleep/presentation/sleep_provider.dart';
import 'features/settings/data/settings_model.dart';
import 'features/settings/data/settings_repository_impl.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/settings/presentation/theme_provider.dart';
import 'features/settings/presentation/units_provider.dart';
import 'features/health_score/presentation/health_score_provider.dart';
import 'features/alarm/data/alarm_settings_model.dart';
import 'features/alarm/presentation/alarm_provider.dart';
import 'features/reminders/data/reminder_model.dart';
import 'features/reminders/presentation/reminders_provider.dart';
import 'features/splash/presentation/interactive_initialization_screen.dart';
import 'package:alarm/alarm.dart';

/// Cached SharedPreferences singleton — initialised once in main(),
/// available synchronously throughout the app lifecycle.
late final SharedPreferences sharedPrefs;

/// Health Companion — Application Entry Point
///
/// Starts immediately to render the interactive aesthetic initialization screen,
/// run background initialization in the background, and transition smoothly.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set the app to full-screen mode to fit the screen size of all mobile devices properly
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const HealthCompanionApp());
}

Future<Box<T>> _safeOpenBox<T>(String name) async {
  try {
    return await Hive.openBox<T>(name);
  } catch (e) {
    if (kDebugMode) {
      print('Hive openBox error for "$name": $e. Deleting and recreating...');
    }
    try {
      await Hive.deleteBoxFromDisk(name);
    } catch (_) {}
    return await Hive.openBox<T>(name);
  }
}

/// Root widget of the Health Companion application.
class HealthCompanionApp extends StatefulWidget {
  const HealthCompanionApp({super.key});

  @override
  State<HealthCompanionApp> createState() => _HealthCompanionAppState();
}

class _HealthCompanionAppState extends State<HealthCompanionApp> {
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Setup Global Error Boundaries & Releases Protection
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          print('Flutter UI Frame Error: ${details.exceptionAsString()}');
        }
      };

      // Phase 1: Parallelize plugin initialization
      final results = await Future.wait<Object?>([
        (() async {
          try {
            await Alarm.init();
          } catch (e) {
            if (kDebugMode) {
              print('Warning: Alarm.init() failed: $e');
            }
          }
        })(),
        Hive.initFlutter(),
        SharedPreferences.getInstance(),
      ]);

      sharedPrefs = results[2] as SharedPreferences;

      // Phase 2: Register Hive Adapters
      Hive.registerAdapter(ProfileModelAdapter());
      Hive.registerAdapter(WaterEntryAdapter());
      Hive.registerAdapter(StepEntryAdapter());
      Hive.registerAdapter(BMIEntryAdapter());
      Hive.registerAdapter(SleepRecordAdapter());
      Hive.registerAdapter(NotificationModelAdapter());
      Hive.registerAdapter(SettingsModelAdapter());
      Hive.registerAdapter(AlarmSettingsModelAdapter());
      Hive.registerAdapter(ReminderModelAdapter());

      // Phase 3: Open boxes concurrently
      await Future.wait([
        _safeOpenBox<ProfileModel>(ProfileLocalDataSource.boxName),
        _safeOpenBox<WaterEntry>(WaterLocalDataSource.boxName),
        _safeOpenBox<StepEntry>(StepLocalDataSource.boxName),
        _safeOpenBox<BMIEntry>(BmiLocalDataSource.boxName),
        _safeOpenBox<SleepRecord>(SleepLocalDataSource.boxName),
        _safeOpenBox<NotificationModel>(NotificationService.boxName),
        _safeOpenBox<SettingsModel>(SettingsRepositoryImpl.boxName),
        _safeOpenBox<String>('theme_prefs_box'),
        _safeOpenBox<AlarmSettingsModel>(AlarmProvider.boxName),
        _safeOpenBox<ReminderModel>(RemindersProvider.boxName),
        Hive.openBox('app_state'),
      ]);

      // Phase 4: Init Notification Service
      try {
        await NotificationService.instance.init();
      } catch (e) {
        if (kDebugMode) {
          print('Warning: NotificationService.init() failed: $e');
        }
      }

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F9F68),
            brightness: Brightness.light,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We encountered an issue preparing the app:\n$_initError\n\nTap retry to attempt resetting local database layers.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _initError = null;
                      });
                      _initApp();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Interactive Initialization Loader (Aesthetic particles + ripples + pulse logo)
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F9F68),
            brightness: Brightness.light,
          ),
        ),
        home: const InteractiveInitializationScreen(),
      );
    }

    // Main App with full Provider capabilities once databases are verified open
    final profileDataSource = ProfileLocalDataSource();
    final waterDataSource = WaterLocalDataSource();
    final stepDataSource = StepLocalDataSource();
    final bmiDataSource = BmiLocalDataSource();
    final sleepDataSource = SleepLocalDataSource();
    final healthService = HealthService();
    final settingsRepo = SettingsRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final p = SettingsProvider(settingsRepo);
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<HealthScoreProvider>(context, listen: false).refreshAll();
                    Provider.of<BmiProvider>(context, listen: false).refreshAll();
                    Provider.of<SleepProvider>(context, listen: false).refreshAll();
                    Provider.of<StepProvider>(context, listen: false).refresh();
                    Provider.of<WaterProvider>(context, listen: false).refresh();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = AlarmProvider();
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<SleepProvider>(context, listen: false).refreshAll();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = RemindersProvider();
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<SleepProvider>(context, listen: false).refreshAll();
                    Provider.of<WaterProvider>(context, listen: false).refresh();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(settingsRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => UnitsProvider(settingsRepo),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = ProfileProvider(
               ProfileRepositoryImpl(profileDataSource),
            );
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<HealthScoreProvider>(context, listen: false).refreshAll();
                    Provider.of<BmiProvider>(context, listen: false).refreshAll();
                    Provider.of<SleepProvider>(context, listen: false).refreshAll();
                    Provider.of<StepProvider>(context, listen: false).refresh();
                    Provider.of<WaterProvider>(context, listen: false).refresh();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = WaterProvider(
              WaterRepositoryImpl(waterDataSource),
              profileDataSource,
            );
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<HealthScoreProvider>(context, listen: false).refreshAll();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = StepProvider(
              StepRepositoryImpl(stepDataSource),
              profileDataSource,
              healthService,
            );
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<HealthScoreProvider>(context, listen: false).refreshAll();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = BmiProvider(
              BmiRepositoryImpl(bmiDataSource),
              profileDataSource,
            );
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<HealthScoreProvider>(context, listen: false).refreshAll();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final p = SleepProvider(
              SleepRepositoryImpl(sleepDataSource),
              profileDataSource,
            );
            p.addListener(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  try {
                    Provider.of<DashboardProvider>(context, listen: false).refreshAll();
                    Provider.of<HealthScoreProvider>(context, listen: false).refreshAll();
                  } catch (_) {}
                }
              });
            });
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            profileDataSource,
            waterDataSource,
            stepDataSource,
            sleepDataSource,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthScoreProvider(
            profileDataSource: profileDataSource,
            waterRepository: WaterRepositoryImpl(waterDataSource),
            stepRepository: StepRepositoryImpl(stepDataSource),
            sleepRepository: SleepRepositoryImpl(sleepDataSource),
            bmiRepository: BmiRepositoryImpl(bmiDataSource),
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProv, settingsProv, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            child: MaterialApp(
              key: const ValueKey('health_companion_main_app'),
              navigatorKey: globalNavigatorKey,
              title: 'Health Companion',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getTheme(
                brightness: Brightness.light,
                accentColor: themeProv.accentColor,
              ),
              darkTheme: AppTheme.getTheme(
                brightness: Brightness.dark,
                accentColor: themeProv.accentColor,
              ),
              themeMode: themeProv.themeMode,
              builder: (context, child) {
                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                  statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ));
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(settingsProv.textScaleFactor),
                  ),
                  child: child!,
                );
              },
              initialRoute: RouteNames.splash,
              onGenerateRoute: AppRouter.onGenerateRoute,
            ),
          );
        },
      ),
    );
  }
}
