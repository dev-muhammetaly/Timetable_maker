import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/schedule_event.dart';
import 'screens/schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapter
  Hive.registerAdapter(ScheduleEventAdapter());
  
  // Open Box with error handling for schema changes
  try {
    await Hive.openBox<ScheduleEvent>('scheduleBox');
  } catch (e) {
    // If opening fails (usually due to schema change), delete the corrupted box and try again
    debugPrint('Hive Open Error: $e. Resetting box...');
    await Hive.deleteBoxFromDisk('scheduleBox');
    await Hive.openBox<ScheduleEvent>('scheduleBox');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Timetable AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ScheduleScreen(),
    );
  }
}
