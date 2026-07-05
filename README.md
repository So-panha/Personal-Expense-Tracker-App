# 💰 Personal Expense Tracker

A full-featured Flutter mobile app for managing personal finances — track income and expenses, set budgets, save for goals, and visualize spending trends.

---

## ✨ Features

- 🔐 **Authentication** — Login / Register / OTP / Forgot Password (JWT-based)
- 💳 **Transactions** — Add, edit and delete income & expense entries with receipt image uploads
- 📊 **Dashboard & Analytics** — Summary cards, pie charts for category breakdown, monthly trends
- 🎯 **Budget Limits** — Set / monitor monthly budget per category with warning levels
- 🏦 **Savings Goals** — Create goals, track progress, and log contributions
- ⚙️ **Settings & Profile** — Update profile name, email, password, and avatar image
- 🗂️ **Category Management** — Create, edit and delete custom categories (Income / Expense)

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Networking | Dio (with JWT interceptors) |
| Local Storage | SharedPreferences |
| Charts | fl_chart |
| Image Picker | image_picker |
| API Backend | REST API (`https://ant-g2-pet.tt.linkpc.net/api/v1`) |

---

## 📋 Prerequisites

Before running this project, make sure you have installed:

1. **Flutter SDK** `>= 3.11.x` — [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Dart SDK** — included with Flutter
3. **Android Studio** or **VS Code** with Flutter/Dart extensions
4. **An Android emulator** or physical Android/iOS device

> ✅ Verify your setup: run `flutter doctor` in terminal and ensure there are no errors.

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/So-panha/Personal-Expense-Tracker-App.git
cd Personal-Expense-Tracker-App
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Connect a Device or Start an Emulator

- Open **Android Studio → Device Manager** and start a virtual device, **or**
- Connect a physical Android/iOS phone with USB debugging enabled.

Verify the device is detected:
```bash
flutter devices
```

### 4. Run the App

```bash
flutter run
```

> 💡 For a specific device, use: `flutter run -d <device_id>`

---

## 🏗️ Build for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── network/          # Dio API client & interceptors
│   └── theme/            # App colors, gradients, typography
├── models/               # Data models (User, Transaction, Budget, etc.)
├── repositories/         # API data access layer
├── providers/            # State management (Auth, Transactions, Budgets, etc.)
└── views/
    ├── auth/             # Login, Register, OTP, Forgot Password screens
    ├── dashboard/        # Main bottom-nav dashboard and all tabs
    └── settings/         # Category management screen
```

---

## 🌐 API Configuration

The backend API base URL is configured in:

```
lib/core/network/api_client.dart
```

```dart
static const String defaultBaseUrl = 'https://ant-g2-pet.tt.linkpc.net/api/v1';
```

> ⚠️ **Note:** The app requires an active internet connection to communicate with the backend API. Make sure your network allows HTTPS connections.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is for educational purposes.
