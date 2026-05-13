import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/schedule_event.dart';
import '../services/storage_service.dart';
import '../widgets/add_edit_event_dialog.dart';
import 'scanner_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ScheduleEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _events = StorageService.getAllEvents();
    });
  }

  List<Appointment> _buildAppointments() {
    const dayMap = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    const colors = [
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.redAccent,
    ];

    final List<Appointment> appointments = [];

    for (int i = 0; i < _events.length; i++) {
      final e = _events[i];
      final dayNum = dayMap[e.day.toLowerCase()];
      if (dayNum == null) continue;

      final timeParts = e.time.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      // Use a fixed reference date (e.g., first Monday of 2024) for the base of recurring events
      final baseDate = DateTime(2024, 1, 1); // 2024-01-01 was a Monday
      final eventDate = baseDate.add(Duration(days: dayNum - 1));

      final start = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
      );
      final end = start.add(Duration(minutes: e.duration));

      appointments.add(
        Appointment(
          startTime: start,
          endTime: end,
          subject: (e.venue == null || e.venue!.isEmpty) ? e.title : '${e.title} (${e.venue})',
          color: colors[i % colors.length],
          id: i,
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=${_getBYDAY(e.day)}',
        ),
      );
    }

    return appointments;
  }

  String _getBYDAY(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'MO';
      case 'tuesday':
        return 'TU';
      case 'wednesday':
        return 'WE';
      case 'thursday':
        return 'TH';
      case 'friday':
        return 'FR';
      case 'saturday':
        return 'SA';
      case 'sunday':
        return 'SU';
      default:
        return 'MO';
    }
  }

  void _onCalendarTap(CalendarTapDetails details) async {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      if (details.appointments == null || details.appointments!.isEmpty) return;

      final Appointment appointment = details.appointments![0];
      final int index = appointment.id as int;
      final event = _events[index];

      final result = await showDialog<dynamic>(
        context: context,
        builder: (context) => _EventActionDialog(event: event),
      );

      if (result == 'edit') {
        if (!mounted) return;
        final updatedEvent = await showDialog<ScheduleEvent>(
          context: context,
          builder: (context) => AddEditEventDialog(event: event),
        );
        if (updatedEvent != null) {
          await StorageService.updateEvent(index, updatedEvent);
          _loadEvents();
        }
      } else if (result == 'delete') {
        await StorageService.deleteEvent(index);
        _loadEvents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'University Timetable',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blueAccent),
            onPressed: () async {
              final newEvent = await showDialog<ScheduleEvent>(
                context: context,
                builder: (context) => const AddEditEventDialog(),
              );
              if (newEvent != null) {
                await StorageService.addEvent(newEvent);
                _loadEvents();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF16213E),
                  title: const Text(
                    'Clear Schedule?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'This will delete all classes from your timetable.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await StorageService.clearAll();
                _loadEvents();
              }
            },
          ),
        ],
      ),
      body: _events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your timetable is empty.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use the AI scanner or add manually\nto build your schedule.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScannerScreen(),
                        ),
                      );
                      if (result == true) _loadEvents();
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Scan Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SfCalendar(
              view: CalendarView.week,
              dataSource: _ScheduleDataSource(_buildAppointments()),
              onTap: _onCalendarTap,
              backgroundColor: const Color(0xFF1A1A2E),
              todayHighlightColor: Colors.blueAccent,
              headerStyle: const CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white, fontSize: 16),
                backgroundColor: Color(0xFF16213E),
              ),
              viewHeaderStyle: const ViewHeaderStyle(
                backgroundColor: Color(0xFF16213E),
                dayTextStyle: TextStyle(color: Colors.white70),
                dateTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              timeSlotViewSettings: const TimeSlotViewSettings(
                timeTextStyle: TextStyle(color: Colors.white54),
                timeIntervalHeight: 60,
                startHour: 7,
                endHour: 22,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
          if (result == true) _loadEvents();
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class _EventActionDialog extends StatelessWidget {
  final ScheduleEvent event;
  const _EventActionDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: Text(event.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event.day} at ${event.time}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Duration: ${event.duration} min',
            style: const TextStyle(color: Colors.white70),
          ),
          if (event.venue != null && event.venue!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Venue: ${event.venue}',
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'delete'),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'edit'),
          child: const Text('Edit', style: TextStyle(color: Colors.blueAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}

class _ScheduleDataSource extends CalendarDataSource {
  _ScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
