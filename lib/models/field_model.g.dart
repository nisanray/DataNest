// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FieldAdapter extends TypeAdapter<Field> {
  @override
  final int typeId = 1;

  @override
  Field read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Field(
      id: fields[0] as String,
      sectionId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as String,
      requiredField: fields[4] as bool,
      defaultValue: fields[5] as dynamic,
      hint: fields[6] as String?,
      unique: fields[7] as bool,
      allowedOptions: (fields[8] as List?)?.cast<dynamic>(),
      validation: (fields[9] as Map?)?.cast<String, dynamic>(),
      attachmentRules: (fields[10] as Map?)?.cast<String, dynamic>(),
      relations: (fields[11] as Map?)?.cast<String, dynamic>(),
      formula: fields[12] as String?,
      conditionalVisibility: fields[13] as String?,
      order: fields[14] as int?,
      synced: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Field obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sectionId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.requiredField)
      ..writeByte(5)
      ..write(obj.defaultValue)
      ..writeByte(6)
      ..write(obj.hint)
      ..writeByte(7)
      ..write(obj.unique)
      ..writeByte(8)
      ..write(obj.allowedOptions)
      ..writeByte(9)
      ..write(obj.validation)
      ..writeByte(10)
      ..write(obj.attachmentRules)
      ..writeByte(11)
      ..write(obj.relations)
      ..writeByte(12)
      ..write(obj.formula)
      ..writeByte(13)
      ..write(obj.conditionalVisibility)
      ..writeByte(14)
      ..write(obj.order)
      ..writeByte(15)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
