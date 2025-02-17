# Introduction

## Ionic (Angular/Capacitor) vs Flutter

### Widgets vs. Components
#### Flutter:
- Flutter uses **Widgets** as the fundamental UI building blocks.
- Everything in Flutter is a widget (buttons, layouts, paddings, even the entire app).
- Widgets can be **Stateless** (`StatelessWidget`) or **Stateful** (`StatefulWidget`).
- **Composition over inheritance**: Widgets are combined to build UI rather than using large, complex base classes.

#### Ionic:
- Ionic uses **Components** based on HTML, CSS, and JavaScript.
- UI is structured with Angular components and templates.
- Uses **WebView-based rendering**, which impacts performance compared to Flutter’s native rendering.
- Requires a mix of Angular/React/Vue knowledge, whereas Flutter only needs Dart.

**Analogy:**  
Ionic components = HTML elements inside an Angular template.  
Flutter widgets = Everything, including the UI structure itself.

---

### Navigation Differences
#### Flutter:
- Uses the `Navigator` class for routing.
- Supports **stack-based navigation** (`Navigator.push` & `Navigator.pop`).
- Uses `onGenerateRoute` and `go_router` for advanced navigation handling.
- Pages are **kept in memory by default**, unless explicitly removed.

#### Ionic:
- Uses **Angular Router** (`RouterModule`).
- Navigation is based on **URL routing** like traditional web apps.
- Pages are destroyed and recreated on navigation (unless caching is enabled).
- Uses the **History API** for back navigation.

**Analogy:**  
Flutter’s navigation is more like **Android/iOS stack-based navigation**, while Ionic’s navigation feels more like a **single-page web app**.

---

### State Management
#### Flutter (Provider-based in this template):
- Uses **Provider** for global state management.
- Can manage UI and business logic in separate layers (follows MVVM principles).
- Reactive updates are handled efficiently with **ChangeNotifier**.

#### Ionic:
- Uses Angular’s **Services & RxJS Observables** for state management.
- Requires dependency injection to manage global state.
- Often involves using libraries like **NgRx** or **BehaviorSubject** for complex state management.

**Analogy:**  
Provider in Flutter is like an **Angular Service + BehaviorSubject**, where you notify listeners whenever the state changes.

---

### Debugging & Code Compilation
#### Flutter:
- Uses **Dart VM** for hot reload and fast iterations.
- Native compilation to ARM/x86 for mobile and WebAssembly for web.
- Debugging via **Flutter DevTools** and logging (`print()`, `debugPrint()`).

#### Ionic:
- Runs inside a WebView, meaning debugging relies on **Chrome DevTools**.
- Code is interpreted as JavaScript, so performance overhead exists.
- Uses **Live Reload** instead of Hot Reload.

**Key Difference:**  
Flutter compiles to native code, while Ionic relies on a WebView, making Flutter’s performance better, especially for animations and heavy UI.



---
---

## Development Essentials

### Debugging in Flutter
Flutter provides various debugging tools to help developers diagnose issues efficiently.

#### Debugging Modes
Flutter apps can run in different modes:
- **Debug Mode**: Enables hot reload, full debugging capabilities, and asserts.
- **Profile Mode**: Optimized for performance testing with limited debugging.
- **Release Mode**: Fully optimized with no debugging tools.

#### Useful Debugging Tools
- **`kDebugMode`**: A constant that returns `true` in debug mode.
  ```dart
  if (kDebugMode) {
    print("This will only print in debug mode");
  }
  ```
- **`kIsWeb`**: A constant that checks if the app is running on Flutter Web.
  ```dart
  if (kDebugMode) {
    print("Running on web");
  }
  ```
- Flutter DevTools: A suite of debugging tools (flutter pub global activate devtools).
- debugPrint(): Used for logging with performance optimization (avoids log flooding).

---

### Widget types: Stateless vs. Stateful

Widgets in Flutter define the UI and behavior of the app.

**StatelessWidget (stl)**

- Used when UI does not change dynamically (on API call/DB update/user action).
- Example:
  ```dart
    class MyStatelessWidget extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
            return Text('Hello, Flutter!');
        }
    }
    ```

