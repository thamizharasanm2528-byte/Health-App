import 'package:hive_ce/hive_ce.dart';

/// User settings and preferences model persisted via Hive.
class SettingsModel extends HiveObject {
  String themeMode; // system, light, dark
  String fontSize; // small, medium, large
  String weightUnit; // kg, lbs
  String heightUnit; // cm, ft
  String waterUnit; // liters, ml, oz
  bool masterNotificationsEnabled;

  bool waterNotificationsEnabled;
  bool foodNotificationsEnabled;
  bool bedtimeNotificationsEnabled;
  bool wakeupNotificationsEnabled;
  bool reportNotificationsEnabled;

  // Sound and Vibration granular settings
  bool waterVibrationEnabled;
  bool waterSoundEnabled;
  bool foodVibrationEnabled;
  bool foodSoundEnabled;
  bool bedtimeVibrationEnabled;
  bool bedtimeSoundEnabled;
  bool wakeupVibrationEnabled;
  bool wakeupSoundEnabled;

  SettingsModel({
    this.themeMode = 'system',
    this.fontSize = 'medium',
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.waterUnit = 'ml',
    this.masterNotificationsEnabled = true,
    this.waterNotificationsEnabled = true,
    this.foodNotificationsEnabled = true,
    this.bedtimeNotificationsEnabled = true,
    this.wakeupNotificationsEnabled = true,
    this.reportNotificationsEnabled = true,
    this.waterVibrationEnabled = true,
    this.waterSoundEnabled = true,
    this.foodVibrationEnabled = true,
    this.foodSoundEnabled = true,
    this.bedtimeVibrationEnabled = true,
    this.bedtimeSoundEnabled = true,
    this.wakeupVibrationEnabled = true,
    this.wakeupSoundEnabled = true,
  });

  SettingsModel copyWith({
    String? themeMode,
    String? fontSize,
    String? weightUnit,
    String? heightUnit,
    String? waterUnit,
    bool? masterNotificationsEnabled,
    bool? waterNotificationsEnabled,
    bool? foodNotificationsEnabled,
    bool? bedtimeNotificationsEnabled,
    bool? wakeupNotificationsEnabled,
    bool? reportNotificationsEnabled,
    bool? waterVibrationEnabled,
    bool? waterSoundEnabled,
    bool? foodVibrationEnabled,
    bool? foodSoundEnabled,
    bool? bedtimeVibrationEnabled,
    bool? bedtimeSoundEnabled,
    bool? wakeupVibrationEnabled,
    bool? wakeupSoundEnabled,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      waterUnit: waterUnit ?? this.waterUnit,
      masterNotificationsEnabled: masterNotificationsEnabled ?? this.masterNotificationsEnabled,
      waterNotificationsEnabled: waterNotificationsEnabled ?? this.waterNotificationsEnabled,
      foodNotificationsEnabled: foodNotificationsEnabled ?? this.foodNotificationsEnabled,
      bedtimeNotificationsEnabled: bedtimeNotificationsEnabled ?? this.bedtimeNotificationsEnabled,
      wakeupNotificationsEnabled: wakeupNotificationsEnabled ?? this.wakeupNotificationsEnabled,
      reportNotificationsEnabled: reportNotificationsEnabled ?? this.reportNotificationsEnabled,
      waterVibrationEnabled: waterVibrationEnabled ?? this.waterVibrationEnabled,
      waterSoundEnabled: waterSoundEnabled ?? this.waterSoundEnabled,
      foodVibrationEnabled: foodVibrationEnabled ?? this.foodVibrationEnabled,
      foodSoundEnabled: foodSoundEnabled ?? this.foodSoundEnabled,
      bedtimeVibrationEnabled: bedtimeVibrationEnabled ?? this.bedtimeVibrationEnabled,
      bedtimeSoundEnabled: bedtimeSoundEnabled ?? this.bedtimeSoundEnabled,
      wakeupVibrationEnabled: wakeupVibrationEnabled ?? this.wakeupVibrationEnabled,
      wakeupSoundEnabled: wakeupSoundEnabled ?? this.wakeupSoundEnabled,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — written manually (typeId = 8)
// ═══════════════════════════════════════════════════════════════════════════

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 8;

  @override
  SettingsModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SettingsModel(
      themeMode: fields[0] as String? ?? 'system',
      fontSize: fields[1] as String? ?? 'medium',
      weightUnit: fields[2] as String? ?? 'kg',
      heightUnit: fields[3] as String? ?? 'cm',
      waterUnit: fields[4] as String? ?? 'ml',
      masterNotificationsEnabled: fields[5] as bool? ?? true,
      waterNotificationsEnabled: fields[6] as bool? ?? true,
      foodNotificationsEnabled: fields[7] as bool? ?? true,
      bedtimeNotificationsEnabled: fields[8] as bool? ?? true,
      wakeupNotificationsEnabled: fields[9] as bool? ?? true,
      reportNotificationsEnabled: fields[10] as bool? ?? true,
      waterVibrationEnabled: fields[11] as bool? ?? true,
      waterSoundEnabled: fields[12] as bool? ?? true,
      foodVibrationEnabled: fields[13] as bool? ?? true,
      foodSoundEnabled: fields[14] as bool? ?? true,
      bedtimeVibrationEnabled: fields[15] as bool? ?? true,
      bedtimeSoundEnabled: fields[16] as bool? ?? true,
      wakeupVibrationEnabled: fields[17] as bool? ?? true,
      wakeupSoundEnabled: fields[18] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer.writeByte(19);
    
    writer.writeByte(0);
    writer.write(obj.themeMode);
    
    writer.writeByte(1);
    writer.write(obj.fontSize);
    
    writer.writeByte(2);
    writer.write(obj.weightUnit);
    
    writer.writeByte(3);
    writer.write(obj.heightUnit);
    
    writer.writeByte(4);
    writer.write(obj.waterUnit);
    
    writer.writeByte(5);
    writer.write(obj.masterNotificationsEnabled);
    
    writer.writeByte(6);
    writer.write(obj.waterNotificationsEnabled);
    
    writer.writeByte(7);
    writer.write(obj.foodNotificationsEnabled);
    
    writer.writeByte(8);
    writer.write(obj.bedtimeNotificationsEnabled);
    
    writer.writeByte(9);
    writer.write(obj.wakeupNotificationsEnabled);
    
    writer.writeByte(10);
    writer.write(obj.reportNotificationsEnabled);

    writer.writeByte(11);
    writer.write(obj.waterVibrationEnabled);

    writer.writeByte(12);
    writer.write(obj.waterSoundEnabled);

    writer.writeByte(13);
    writer.write(obj.foodVibrationEnabled);

    writer.writeByte(14);
    writer.write(obj.foodSoundEnabled);

    writer.writeByte(15);
    writer.write(obj.bedtimeVibrationEnabled);

    writer.writeByte(16);
    writer.write(obj.bedtimeSoundEnabled);

    writer.writeByte(17);
    writer.write(obj.wakeupVibrationEnabled);

    writer.writeByte(18);
    writer.write(obj.wakeupSoundEnabled);
  }
}
