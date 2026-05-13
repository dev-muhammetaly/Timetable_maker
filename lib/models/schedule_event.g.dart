// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleEventAdapter extends TypeAdapter<ScheduleEvent> {
  @override
  final int typeId = 0;

  @override
  ScheduleEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleEvent(
      day: fields[0] as String,
      time: fields[1] as String,
      title: fields[2] as String,
      duration: fields[3] as int,
      venue: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.venue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