**StatefulWidget (stfl)**

- Used when UI changes based on user interaction or data updates.
- Example:
  ```dart
    class MyStatefulWidget extends StatefulWidget {
        @override
        _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
    }

    class _MyStatefulWidgetState extends State<MyStatefulWidget> {
        int counter = 0;

        @override
        Widget build(BuildContext context) {
            return Column(
                children: [
                    Text('Counter: $counter'),
                    ElevatedButton(
                      onPressed: () => setState(() => counter++),
                        child: Text('Increment'),
                    ),
                ],
            );
        }
    }
    ```

---

### When to use StatefulWidget (stfl) vs. StatelessWidget (stl)

|Feature | StatelessWidget | StatefulWidget |
| ---- | --- | --- |
| UI never changes| ✅ Yes| ❌ No |
| UI updates over time| ❌ No| ✅ Yes |
| Performance| ✅ Faster| ⚠️ Slightly Slower |


### VS Code Shortcuts (Flutter equivalents of Emmet in Ionic)

#### Commonly Used Shortcuts:
| Shortcut |	Description |
| ---- | ---- |
| `Ctrl + .` (or Cmd + . on Mac) |	Quick fix & refactoring |
| `Alt + Shift + F` (or Cmd + Shift + F) |	Format code |
| `F5` |	Start debugging |
| `Ctrl + Shift + P` |	Open VS Code command palette |

#### Flutter-Specific Shortcuts:
| Shortcut | Description |
| ---- | ---- |
| `stl` + Enter |	Generates StatelessWidget |
| `stfl` + Enter |	Generates StatefulWidget |
| `Ctrl + S` | Hot reload |
| `Shift + R` | Hot restart |
| `Ctrl + Shift + P` → "Flutter: Select Device" | Switch between devices |
| `Ctrl + Shift + P` → "Flutter: Run Emulator" | Start an emulator |

`Note: To use stfl and stl, simply create a new dart file, and write stfl/stl and press; the Flutter plugin of vscode/android studio would automatically create a basic widget.`

----
----

---

## Development Environment  

### Required Tools  
- **VS Code** (Recommended IDE)  
- **Flutter VS Code Extension** (For debugging, autocompletion)  
- **Material Icon Theme** (For better file visibility)  
- **Markdown Preview Enhanced** (For improved documentation viewing)  

### Flutter SDK Version  

This project uses **Flutter 3.27.4**. Ensure you have the correct version installed:  

```bash
flutter --version
```

### Git Workflow

1. Always pull from `master` before making changes.
2. Create a new branch for your changes.
3. Never push directly to `master`.
4. Only push changes of `lib` directory, `pubspec.yaml`, any `markdown` file you created for documentation. All other files are unnecessary, 

#### Commands:

The commands I commonlt use for this are as following.

```bash
git checkout master            # Switch to master
git pull origin master         # Get the latest updates
git checkout -b <new-branch>   # Create a new branch
# Make your changes
git add <directory/updated file>                      # Stage changes
git commit -m "Your commit message"  # Commit changes
git push origin <new-branch>   # Push your changes
```

### VS Code Extensions:

- `Flutter VS Code Extension` (for debugging & development)
- `Material Icon Theme` (for better project file visualization)
- `Markdown Preview Enhanced` (for previewing documentation)

--- 

### Running the App

```bash
flutter pub get        # Install dependencies
flutter run -d chrome  # Run on Web
flutter run -d android # Run on Android
flutter run -d ios     # Run on iOS (requires macOS & Xcode)
```

----
----

## Project Structure

The project structure can be found in `DirectoryStructure.md` file in project root directory.

### Explanation of Key Directories

#### `constants/`
Defines app-wide static values used throughout the project.
- `app_colors.dart`: Centralized theme colors.
- `app_style.dart`: Global text styles.
- `app_theme.dart`: Defines Material theme settings.
- `base_url_config.dart`: Manages different API base URLs for environments.

#### `l10n/`
Contains localization files for supporting multiple languages.
- `app_en.arb`: English translation strings.
- `app_hi.arb`: Hindi translation strings.

---

