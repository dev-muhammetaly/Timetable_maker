import 'package:flutter/material.dart';
import '../models/schedule_event.dart';

class AddEditEventDialog extends StatefulWidget {
  final ScheduleEvent? event;

  const AddEditEventDialog({super.key, this.event});

  @override
  State<AddEditEventDialog> createState() => _AddEditEventDialogState();
}

class _AddEditEventDialogState extends State<AddEditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _venue;
  late String _day;
  late TimeOfDay _time;
  late int _duration;

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _title = widget.event!.title;
      _venue = widget.event!.venue ?? '';
      _day = widget.event!.day;
      final timeParts = widget.event!.time.split(':');
      _time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _duration = widget.event!.duration;
    } else {
      _title = '';
      _venue = '';
      _day = 'Monday';
      _time = const TimeOfDay(hour: 9, minute: 0);
      _duration = 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: Text(
        widget.event == null ? 'Add Class' : 'Edit Class',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _title,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Class Title',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _venue,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Lecture Venue (Room/Hall)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                onSaved: (value) => _venue = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _day,
                dropdownColor: const Color(0xFF16213E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Day',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (value) => setState(() => _day = value!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Time', style: TextStyle(color: Colors.white70)),
                subtitle: Text(_time.format(context), style: const TextStyle(color: Colors.white, fontSize: 18)),
                trailing: const Icon(Icons.access_time, color: Colors.blueAccent),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _time);
                  if (picked != null) setState(() => _time = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _duration.toString(),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a valid number' : null,
                onSaved: (value) => _duration = int.parse(value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final event = ScheduleEvent(
                day: _day,
                time: '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                title: _title,
                duration: _duration,
                venue: _venue,
              );
              Navigator.pop(context, event);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          child: const Text('Save'),
        ),
      ],
    );
  }
}