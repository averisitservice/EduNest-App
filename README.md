# EduNest — Student Mobile App

Flutter mobile app for **students** of the EduNest school ERP. Students connect to
their school with a school code, sign in with a username and password, and view
their profile, class details, and school information.

Part of a three-app system:

| Project | Role |
|---|---|
| **EduNest-App** (this repo) | Flutter mobile app — **students** |
| `EduNest-Web` | React admin panel — teachers / staff |
| `EduNest-backend` | Spring Boot REST API (serves both) |

## Getting started

```bash
flutter pub get
flutter run
flutter analyze
```

Requires the Flutter SDK (Dart `^3.11.4`).

### Environment / API base URL

The environment is selected in `lib/main.dart` via `EduNestEnvironment.initialize(env: 'dev')`.
Base URLs live in `lib/flavors/edunest_environment.dart`:

| env | base URL |
|---|---|
| `dev` | `http://10.185.117.76:8081` (local backend, port 8081) |
| `uat` | `https://uat-api.mynovian.com` |
| `prod`| `https://api.mynovian.com` |

> The `dev` URL is cleartext `http://`. Android release and iOS block cleartext by
> default, so it may work in debug but fail in release without the network config in
> `android/.../network_security_config.xml` and `ios/Runner/Info.plist`.

## Dependencies

| Package | Used for |
|---|---|
| `dio` | HTTP client |
| `get` | Navigation + snackbars (`GetMaterialApp`) |
| `shared_preferences` | Local storage (token, tenant, student) |
| `cached_network_image` | Disk-cached school banner / logo / photo |
| `device_info_plus` | Real device details on the Device Info screen |
| `package_info_plus` | App version |
| `google_fonts`, `intl` | Typography, date formatting |

## Architecture

Follows the conventions of the team's `ChatApp-Frontend` project — **no GetX
controllers, no result-wrapper types**. Screens are `StatefulWidget` + `setState`,
holding a repository directly.

```
lib/
  main.dart                       app entry — selects env, runs MyApp
  app/
    my_app.dart                   GetMaterialApp, theme
    core/
      base/base_repo.dart         BaseRepo (marker base class)
      network/
        dio_client.dart           DioClient.getInstance() -> fresh Dio + interceptor
        edunest_interceptors.dart attaches Bearer token; 401 -> clear + TenantPage
        error_helper.dart         ApiException + ErrorHelper.toApiException(e)
      services/common_service.dart SharedPreferences: token, tenant, student, schoolCode
      utils/app_urls.dart          AppUrls.someCall() -> full URL strings
      values/                      app_colors.dart, app_values.dart
    data/
      model/                       tenant, student, student_detail, school_contact, login_response
      repository/                  auth_repo, tenant_repo, profile_repo
    global_widgets/                edunest_button / _text_field / _divider
    UI/
      splash/                      SplashScreen (routes by stored token/tenant)
      login/                       tenant_page, login_page, forgot_password widget
      home/                        home_page + drawer_menu
      profile/                     profile, school_contacts, faq, about_us, settings*
      notifications/
  flavors/                         environment + global configuration
```

### Networking pattern

```dart
// repository — thin, owns the try/catch, throws ApiException
class AuthRepo extends BaseRepo {
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final res = await DioClient.getInstance().post(
        AppUrls.login(),
        data: {"username": username, "password": password},
      );
      return LoginResponseModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
```

```dart
// screen — StatefulWidget holds the repo, catches ApiException for inline errors
final AuthRepo _authRepo = AuthRepo();
try {
  final result = await _authRepo.login(username, password);
  // save + navigate
} on ApiException catch (e) {
  setState(() => passwordError = e.message);
}
```

The API envelope is `{ success, errors, data }`; repositories read `res.data['data']`.
`EdunestInterceptors` adds `Authorization: Bearer <token>` from `CommonService`, and on
`401` clears storage and returns the user to the Tenant page.

## App flow

```
Splash ──► token stored?  ──yes──►  Home
        └► tenant stored? ──yes──►  Login   (enter username + password)
        └► otherwise      ─────────►  Tenant  (enter school code)
```

1. **Tenant** — enter school code → `GET /auth/tenant/{schoolCode}` → saves the school
   (name, logos, banner, primary color) to local storage.
2. **Login** — username + password → `POST /api/auth/login` → saves session/refresh
   tokens, student profile, and tenant. Shows the school's logo and name.
   *Forgot password* emails a new password to the registered address.
3. **Home / Profile** — student data loads from the API (e.g. `GET /api/student/{id}`,
   `GET /api/school/contact`); change password via `POST /api/auth/change-password`.

## Student-facing API (all under `/api`, except the pre-login school lookup)

| Endpoint | Purpose |
|---|---|
| `GET /auth/tenant/{schoolCode}` | Resolve school by code (public, pre-login) |
| `POST /api/auth/login` | Login with `{username, password}` |
| `POST /api/auth/forgot-password` | Email a new password |
| `POST /api/auth/change-password` | Change password (authenticated) |
| `GET /api/student/{studentId}` | Full student profile |
| `GET /api/school/contact` | School contact details |

## Assets

Bundled images live in `assets/images/` and are declared in `pubspec.yaml`
(`full-icon.png`, `BackGroud.png`, `ChangePassword.png`, `DeviceInfo.png`).
