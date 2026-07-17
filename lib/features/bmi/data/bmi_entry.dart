import 'package:hive_ce/hive_ce.dart';

/// Represents a single BMI calculation entry saved in history.
class BMIEntry extends HiveObject {
  /// Unique identifier (timestamp string).
  final String id;

  /// Height in cm.
  final double heightCm;

  /// Weight in kg.
  final double weightKg;

  /// Calculated BMI value.
  final double bmiValue;

  /// BMI category name (Underweight, Healthy, Overweight, Obese).
  final String category;

  /// Date and time of calculation.
  final DateTime timestamp;

  BMIEntry({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.bmiValue,
    required this.category,
    required this.timestamp,
  });

  /// Factory to generate a new entry with an automated ID.
  factory BMIEntry.create({
    required double heightCm,
    required double weightKg,
    required double bmiValue,
    required String category,
  }) {
    final now = DateTime.now();
    return BMIEntry(
      id: now.millisecondsSinceEpoch.toString(),
      heightCm: heightCm,
      weightKg: weightKg,
      bmiValue: bmiValue,
      category: category,
      timestamp: now,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — written manually (typeId = 3)
// ═══════════════════════════════════════════════════════════════════════════

class BMIEntryAdapter extends TypeAdapter<BMIEntry> {
  @override
  final int typeId = 3;

  @override
  BMIEntry read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return BMIEntry(
      id: fields[0] as String? ?? '',
      heightCm: fields[1] as double? ?? 170.0,
      weightKg: fields[2] as double? ?? 70.0,
      bmiValue: fields[3] as double? ?? 24.2,
      category: fields[4] as String? ?? 'Healthy',
      timestamp: DateTime.tryParse(fields[5] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, BMIEntry obj) {
    writer.writeByte(6); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.heightCm);
    writer.writeByte(2);
    writer.write(obj.weightKg);
    writer.writeByte(3);
    writer.write(obj.bmiValue);
    writer.writeByte(4);
    writer.write(obj.category);
    writer.writeByte(5);
    writer.write(obj.timestamp.toIso8601String());
  }
}
