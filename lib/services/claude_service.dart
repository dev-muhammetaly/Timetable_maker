import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_event.dart';

class ClaudeService {
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  static Future<List<ScheduleEvent>> extractScheduleFromImage(
    String base64Image,
    String mimeType,
  ) async {
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://github.com/dev-muhammetaly/vibe_coding',
        'X-Title': 'Schedule Maker',
      },
      body: jsonEncode({
        'model': 'openai/gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': '''You are a schedule extractor.
Look at this image and extract ALL schedule or timetable entries.
Return ONLY a raw JSON object, no explanation, no markdown:
{
  "events": [
    {"day": "Monday", "time": "09:00", "title": "Math Class", "duration": 60, "venue": "Room 101"},
    {"day": "Tuesday", "time": "14:00", "title": "Meeting", "duration": 30, "venue": "Conference Hall"}
  ]
}
Rules:
- Days must be: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
- Time must be HH:MM in 24hr format
- Duration in minutes
- Venue: Extract the location or room number if visible, otherwise use an empty string.
- If no schedule found, return: {"events": []}''',
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String text = data['choices'][0]['message']['content'] as String;
      
      // Robust JSON extraction
      try {
        if (text.contains('{')) {
          text = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
        }
        final parsed = jsonDecode(text);
        final eventsList = (parsed['events'] ?? []) as List;
        return eventsList.map((e) => ScheduleEvent.fromJson(e)).toList();
      } catch (e) {
        print('Parsing Error: $e');
        print('Raw Text: $text');
        throw Exception('Failed to parse schedule data. Please try again.');
      }
    } else {
      // Detailed error logging to help diagnose the 401
      final errorMsg = 'Status: ${response.statusCode}\nBody: ${response.body}';
      print('OpenRouter Error:\n$errorMsg');
      throw Exception(errorMsg);
    }
  }
}
