import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_logger.dart';
import '../../features/settings/presentation/settings_provider.dart';
import '../../features/alarm/presentation/alarm_provider.dart';
import '../../features/reminders/presentation/reminders_provider.dart';
import '../../features/profile/presentation/profile_provider.dart';
import '../../features/water/presentation/water_provider.dart';
import '../../features/steps/presentation/step_provider.dart';
import '../../features/bmi/presentation/bmi_provider.dart';
import '../../features/sleep/presentation/sleep_provider.dart';
import '../../features/dashboard/presentation/dashboard_provider.dart';
import '../../features/health_score/presentation/health_score_provider.dart';

/// Coordinator that explicitly handles cross-provider refresh triggers,
/// coalescing duplicate calls within a single frame and preventing circular dependency cycles.
class AppRefreshCoordinator {
  final BuildContext context;

  AppRefreshCoordinator(this.context);

  /// Explicit dependency graph declaring source provider types and their target types.
  static final Map<Type, List<Type>> _refreshGraph = {
    SettingsProvider: [
      DashboardProvider,
      HealthScoreProvider,
      BmiProvider,
      SleepProvider,
      StepProvider,
      WaterProvider,
    ],
    AlarmProvider: [
      DashboardProvider,
      SleepProvider,
    ],
    RemindersProvider: [
      DashboardProvider,
      SleepProvider,
      WaterProvider,
    ],
    ProfileProvider: [
      DashboardProvider,
      HealthScoreProvider,
      BmiProvider,
      SleepProvider,
      StepProvider,
      WaterProvider,
    ],
    WaterProvider: [
      DashboardProvider,
      HealthScoreProvider,
    ],
    StepProvider: [
      DashboardProvider,
      HealthScoreProvider,
    ],
    BmiProvider: [
      DashboardProvider,
      HealthScoreProvider,
    ],
    SleepProvider: [
      DashboardProvider,
      HealthScoreProvider,
    ],
  };

  /// Executes the refresh operation specific to the target type.
  void _refreshTarget(Type targetType) {
    if (targetType == DashboardProvider) {
      context.read<DashboardProvider>().refreshAll();
    } else if (targetType == HealthScoreProvider) {
      context.read<HealthScoreProvider>().refreshAll();
    } else if (targetType == BmiProvider) {
      context.read<BmiProvider>().refreshAll();
    } else if (targetType == SleepProvider) {
      context.read<SleepProvider>().refreshAll();
    } else if (targetType == StepProvider) {
      context.read<StepProvider>().refresh();
    } else if (targetType == WaterProvider) {
      context.read<WaterProvider>().refresh();
    }
  }

  final Set<Type> _dirtySources = {};
  final Set<Type> _refreshedThisFrame = {};
  final List<Type> _activePath = [];
  bool _frameScheduled = false;
  bool _isFlushing = false;

  /// Invoked whenever a source provider notifies its listeners.
  void onSourceNotified(Type sourceType) {
    if (_isFlushing) {
      // Synchronously propagate the updates to targets within the current frame flush
      final targets = _refreshGraph[sourceType] ?? [];
      for (final target in targets) {
        _refreshTargetRecursive(target);
      }
      return;
    }

    _dirtySources.add(sourceType);
    if (!_frameScheduled) {
      _frameScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _flushRefreshes());
    }
  }

  /// Flushes all pending refreshes at the end of the frame.
  void _flushRefreshes() {
    _isFlushing = true;
    _frameScheduled = false;

    _refreshedThisFrame.clear();
    _activePath.clear();

    final sources = Set<Type>.from(_dirtySources);
    _dirtySources.clear();

    try {
      for (final source in sources) {
        final targets = _refreshGraph[source] ?? [];
        for (final target in targets) {
          _refreshTargetRecursive(target);
        }
      }
    } finally {
      _isFlushing = false;
    }
  }

  /// Recursively refreshes target providers, preventing cyclic dependency loops.
  void _refreshTargetRecursive(Type target) {
    if (_activePath.contains(target)) {
      final cycleStr = '${_activePath.join(' -> ')} -> $target';
      AppLogger.error(
        'AppRefreshCoordinator',
        Exception('Circular dependency cascade detected! Cycle path: $cycleStr'),
      );
      return;
    }

    if (_refreshedThisFrame.contains(target)) {
      // Coalesce duplicate refreshes within the same frame
      return;
    }

    _activePath.add(target);
    _refreshedThisFrame.add(target);

    try {
      _refreshTarget(target);
    } catch (e, st) {
      AppLogger.error('AppRefreshCoordinator._refreshTargetRecursive ($target)', e, st);
    } finally {
      _activePath.remove(target);
    }
  }
}

/// A wrapper widget that instantiates the coordinator and binds listeners to all source providers.
class AppRefreshCoordinatorWidget extends StatefulWidget {
  final Widget child;

  const AppRefreshCoordinatorWidget({super.key, required this.child});

  @override
  State<AppRefreshCoordinatorWidget> createState() => _AppRefreshCoordinatorWidgetState();
}

class _AppRefreshCoordinatorWidgetState extends State<AppRefreshCoordinatorWidget> {
  AppRefreshCoordinator? _coordinator;
  final List<VoidCallback> _removeListeners = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _setupCoordinator();
    }
  }

  void _setupCoordinator() {
    final coord = AppRefreshCoordinator(context);
    _coordinator = coord;

    _bindSource<SettingsProvider>(coord);
    _bindSource<AlarmProvider>(coord);
    _bindSource<RemindersProvider>(coord);
    _bindSource<ProfileProvider>(coord);
    _bindSource<WaterProvider>(coord);
    _bindSource<StepProvider>(coord);
    _bindSource<BmiProvider>(coord);
    _bindSource<SleepProvider>(coord);
  }

  void _bindSource<T extends ChangeNotifier>(AppRefreshCoordinator coord) {
    try {
      final provider = Provider.of<T>(context, listen: false);
      void listener() => coord.onSourceNotified(T);
      provider.addListener(listener);
      _removeListeners.add(() => provider.removeListener(listener));
    } catch (e, st) {
      AppLogger.error('AppRefreshCoordinatorWidget.bindSource<$T>', e, st);
    }
  }

  @override
  void dispose() {
    for (final unsubscribe in _removeListeners) {
      unsubscribe();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
