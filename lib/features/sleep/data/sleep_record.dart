import 'package:hive/hive.dart';

/// Represents a single logged sleep record.
class SleepRecord extends HiveObject {
  /// Unique identifier (timestamp string).
  final String id;

  /// Time when the user went to sleep.
  final DateTime bedtime;

  /// Time when the user woke up.
  final DateTime wakeTime;

  /// Calculated duration of sleep in hours.
  final double durationHours;

  /// Sleep quality status (Excellent, Good, Needs Improvement).
  final String status;

  SleepRecord({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.durationHours,
    required this.status,
  });

  /// Factory to generate a new record with an automated ID.
  factory SleepRecord.create({
    required DateTime bedtime,
    required DateTime wakeTime,
    required double durationHours,
    required String status,
  }) {
    return SleepRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bedtime: bedtime,
      wakeTime: wakeTime,
      durationHours: durationHours,
      status: status,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — written manually (typeId = 4)
// ═══════════════════════════════════════════════════════════════════════════

class SleepRecordAdapter extends TypeAdapter<SleepRecord> {
  @override
  final int typeId = 4;

  @override
  SleepRecord read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SleepRecord(
      id: fields[0] as String? ?? '',
      bedtime: DateTime.tryParse(fields[1] as String? ?? '') ?? DateTime.now(),
      wakeTime: DateTime.tryParse(fields[2] as String? ?? '') ?? DateTime.now(),
      durationHours: fields[3] as double? ?? 8.0,
      status: fields[4] as String? ?? 'Good',
    );
  }

  @override
  void write(BinaryWriter writer, SleepRecord obj) {
    writer.writeByte(5); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.bedtime.toIso8601String());
    writer.writeByte(2);
    writer.write(obj.wakeTime.toIso8601String());
    writer.writeByte(3);
    writer.write(obj.durationHours);
    writer.writeByte(4);
    writer.write(obj.status);
  }
}
