# 📅 Timetable Maker

A modern, cross-platform Flutter application designed to simplify schedule management. **Timetable Maker** allows users to scan physical schedules using AI and manage their daily routines with ease.

## ✨ Features

- **📸 AI Schedule Scanner**: Extract timetable entries directly from images using advanced AI (GPT-4o via OpenRouter).
- **🗓️ Interactive Calendar**: View your schedule in a beautiful, organized calendar interface powered by Syncfusion.
- **🛠️ Manual Management**: Add, edit, or delete events manually with precise control over time, duration, and location.
- **💾 Local Storage**: Your data is saved securely on your device using Hive for fast, offline access.
- **📱 Cross-Platform**: Built with Flutter to run on Android, iOS, Web, Windows, macOS, and Linux.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
- [Dart SDK](https://dart.dev/get-started/sdk)
- An [OpenRouter API Key](https://openrouter.ai/) (for the AI scanning feature)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dev-muhammetaly/Timetable_maker.git
   cd Timetable_maker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up your API Key:**
   Open `lib/services/claude_service.dart` and replace `YOUR_API_KEY_HERE` with your actual OpenRouter API key.

4. **Run the application:**
   ```bash
   flutter run
   ```

## 🛠️ Built With

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Provider-like patterns with Hive
- **Database**: [Hive](https://docs.hivedb.dev/) (NoSQL)
- **UI Components**: [Syncfusion Flutter Calendar](https://www.syncfusion.com/flutter-widgets/flutter-calendar)
- **AI Integration**: [OpenRouter API](https://openrouter.ai/) (OpenAI GPT-4o-mini)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Built with ❤️ by [dev-muhammetaly](https://github.com/dev-muhammetaly)