#### `models/`
Contains data models for API responses and local data management.
- Example: `login_response.dart`, `state_district.dart`
- Organized by feature (e.g., `LoginModel/`, `LogoutModel/`).

---

#### `services/`
Handles core application services such as API calls, database handling, encryption, and local storage.
- `ApiService/`: API request handling.
- `DatabaseHelper/`: SQLite & IndexedDB (for Web) service.
- `EncryptionService/`: Encrypts and decrypts sensitive data.
- `LocalStorageService/`: Manages local storage operations.
- `LogService/`: Handles app-wide logging.

---

#### `utils/`
Contains helper functions for reusable utilities like:
- `camera_utils.dart`: Handles camera-related operations.
- `device_id.dart`: Retrieves unique device identifiers.
- `toast_util.dart`: Displays toast notifications.

---

#### `viewmodels/`
Implements **Provider-based state management** for different features.
- Example: `user_provider.dart`, `network_provider.dart`
- Subdirectories group feature-specific view models (`Login/`, `Register/`, etc.).

---

#### `views/`
Contains all UI-related components.
- **`screens/`**: Houses all screens categorized by feature (`Login/`, `Register/`, `Settings/`, etc.).
- **`widgets/`**: Contains reusable UI components (`custom_button.dart`, `custom_text_widget.dart`).
- **`widgets/web/`**: Contains web-specific widgets (`camera_gallery_screen.dart`).

---

----
----

## Architecture Overview (MVVM)

The project follows the **MVVM (Model-View-ViewModel)** architecture to ensure a clear separation of concerns, better state management, and improved maintainability.  

---

### How MVVM is Applied in Flutter

MVVM consists of three layers:

1. **Model (M)**  
   - Represents **data** and **business logic**.  
   - Fetches data from APIs or databases and provides structured responses.  
   - Located in the **`models/`** directory.  
   - Example: `LoginModel/login_response.dart`

2. **View (V)**  
   - UI components that display data and handle user interactions.  
   - Located in **`views/screens/`** and **`views/widgets/`**.  
   - Example: `views/screens/Login/login_screen.dart`

3. **ViewModel(VM)**  
   - Acts as a bridge between the **Model** and **View**.  
   - Manages state and business logic.  
   - Uses **Provider** for state management.  
   - Located in **`viewmodels/`**.  
   - Example: `viewmodels/Login/login_view_model.dart`

---

### Mapping MVVM Concepts to Flutter

| MVVM Concept    | Flutter Equivalent |
|----------------|------------------|
| **Model (M)**  | Data models stored in `models/`. Handles API responses and local data. |
| **View (V)**   | UI screens in `views/screens/` and reusable UI components in `views/widgets/`. |
| **ViewModel (VM)** | **Provider-based** state management in `viewmodels/`. |

### How MVVM Works with API Calls & Encryption

1. **View (UI Layer)**
   - Calls the corresponding ViewModel when an action is performed.
   - Example: Login button in `login_screen.dart` calls `loginViewModel.loginUser()`.

2. **ViewModel (Business Logic Layer)**
   - Encrypts request data using **AES-256**.
   - Calls `ApiService` from **`services/ApiService/api_service.dart`** to send the encrypted request.
   - Stores the decrypted response in Provider state.

3. **Model (Data Layer)**
   - Receives encrypted response from API.
   - Decrypts response using **Global Key** or **UserEncryptionKey** (based on auth requirement).
   - Converts decrypted response to structured data (`LoginModel/login_response.dart`).

----
----

## Packages Used and Their Purpose

This project uses several dependencies to handle various functionalities such as **state management, API calls, encryption, storage, and more**. Below is a categorized breakdown of the packages used.

### List of dependencies (pubspec.yaml)

