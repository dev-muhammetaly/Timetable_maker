import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_event.dart';

class StorageService {
  static const String _boxName = 'scheduleBox';

  static Box<ScheduleEvent> get _box => Hive.box<ScheduleEvent>(_boxName);

  static List<ScheduleEvent> getAllEvents() {
    return _box.values.toList();
  }

  static Future<void> saveEvents(List<ScheduleEvent> events) async {
    // For now, we append new events to existing ones
    await _box.addAll(events);
  }

  static Future<void> addEvent(ScheduleEvent event) async {
    await _box.add(event);
  }

  static Future<void> updateEvent(int index, ScheduleEvent event) async {
    await _box.putAt(index, event);
  }

  static Future<void> deleteEvent(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}