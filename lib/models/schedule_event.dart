import 'package:hive/hive.dart';

part 'schedule_event.g.dart';

@HiveType(typeId: 0)
class ScheduleEvent {
  @HiveField(0)
  final String day;
  
  @HiveField(1)
  final String time;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final int duration;

  @HiveField(4)
  final String? venue;

  ScheduleEvent({
    required this.day,
    required this.time,
    required this.title,
    required this.duration,
    this.venue,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleEvent(
      day: json['day']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      venue: json['venue']?.toString() ?? '',
    );
  }
}
