# Todo App

A polished Flutter task manager powered by Firebase. Todo App helps users sign in, manage daily tasks in real time, filter work by date and status, personalize their profile, switch themes, and receive task reminders through Firebase Cloud Messaging.

## Highlights

- Email/password authentication with Firebase Auth
- Google sign-in support
- Real-time task sync with Cloud Firestore
- Add, edit, complete, and delete tasks
- Swipe-to-delete task interaction
- Calendar strip for date-based task browsing
- Filters for all, pending, and completed tasks
- Completed task history cleanup
- Profile screen with user info and profile photo upload
- Light and dark theme support with local persistence
- Push notification support with Firebase Messaging
- Share app action
- About and privacy policy screens
- Responsive layout adjustments for larger screens

## Tech Stack

- Flutter
- Dart
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Cloud Messaging
- Provider for state management
- Shared Preferences for local theme storage
- Image Picker for profile photos
- Share Plus and URL Launcher for platform features

## Screens

- Authentication: login, sign up, and Google sign-in
- Home: task timeline, calendar strip, filters, and add-task sheet
- Profile: avatar upload, theme toggle, notification toggle, history cleanup, sharing, about, privacy policy, and sign out

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  providers/
    notification_provider.dart
    task_filter_provider.dart
    theme_provider.dart
  screens/
    about_screen.dart
    auth_screen.dart
    home_screen.dart
    pricavy_policy_screen.dart
    profile_screen.dart
  service/
    auth_service.dart
    firestore_service.dart
    messaging_service.dart
    profile_image_service.dart
  theme/
    app_colors.dart
    app_sizes.dart
    app_theme.dart
  widgets/
    add_task_sheet.dart
    calendar_strip.dart
    filter_chips_row.dart
    profile_avatar.dart
    task_tile.dart
```

## Getting Started

### Prerequisites

Install the following before running the project:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Firebase CLI
- FlutterFire CLI
- A Firebase project

Check your Flutter installation:

```bash
flutter doctor
```

### Installation

Clone the repository:

```bash
git clone https://github.com/your-username/todo-app.git
cd todo-app
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase for your own project:

```bash
flutterfire configure
```

Run the app:

```bash
flutter run
```

## Firebase Setup

Create a Firebase project and enable:

- Authentication
  - Email/Password provider
  - Google provider
- Cloud Firestore
- Firebase Cloud Messaging

For Android, make sure your Firebase configuration is added to:

```text
android/app/google-services.json
```

For other platforms, run:

```bash
flutterfire configure
```

This generates or updates:

```text
lib/firebase_options.dart
```

## Firestore Data Model

Tasks are stored in the `tasks` collection.

Example task document:

```json
{
  "title": "Finish project README",
  "body": "Add setup instructions and feature list",
  "isCompleted": false,
  "userId": "firebase-user-id",
  "createdAt": "timestamp",
  "timestamp": "timestamp"
}
```

User profile data is stored in the `users` collection.

Example user document:

```json
{
  "profilePicData": "base64-image-string",
  "updatedAt": "timestamp"
}
```

## Useful Commands

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build Android APK:

```bash
flutter build apk
```

Build for web:

```bash
flutter build web
```

## Security Notes

Do not commit private Firebase service-account credentials, API secrets, or production keys to a public repository. Server-side push notification logic should be handled with a trusted backend or Cloud Functions, not directly inside a client app.

Before publishing this project publicly, rotate any exposed Firebase service-account keys and move privileged notification sending to a secure backend.

## Roadmap

- Add due dates and reminders per task
- Add priority labels
- Add task search
- Add recurring tasks
- Add Firestore security rules documentation
- Add screenshots or demo GIFs
- Add release builds for Android and web

## Author

Created by Sabiha Niaz.

## License

This project is currently not licensed. Add a license file before accepting external contributions or publishing as open source.
