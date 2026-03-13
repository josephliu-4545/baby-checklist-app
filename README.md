# APDP App (Baby Checklist)

A Flutter app for managing a baby-preparation checklist with a soft pastel theme.

## Features

- **Authentication**
  - Email/password sign up and login using **Firebase Authentication**
  - Session routing handled by `AuthGate` (listens to `authStateChanges()`)

- **Checklist items (Firestore)**
  - Items stored per-user in **Cloud Firestore** at:
    - `users/{uid}/items/{itemId}`
  - Create, update, delete
  - Status flow: `pending` / `delegated` / `purchased`
  - Delegation fields persisted: `delegatedTo`, `delegationDate`
  - Delegation can optionally open the device SMS app with a prefilled message (Android/iOS)

- **Images (no Firebase Storage)**
  - Mobile/Desktop: stores a local file path in Firestore (prototype behavior)
  - Web: stores a **base64-encoded image string** in Firestore so images render after refresh
  - This project intentionally **does not** use Firebase Storage

- **UI/Theme**
  - Global pastel Material 3 theme (warm, parent-friendly palette)
  - Consistent buttons, cards, inputs, navigation bar, and status badges

## Project structure (high level)

- `lib/navigation/auth_gate.dart`
  - Routes to Welcome or MainShell based on Firebase auth state
- `lib/services/di/service_locator.dart`
  - Wires FirebaseAuth + Firestore + repositories/usecases/controllers
- `lib/features/**`
  - Feature-first folders (`auth`, `items`) with data/domain/presentation layers

## Key files (quick map)

- **App entry / Firebase init**
  - `lib/main.dart`
- **Auth routing**
  - `lib/navigation/auth_gate.dart`
- **Bottom navigation shell**
  - `lib/navigation/main_shell.dart`
- **Auth UI**
  - `lib/features/auth/presentation/screens/welcome_screen.dart`
  - `lib/features/auth/presentation/screens/login_screen.dart`
  - `lib/features/auth/presentation/screens/register_screen.dart`
  - `lib/features/auth/presentation/screens/profile_screen.dart`
- **Items UI**
  - `lib/features/items/presentation/screens/home_screen.dart`
  - `lib/features/items/presentation/screens/add_item_screen.dart`
  - `lib/features/items/presentation/screens/item_detail_screen.dart`
  - `lib/features/items/presentation/screens/delegation_screen.dart`
- **Controllers (ChangeNotifier)**
  - `lib/features/auth/presentation/controllers/auth_controller.dart`
  - `lib/features/items/presentation/controllers/item_controller.dart`
- **Firestore persistence**
  - `lib/features/items/data/datasources/item_firestore_datasource.dart`
  - `lib/features/items/data/repositories/item_repository_impl.dart`
- **Notifications (SMS adapter)**
  - `lib/services/notification/notification_service.dart`
  - `lib/services/notification/sms_adapter.dart`
  - `lib/services/notification/sms_mock_adapter.dart`

## Setup

### 1) Prerequisites

- Flutter SDK installed
- A Firebase project with:
  - **Authentication** (Email/Password enabled)
  - **Cloud Firestore** enabled

### 2) Firebase configuration

This app expects FlutterFire configuration to be present.

- `lib/firebase_options.dart` must exist and match your Firebase project.
- If you need to regenerate it, use FlutterFire CLI:
  - `flutterfire configure`

### 3) Install dependencies

- `flutter pub get`

## Run

### Mobile (Android/iOS)

- `flutter run`

### Web

- `flutter run -d chrome`

If you want auth persistence to behave consistently during development, prefer a fixed port:

- `flutter run -d chrome --web-port 5000`

## Notes / troubleshooting

### Profile shows no user

Profile is bound to Firebase auth state; it will show the current Firebase user (display name/email/uid).

### Images on Web

Web builds cannot reliably use local file paths across reloads.
For that reason, on Web the app stores `imageBase64` in Firestore and renders with `Image.memory`.

### Images on Mobile/Desktop

On non-web platforms, the app stores an image file path in Firestore. If the file is moved/deleted,
the app will fall back gracefully.

### Delegation SMS (prefilled composer)

When delegating an item, if the `delegatedTo` value looks like a phone number, the app attempts to open
the device SMS composer using an `sms:` link (user manually taps **Send**).

- Works best on **physical Android devices**
- Emulator support depends on system apps installed
- Requires `url_launcher` and, on Android 11+, package visibility `<queries>` entries for `sms`/`smsto`

If you add the dependency or change `AndroidManifest.xml`, do a **full stop and rerun** (hot restart is not enough).

## Automated tests (P7)

This project includes unit, widget, and integration tests.

### Test folders

- `test/`
  - Unit + widget tests
- `integration_test/`
  - Integration tests (run on Windows desktop / emulator / physical device)

### Test files included

- **Unit test** (use case)
  - `test/unit/mark_purchased_test.dart`
- **Widget test** (Login validation)
  - `test/widget/login_screen_test.dart`
- **Integration test** (startup flow)
  - `integration_test/app_flow_test.dart`

### Run tests

- Run unit + widget tests:
  - `flutter test`

- Run integration test on Windows desktop:
  - `flutter test integration_test -d windows`

### Integration test note (Web)

`integration_test` is not supported on web devices (Chrome/Edge) via `flutter test`.
