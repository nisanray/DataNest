// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordAdapter extends TypeAdapter<Record> {
  @override
  final int typeId = 2;

  @override
  Record read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Record(
      id: fields[0] as String,
      sectionId: fields[1] as String,
      data: (fields[2] as Map).cast<String, dynamic>(),
      attachments: (fields[3] as List?)?.cast<String>(),
      relations: (fields[4] as Map?)?.cast<String, dynamic>(),
      synced: fields[5] as bool,
      userId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Record obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sectionId)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.attachments)
      ..writeByte(4)
      ..write(obj.relations)
      ..writeByte(5)
      ..write(obj.synced)
      ..writeByte(6)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
