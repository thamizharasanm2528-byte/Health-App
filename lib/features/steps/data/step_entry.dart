import 'package:hive_ce/hive_ce.dart';

/// Model representing steps tracked on a single day.
///
/// Persisted in Hive. Uses manual [TypeAdapter] (typeId = 2) to
/// avoid code generation dependencies.
class StepEntry extends HiveObject {
  /// Unique identifier (usually date formatted as 'yyyy-MM-dd').
  final String id;

  /// Steps counted for the day.
  int steps;

  /// Target steps for the day.
  int goal;

  /// Day timestamp.
  final DateTime date;

  /// True if steps were synced from Health Connect / Apple Health.
  bool isSynced;

  StepEntry({
    required this.id,
    required this.steps,
    required this.goal,
    required this.date,
    this.isSynced = false,
  });

  /// Computed progress fraction (0.0 to 1.0+).
  double get progress => goal > 0 ? steps / goal : 0.0;

  /// Percentage of step goal completed (capped at 999%).
  int get progressPercent => (progress * 100).round().clamp(0, 999);

  /// True if the user hit or exceeded their step goal.
  bool get isGoalAchieved => steps >= goal;
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — manual (typeId = 2)
// ═══════════════════════════════════════════════════════════════════════════

class StepEntryAdapter extends TypeAdapter<StepEntry> {
  @override
  final int typeId = 2;

  @override
  StepEntry read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return StepEntry(
      id: fields[0] as String? ?? '',
      steps: fields[1] as int? ?? 0,
      goal: fields[2] as int? ?? 8000,
      date: DateTime.tryParse(fields[3] as String? ?? '') ?? DateTime.now(),
      isSynced: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, StepEntry obj) {
    writer.writeByte(5); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.steps);
    writer.writeByte(2);
    writer.write(obj.goal);
    writer.writeByte(3);
    writer.write(obj.date.toIso8601String());
    writer.writeByte(4);
    writer.write(obj.isSynced);
  }
}
