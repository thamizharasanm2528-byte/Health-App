import 'package:hive_ce/hive_ce.dart';

/// Represents metadata for a scheduled notification/reminder.
class NotificationModel extends HiveObject {
  final int id;
  final String title;
  final String body;
  final String notificationType; // water, bedtime, wakeup, food, walk, weight, report
  DateTime? scheduledDate;
  final String repeatType; // none, daily, weekly, hourly, custom
  bool isEnabled;
  final String? payload;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationType,
    this.scheduledDate,
    this.repeatType = 'none',
    this.isEnabled = true,
    this.payload,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationModel copyWith({
    String? title,
    String? body,
    DateTime? scheduledDate,
    bool? isEnabled,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      notificationType: notificationType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      repeatType: repeatType,
      isEnabled: isEnabled ?? this.isEnabled,
      payload: payload,
      createdAt: createdAt,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — written manually (typeId = 7)
// ═══════════════════════════════════════════════════════════════════════════

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 7;

  @override
  NotificationModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return NotificationModel(
      id: fields[0] as int? ?? 0,
      title: fields[1] as String? ?? '',
      body: fields[2] as String? ?? '',
      notificationType: fields[3] as String? ?? 'water',
      scheduledDate: fields[4] != null ? DateTime.tryParse(fields[4].toString()) : null,
      repeatType: fields[5] as String? ?? 'none',
      isEnabled: fields[6] as bool? ?? true,
      payload: fields[7] as String?,
      createdAt: fields[8] != null ? (DateTime.tryParse(fields[8].toString()) ?? DateTime.now()) : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer.writeByte(9); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.body);
    writer.writeByte(3);
    writer.write(obj.notificationType);
    writer.writeByte(4);
    writer.write(obj.scheduledDate?.toIso8601String());
    writer.writeByte(5);
    writer.write(obj.repeatType);
    writer.writeByte(6);
    writer.write(obj.isEnabled);
    writer.writeByte(7);
    writer.write(obj.payload);
    writer.writeByte(8);
    writer.write(obj.createdAt.toIso8601String());
  }
}
