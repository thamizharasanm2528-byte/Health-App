import 'package:hive_ce/hive_ce.dart';

/// A single water intake entry persisted via Hive.
///
/// Each entry records the amount (in millilitres) and the
/// exact timestamp when the water was logged.
class WaterEntry extends HiveObject {
  /// Unique identifier (ISO-8601 timestamp string).
  String id;

  /// Amount of water in millilitres.
  int amountMl;

  /// When this entry was recorded.
  DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  /// Creates a new entry with a generated ID.
  factory WaterEntry.create(int amountMl) {
    return WaterEntry(
      id: DateTime.now().toIso8601String(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
  }

  /// Amount in litres for display.
  double get amountLiters => amountMl / 1000;
}

// ═══════════════════════════════════════════════════════════════════════════
// Hive TypeAdapter — manual (typeId = 1)
// ═══════════════════════════════════════════════════════════════════════════

class WaterEntryAdapter extends TypeAdapter<WaterEntry> {
  @override
  final int typeId = 1;

  @override
  WaterEntry read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return WaterEntry(
      id: fields[0] as String? ?? '',
      amountMl: fields[1] as int? ?? 0,
      timestamp: DateTime.tryParse(fields[2] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, WaterEntry obj) {
    writer.writeByte(3); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.amountMl);
    writer.writeByte(2);
    writer.write(obj.timestamp.toIso8601String());
  }
}
