import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uniplan/services/claude_service.dart';
import 'package:uniplan/services/storage_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isLoading = false;
  String _status = '';

  Future<void> _pickAndProcess(ImageSource source) async {
    // Check for Windows Camera limitation
    if (source == ImageSource.camera && !kIsWeb && Platform.isWindows) {
      setState(() => _status = 'Camera is not supported on Windows. Please use Gallery.');
      return;
    }

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _status = 'Reading image...';
      });

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = image.mimeType ?? 'image/jpeg';

      setState(() => _status = 'AI is detecting schedule...');

      final events = await ClaudeService.extractScheduleFromImage(
        base64Image,
        mimeType,
      );

      setState(() => _status = 'Saving to storage...');
      
      // Save to Hive
      await StorageService.saveEvents(events);

      setState(() => _status = 'Done!');

      if (!mounted) return;
      // Go back to the timetable screen and signal success
      Navigator.pop(context, true);
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('cameraDelegate')) {
        errorMsg = 'Camera not supported on this platform. Use Gallery instead.';
      }
      setState(() => _status = 'Error: $errorMsg');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'AI Schedule Scanner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.document_scanner,
                    size: 90,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AI Schedule Scanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload a photo to auto-detect your schedule',
                    style: TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcess(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(220, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickAndProcess(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take a Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(220, 50),
                    ),
                  ),
                  if (_status.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      _status,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}