```yaml
cupertino_icons: ^1.0.8
http: ^1.2.2
provider: ^6.1.2
delightful_toast: ^1.1.0
flutter_secure_storage: ^9.0.0
image_picker: ^1.1.2
intl: ^0.19.0
flutter_map: ^7.0.2
geocoding: ^3.0.0
geolocator: ^13.0.2
latlong2: ^0.9.1
permission_handler: ^11.3.1
camera: ^0.10.5+9
encrypt: ^5.0.3
sqflite: ^2.0.0+4
syncfusion_flutter_pdf: ^21.2.4
path_provider: ^2.0.11
open_file: ^3.2.1
flutter_offline: ^4.0.0
internet_connection_checker: ^3.0.1
device_info_plus: ^11.2.1
android_id: ^0.4.0
fluttertoast: ^8.0.9
connectivity_plus: ^6.1.1
crypto: ^3.0.1
path: ^1.9.0
logger: ^2.5.0
uuid: ^4.5.1
idb_shim: ^2.6.1+7
universal_html: ^2.2.4
file_picker: ^8.3.5
```

### Package usage
State Management
provider: Used for state management across the app (viewmodels/).
Example: viewmodels/user_provider.dart manages user session state.
🔹 Networking & API Requests
http: Handles API calls (services/ApiService/api_service.dart).
crypto: Provides cryptographic utilities for request encryption.
🔹 Data Storage
flutter_secure_storage: Stores sensitive data securely (e.g., UserEncryptionKey).
sqflite: Manages SQLite database for offline storage.
idb_shim: Manages IndexedDB for web storage.
path_provider: Helps locate storage paths on different platforms.
🔹 Encryption & Security
encrypt: Implements AES-256 encryption for API requests (services/EncryptionService/encryption_service.dart).
android_id: Retrieves device-specific IDs for security and tracking.
🔹 Geolocation & Maps
geocoding: Converts coordinates to addresses.
geolocator: Fetches current location.
flutter_map: Displays maps using OpenStreetMap.
latlong2: Handles latitude & longitude calculations.
🔹 Permissions & Device Info
permission_handler: Manages app permissions.
device_info_plus: Retrieves device information.
🔹 UI & Widgets
cupertino_icons: Provides iOS-style icons.
image_picker: Allows users to pick images from camera/gallery.
fluttertoast: Displays toast notifications.
delightful_toast: Provides customized toast messages.
syncfusion_flutter_pdf: Generates and handles PDF files.
file_picker: Enables file selection.
🔹 Offline & Connectivity
flutter_offline: Detects offline mode.
connectivity_plus: Monitors network status.
internet_connection_checker: Verifies active internet connection.
🔹 Logging & Debugging
logger: Provides logging utilities for debugging.
🔹 Utility & Miscellaneous
uuid: Generates unique IDs.
path: Helps in file path manipulation.
universal_html: Provides browser compatibility utilities.

----
----

## API Integration and Services

The app uses **AES-256 encryption** for securing API communication. There are **two encryption keys** used:

1. **Global Key** (Static)
   - Shared between frontend and backend.
   - Stored in source code.
   - Used for encrypting/decrypting requests that do **not** require authentication.

2. **UserEncryptionKey** (Dynamic, per user)
   - Generated on first login.
   - **Mobile:** Stored securely in **Flutter Secure Storage**.
   - **Web:** Stored in **IndexedDB**, encrypted with the **Global Key**.
   - Used for decrypting authenticated responses.

---

### Encryption Process

#### For Unauthenticated Requests (e.g., Login, Register)
- Request body is **stringified** (serialized).
- Encrypted using **AES-256 with the Global Key**.
- Sent to the backend.
- Backend encrypts the response with the **Global Key** and sends it back.
- App decrypts the response using the **Global Key** and deserializes it.

---

#### For Authenticated Requests (Requires `authToken`)
- Request body is **stringified and encrypted** using **AES-256 with the Global Key**.
- `authToken` is also **encrypted** using **AES-256 with the Global Key**.
- Sent to the backend.
- **Backend encrypts the response using UserEncryptionKey**.
- App decrypts the response using **UserEncryptionKey** and deserializes it.

---

#### Response Handling
- **For unauthenticated requests:**  
  - Decrypt response using **Global Key**.
  - Deserialize into JSON.

- **For authenticated requests:**  
  - Decrypt response using **UserEncryptionKey**.
  - Deserialize into JSON.

This ensures **end-to-end encryption** while keeping the encryption key **securely stored on the frontend**. 🚀  
Let me know if you'd like modifications! 

---
---


## Navigation
### How navigation works in Flutter
### Deep linking (if applicable)

