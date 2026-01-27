# Starlink System

A Flutter web and mobile application for managing Starlink installations and inventory. This system allows administrators to track devices, manage user access via Firebase Authentication, and handle bulk data operations through CSV export/import.

## Features

- **Authentication**: Secure login system using Firebase Auth.
- **Starlink Management**:
  - Add, edit, and delete Starlink device records.
  - View detailed information including Kit Number, Dish Serial, IP Address, Account Number, and associated Service Plan.
  - Search and filter capabilities.
- **Bulk Operations**:
  - Import device data from CSV files.
  - Export current inventory to CSV.
- **Responsive Design**: Built to work seamlessly on both web and mobile platforms.

## Technologies Used

- **Framework**: [Flutter](https://flutter.dev) (SDK ^3.8.0)
- **Backend/Database**: [Firebase](https://firebase.google.com) (Firestore, Auth)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **CSV Handling**: [csv](https://pub.dev/packages/csv) package
- **Icons**: [Lucide Icons](https://pub.dev/packages/lucide_icons)

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Flutter SDK**: Version 3.8.0 or higher.
- **Dart SDK**: Compatible version included with Flutter.
- **Firebase Project**: A Firebase project set up with Firestore and Authentication enabled.

## Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Francisco-V98/starlink_system.git
    cd starlink_system
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    The project includes `lib/firebase_options.dart` which contains the Firebase configuration. Ensure your Firebase project is correctly set up to match these credentials, or run `flutterfire configure` to regenerate the options for your specific project if you are setting up a new environment.

## Running the App

### Web (Recommended for Admin)
To run the application in Chrome:
```bash
flutter run -d chrome
```

### Mobile (iOS/Android)
Ensure you have an emulator running or a physical device connected.
```bash
flutter run
```

## Project Structure

```
lib/
├── firebase_options.dart      # Firebase configuration
├── main.dart                  # Application entry point
├── models/                    # Data models (e.g., StarlinkDevice)
├── providers/                 # State management (DataProvider)
├── screens/                   # UI Screens (Login, Manager, etc.)
└── widgets/                   # Reusable UI components
```

## Environment Variables

This project **does not require a `.env` file**. Configuration is handled through `firebase_options.dart`. Ensure this file is present and contains valid Firebase credentials.
