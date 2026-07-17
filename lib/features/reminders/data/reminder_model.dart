import 'package:hive_ce/hive_ce.dart';

class ReminderModel extends HiveObject {
  final String id; // 'water', 'bedtime', or 'food_<food_id>'
  final String type; // 'water', 'bedtime', 'food'
  final String title;
  final String body;
  bool isEnabled;
  List<int> reminderTimes; // minutes from midnight: [hour * 60 + minute]
  List<int> repeatDays; // 1 = Mon, 7 = Sun (empty means daily)
  bool sound;
  bool vibrate;

  ReminderModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isEnabled = true,
    required this.reminderTimes,
    required this.repeatDays,
    this.sound = true,
    this.vibrate = true,
  });

  ReminderModel copyWith({
    bool? isEnabled,
    List<int>? reminderTimes,
    List<int>? repeatDays,
    bool? sound,
    bool? vibrate,
  }) {
    return ReminderModel(
      id: id,
      type: type,
      title: title,
      body: body,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      repeatDays: repeatDays ?? this.repeatDays,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
    );
  }
}

class ReminderModelAdapter extends TypeAdapter<ReminderModel> {
  @override
  final int typeId = 15;

  @override
  ReminderModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ReminderModel(
      id: fields[0] as String? ?? '',
      type: fields[1] as String? ?? '',
      title: fields[2] as String? ?? '',
      body: fields[3] as String? ?? '',
      isEnabled: fields[4] as bool? ?? true,
      reminderTimes: (fields[5] as List?)?.cast<int>() ?? [],
      repeatDays: (fields[6] as List?)?.cast<int>() ?? [],
      sound: fields[7] as bool? ?? true,
      vibrate: fields[8] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderModel obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.type);
    writer.writeByte(2);
    writer.write(obj.title);
    writer.writeByte(3);
    writer.write(obj.body);
    writer.writeByte(4);
    writer.write(obj.isEnabled);
    writer.writeByte(5);
    writer.write(obj.reminderTimes);
    writer.writeByte(6);
    writer.write(obj.repeatDays);
    writer.writeByte(7);
    writer.write(obj.sound);
    writer.writeByte(8);
    writer.write(obj.vibrate);
  }
}
