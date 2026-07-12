import 'package:hive/hive.dart';

/// Persisted configuration for the wake-up alarm.
class AlarmSettingsModel extends HiveObject {
  int id;
  bool isEnabled;
  int hour;
  int minute;
  List<int> repeatDays; // 1 = Mon, 7 = Sun
  int snoozeDurationMinutes;
  bool vibrate;
  bool sound;
  String label;
  bool isPrimaryWakeup;

  AlarmSettingsModel({
    int? id,
    this.isEnabled = false,
    this.hour = 7,
    this.minute = 0,
    List<int>? repeatDays,
    this.snoozeDurationMinutes = 10,
    this.vibrate = true,
    this.sound = true,
    this.label = 'Wake-up Alarm',
    this.isPrimaryWakeup = false,
  })  : id = id ?? (DateTime.now().millisecondsSinceEpoch & 0xfffffff),
        repeatDays = repeatDays ?? [];

  AlarmSettingsModel copyWith({
    int? id,
    bool? isEnabled,
    int? hour,
    int? minute,
    List<int>? repeatDays,
    int? snoozeDurationMinutes,
    bool? vibrate,
    bool? sound,
    String? label,
    bool? isPrimaryWakeup,
  }) {
    return AlarmSettingsModel(
      id: id ?? this.id,
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      snoozeDurationMinutes: snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      vibrate: vibrate ?? this.vibrate,
      sound: sound ?? this.sound,
      label: label ?? this.label,
      isPrimaryWakeup: isPrimaryWakeup ?? this.isPrimaryWakeup,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — manual (typeId = 14)
// ═══════════════════════════════════════════════════════════════════════════

class AlarmSettingsModelAdapter extends TypeAdapter<AlarmSettingsModel> {
  @override
  final int typeId = 14;

  @override
  AlarmSettingsModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AlarmSettingsModel(
      isEnabled: fields[0] as bool? ?? false,
      hour: fields[1] as int? ?? 7,
      minute: fields[2] as int? ?? 0,
      repeatDays: (fields[3] as List?)?.cast<int>() ?? [],
      snoozeDurationMinutes: fields[4] as int? ?? 10,
      vibrate: fields[5] as bool? ?? true,
      sound: fields[6] as bool? ?? true,
      id: fields[7] as int?,
      label: fields[8] as String? ?? 'Wake-up Alarm',
      isPrimaryWakeup: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmSettingsModel obj) {
    writer.writeByte(10);
    writer.writeByte(0);
    writer.write(obj.isEnabled);
    writer.writeByte(1);
    writer.write(obj.hour);
    writer.writeByte(2);
    writer.write(obj.minute);
    writer.writeByte(3);
    writer.write(obj.repeatDays);
    writer.writeByte(4);
    writer.write(obj.snoozeDurationMinutes);
    writer.writeByte(5);
    writer.write(obj.vibrate);
    writer.writeByte(6);
    writer.write(obj.sound);
    writer.writeByte(7);
    writer.write(obj.id);
    writer.writeByte(8);
    writer.write(obj.label);
    writer.writeByte(9);
    writer.write(obj.isPrimaryWakeup);
  }
}
