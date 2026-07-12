import 'package:hive/hive.dart';

/// Profile data model persisted via Hive.
///
/// Stores all user health profile data collected during the
/// multi-step profile setup wizard. Uses a manual [TypeAdapter]
/// to avoid `build_runner` / `hive_generator` dependency.
class ProfileModel extends HiveObject {
  /// User's full name.
  String name;

  /// User's age in years.
  int age;

  /// Height in centimetres.
  double heightCm;

  /// Weight in kilograms.
  double weightKg;

  /// Target weight in kilograms.
  double targetWeightKg;

  /// Activity level label (e.g. "Sedentary", "Very Active").
  String activityLevel;

  /// Daily water intake goal in litres.
  double waterGoalLiters;

  /// Daily step count goal.
  int dailyStepGoal;

  /// Bedtime stored as minutes since midnight (e.g. 22:30 → 1350).
  int bedtimeMinutes;

  /// Wake-up time stored as minutes since midnight (e.g. 6:30 → 390).
  int wakeTimeMinutes;

  /// User's date of birth.
  DateTime? dateOfBirth;

  /// Selected healthy food preference labels.
  List<String> foodPreferences;

  ProfileModel({
    this.name = '',
    this.age = 25,
    this.dateOfBirth,
    this.heightCm = 170,
    this.weightKg = 70,
    double? targetWeightKg,
    this.activityLevel = 'Moderately Active',
    this.waterGoalLiters = 3.0,
    this.dailyStepGoal = 8000,
    this.bedtimeMinutes = 1350, // 22:30
    this.wakeTimeMinutes = 390, // 06:30
    List<String>? foodPreferences,
  })  : targetWeightKg = targetWeightKg ?? weightKg,
        foodPreferences = foodPreferences ?? [];

  // ── Computed properties ──────────────────────────────────────────────

  /// Body Mass Index = weight(kg) / height(m)².
  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Human-readable BMI category.
  String get bmiCategory {
    final value = bmi;
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Healthy';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  /// Expected sleep duration in hours.
  double get sleepDurationHours {
    var diff = wakeTimeMinutes - bedtimeMinutes;
    if (diff <= 0) diff += 1440; // crosses midnight
    return diff / 60;
  }

  /// Formatted bedtime string (e.g. "10:30 PM").
  String get bedtimeFormatted => _formatMinutes(bedtimeMinutes);

  /// Formatted wake time string (e.g. "6:30 AM").
  String get wakeTimeFormatted => _formatMinutes(wakeTimeMinutes);

  String _formatMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayH.toString()}:${m.toString().padLeft(2, '0')} $period';
  }

  /// Creates a copy with optional field overrides.
  ProfileModel copyWith({
    String? name,
    int? age,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    String? activityLevel,
    double? waterGoalLiters,
    int? dailyStepGoal,
    int? bedtimeMinutes,
    int? wakeTimeMinutes,
    List<String>? foodPreferences,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      waterGoalLiters: waterGoalLiters ?? this.waterGoalLiters,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      bedtimeMinutes: bedtimeMinutes ?? this.bedtimeMinutes,
      wakeTimeMinutes: wakeTimeMinutes ?? this.wakeTimeMinutes,
      foodPreferences: foodPreferences ?? List.from(this.foodPreferences),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — written manually to avoid build_runner dependency
// ═══════════════════════════════════════════════════════════════════════════

/// Hive TypeAdapter for [ProfileModel]. TypeId = 0.
class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 0;

  @override
  ProfileModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    final w = fields[3] as double? ?? 70.0;
    return ProfileModel(
      name: fields[0] as String? ?? '',
      age: fields[1] as int? ?? 25,
      dateOfBirth: fields[11] as DateTime?,
      heightCm: fields[2] as double? ?? 170,
      weightKg: w,
      targetWeightKg: fields[10] as double? ?? w,
      activityLevel: fields[4] as String? ?? 'Moderately Active',
      waterGoalLiters: fields[5] as double? ?? 3.0,
      dailyStepGoal: fields[6] as int? ?? 8000,
      bedtimeMinutes: fields[7] as int? ?? 1350,
      wakeTimeMinutes: fields[8] as int? ?? 390,
      foodPreferences: (fields[9] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer.writeByte(12); // number of fields (increased from 11)
    // 0: name
    writer.writeByte(0);
    writer.write(obj.name);
    // 1: age
    writer.writeByte(1);
    writer.write(obj.age);
    // 2: heightCm
    writer.writeByte(2);
    writer.write(obj.heightCm);
    // 3: weightKg
    writer.writeByte(3);
    writer.write(obj.weightKg);
    // 4: activityLevel
    writer.writeByte(4);
    writer.write(obj.activityLevel);
    // 5: waterGoalLiters
    writer.writeByte(5);
    writer.write(obj.waterGoalLiters);
    // 6: dailyStepGoal
    writer.writeByte(6);
    writer.write(obj.dailyStepGoal);
    // 7: bedtimeMinutes
    writer.writeByte(7);
    writer.write(obj.bedtimeMinutes);
    // 8: wakeTimeMinutes
    writer.writeByte(8);
    writer.write(obj.wakeTimeMinutes);
    // 9: foodPreferences
    writer.writeByte(9);
    writer.write(obj.foodPreferences);
    // 10: targetWeightKg
    writer.writeByte(10);
    writer.write(obj.targetWeightKg);
    // 11: dateOfBirth
    writer.writeByte(11);
    writer.write(obj.dateOfBirth);
  }
}
