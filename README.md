# 🎓 EduNest App

A robust, feature-rich multi-tenant Flutter application designed to provide customized branding, secure access, and streamlined portal management for educational institutions.

---

## 🚀 Key Features

* **Multi-Tenancy Integration**: Dynamically loads institutional profiles, brand names, and banner assets based on the school code.
* **Smart Splash Screen & Bootstrapping**: Smooth scale and fade animations that pre-load configuration settings, verify cached sessions, and dynamically transition users to the correct page.
* **Modular Clean Architecture**: Organized with a clear separation of UI representation, network request handling, local cache persistence, data model mapping, and configuration flavors.
* **Dynamic Institutional Branding**: Supports real-time rendering of custom school banners, fallback assets, and dynamic theme applications.

---

## 📁 Architecture & Directory Structure

The project follows a clean, layered architecture structure under the `lib` folder:

```text
lib/
├── flavors/                    # Flavor & environment configurations (dev, uat, prod)
│   ├── edunest_environment.dart
│   └── global_configuration.dart
└── app/
    ├── UI/                     # UI components and view layers
    │   ├── splash/             # Splash Screen with bootstrap anims
    │   └── login/              # Login, tenant selection, and form fields
    ├── core/                   # Core frameworks, utilities, and helper tools
    │   ├── base/               # Base repository & service definitions
    │   ├── network/            # Networking client (Dio wrapper) & error models
    │   ├── services/           # Shared preference persistence & settings storage
    │   ├── utils/              # Application constants & URL builders
    │   └── values/             # UI styling system (colors, padding, borders)
    ├── data/                   # Data parsing and networking layers
    │   ├── model/              # JSON serialization & business models
    │   └── repository/         # Data repositories fetching remote details
    └── my_app.dart             # Root GetMaterialApp configuration (fonts, routing)
```

---

## 🛠️ Technology Stack & Dependencies

* **Language**: [Dart](https://dart.dev/) (SDK version `^3.11.4`)
* **Framework**: [Flutter](https://flutter.dev/)
* **State & Navigation Management**: [GetX](https://pub.dev/packages/get)
* **Networking Client**: [Dio](https://pub.dev/packages/dio) for robust HTTP requests, interceptors, and error propagation
* **Local Caching**: [SharedPreferences](https://pub.dev/packages/shared_preferences) for session and tenant settings
* **Design & Typography**: [Google Fonts (Poppins)](https://pub.dev/packages/google_fonts) and Custom Material styling
* **Device / Bundle Info**: [Package Info Plus](https://pub.dev/packages/package_info_plus)

---

## ⚙️ Setup & Installation

### Prerequisites
Make sure you have Flutter installed and configured on your system. Run `flutter doctor` to verify.

### 1. Clone & Fetch Dependencies
```bash
git clone <repository-url>
cd EduNest-App
flutter pub get
```

### 2. Run the Application
Start the application locally on a connected device or emulator:
```bash
flutter run
```

### 3. Static Analysis
Verify code formatting and potential code issues:
```bash
flutter analyze
```

---

## 🏷️ Configuration and Flavors

The project is built to support different runtime environments (Dev, UAT, Production) dynamically:

* **Dev API Environment**: `http://10.153.154.76:8080`
* **UAT API Environment**: `https://uat-api.mynovian.com`
* **Production API Environment**: `https://api.mynovian.com`

Configured env values can be swapped dynamically within the initialization sequence inside `lib/flavors/edunest_environment.dart`.
