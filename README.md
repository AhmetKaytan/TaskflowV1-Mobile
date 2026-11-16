# TaskFlow Mobile

A Flutter-based mobile client for **TaskFlow**, a task management application backed by a REST API. The mobile app connects to the same deployed backend as the TaskFlow web client, so tasks are shared between the two clients.

## Features

- User registration and login
- JWT-based authentication
- Secure local token storage with `flutter_secure_storage`
- View tasks from the shared TaskFlow API
- Search tasks by keyword
- Filter tasks by status and priority
- Create, edit, and delete tasks
- View task details, including assignee, due date, creation date, and last update date
- Visual due-date indication for tasks due today or overdue
- Pull-to-refresh task list
- Logout

## Tech Stack

- **Flutter / Dart** – cross-platform UI framework and language
- **Provider** – application state management
- **http** – REST API communication
- **flutter_secure_storage** – local storage for the authentication token
- **intl** – date formatting

## Backend

The app currently uses the deployed TaskFlow API:

`https://taskflowv1.onrender.com`

The backend provides authentication and protected task-management endpoints. The Flutter app communicates with it over HTTPS.

> The API base URL is currently defined in `lib/services/api_service.dart`. No API secret is required to use the public client endpoint. Never commit user passwords, JWT tokens, private keys, or signing credentials.

## Important Backend Limitations

**Please read before using the application.**

The TaskFlow backend is hosted on [Render.com](https://render.com) using its free plan. As a result, the service has some limitations that may affect your experience:

- **Initial request delay:** Render automatically puts inactive free-tier services to sleep. When the first request is sent after a period of inactivity (for example, during login or registration), the backend needs some time to wake up. Therefore, the first operation may take longer than usual. Please be patient and wait for the response.

- **Temporary data storage:** The free plan does not provide a persistent disk. Data created during a runtime session, including newly registered user accounts and user-created tasks, may be lost when the service goes to sleep or restarts. Predefined mock data remains available.

**Please note:** Despite these limitations, all CRUD operations (Create, Read, Update, Delete) work as expected while the backend is active. The data-loss limitation applies to data added during a runtime session.

## Project Structure

```text
lib/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
└── main.dart

android/
ios/
test/
pubspec.yaml
pubspec.lock
analysis_options.yaml
```


## Requirements

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`
- Android Studio or Android SDK command-line tools for Android builds
- A configured Android emulator or a physical Android device for running the app

Check your local Flutter installation:

```bash
flutter doctor -v
flutter --version
```

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/AhmetKaytan/TaskflowV1-Mobile.git
   ```

2. Open the project directory:

   ```bash
   cd taskflow_mobile
   ```

3. Fetch dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app on a connected Android device or emulator:

   ```bash
   flutter devices
   flutter run
   ```

The first login requires a registered TaskFlow account.

## Android Builds

### Debug APK

Build a debug APK for quick testing:

```bash
flutter build apk --debug
```

Output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

Build an installable release APK:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

To install it on a connected Android device with USB debugging enabled:

```bash
flutter install --release
```

Alternatively, copy `app-release.apk` to the phone and open it to install. Android may ask you to allow installation from that source.

### Android App Bundle (AAB)

Build an Android App Bundle:

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

An AAB is not installed directly on a phone by tapping it. Use the APK for direct device installation.



