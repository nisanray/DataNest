// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SectionAdapter extends TypeAdapter<Section> {
  @override
  final int typeId = 0;

  @override
  Section read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Section(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String?,
      color: fields[3] as String?,
      description: fields[4] as String?,
      order: fields[5] as int?,
      synced: fields[6] as bool,
      settings: (fields[7] as Map?)?.cast<String, dynamic>(),
      userId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Section obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.synced)
      ..writeByte(7)
      ..write(obj.settings)
      ..writeByte(8)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
