# EduNest-App — Project Analysis

Whole-project analysis of the Flutter student app: what it is, how it's built, what it does, and where the rough edges are.

## 1. What it is

A Flutter mobile app for **students** of the EduNest school ERP. A student picks their school (by code), signs in with username/password, and can view timetable, homework, notes, exams/results, attendance, apply for leave, pay pending fees (Razorpay), and manage their profile — with push notifications via Firebase.

It's one of three apps in the system:

| Project | Role |
|---|---|
| **EduNest-App** (this repo) | Flutter mobile app — students |
| `EduNest-Web` | React admin panel — teachers / staff |
| `EduNest-Api` | Spring Boot REST API (serves both) |

## 2. Tech stack

- **Framework**: Flutter (Dart SDK `^3.11.4`)
- **State/navigation**: `get` (GetX) — used only for `GetMaterialApp` routing/snackbars, **not** for GetX controllers or reactive state (see §4)
- **Networking**: `dio` + a custom interceptor (`EdunestInterceptors`) for bearer-token auth and 401 handling
- **Local storage**: `shared_preferences` (token, tenant, student profile, school code)
- **Push notifications**: `firebase_core` + `firebase_messaging` + `flutter_local_notifications` (foreground banners, background handler)
- **Payments**: `razorpay_flutter` (Fee Payment screen)
- **Other packages**: `google_fonts`, `intl`, `cached_network_image`, `device_info_plus`, `permission_handler`, `package_info_plus`, `url_launcher`, `table_calendar`, `cupertino_icons`
- **Dev tooling**: `flutter_lints` (via `flutter analyze`), `flutter_test` (present, but see §7 — no tests currently exist)

## 3. Project structure

```
lib/
  main.dart                       entry point — Firebase init, notification init, env select, runApp
  firebase_options.dart           generated Firebase config
  app/
    my_app.dart                   GetMaterialApp, theme, app-wide TextScaler clamp
    core/
      base/base_repo.dart         BaseRepo marker base class
      network/                    DioClient, EdunestInterceptors, ErrorHelper/ApiException
      services/                   CommonService (prefs), NotificationService (FCM), SubjectIconService
      helper/                     date_util, homework_status_helper
      utils/                      AppUrls (endpoint builders), AppConstants, responsive.dart
      values/                     app_colors.dart, app_values.dart
    data/
      model/                      one folder per domain: auth, student, homework, exam, fee, leave,
                                   timetable, attendance, profile
      repository/                 auth_repo, tenant_repo, profile_repo, features_repo, fee_repo, leave_repo
    global_widgets/                edunest_button, _text_field, _divider, _filter, _confirm_dialog,
                                   _date_picker, _empty_state
    UI/
      splash/                     SplashScreen — routes by stored token/tenant
      login/                      tenant_page, login_page, forgot_password widget
      home/                       home_page (feature grid + attendance stats) + drawer_menu
      features/
        homework/                 date-wise + subject-wise tabs, filter, detail page
        notes/                    list + filter, detail page
        fee/                      fee_payment_page, fee_amount_dialog, fee_payment_handler (Razorpay)
        leave/                    leave_list_page, leave_request_page
        exam_schedule_page.dart, results_page.dart, timetable_page.dart, attendance_page.dart
      profile/                    profile, school_contacts, faq, about_us, settings*
      notifications/              notification_page
  flavors/                        edunest_environment.dart, global_configuration.dart (env/base URL)
```

## 4. Architecture pattern

**No GetX controllers, no BLoC/Riverpod/Provider.** Screens are plain `StatefulWidget` + `setState`, each holding a repository instance directly:

```dart
// repository — thin, owns try/catch, throws ApiException
class AuthRepo extends BaseRepo {
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final res = await DioClient.getInstance().post(AppUrls.login(), data: {...});
      return LoginResponseModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
```

```dart
// screen — calls repo directly, catches ApiException for inline error UI
try {
  final result = await _authRepo.login(username, password);
} on ApiException catch (e) {
  setState(() => passwordError = e.message);
}
```

- API envelope: `{ success, errors, data }` — repositories unwrap `res.data['data']`.
- `EdunestInterceptors` attaches `Authorization: Bearer <token>` from `CommonService`; on `401` it clears storage and routes to `TenantPage`.
- `get` (GetX) is used purely as a routing/snackbar convenience via `GetMaterialApp` — there's no `GetxController`, `Obx`, or `.obs` state anywhere.

This keeps the codebase simple and consistent, at the cost of some repetition (each screen re-implements its own loading/error `setState` boilerplate — see §7).

## 5. App flow

```
Splash ──► token stored?  ──yes──►  Home
        └► tenant stored? ──yes──►  Login   (username + password)
        └► otherwise      ─────────►  Tenant  (school code)
```

1. **Tenant** — school code → `GET /auth/tenant/{schoolCode}` → saves school (name, logos, banner).
2. **Login** — username + password → `POST /api/auth/login` → saves tokens + student + tenant. *Forgot password* emails a new password.
3. **Home** — feature grid (Timetable, Exam, Results, Announcements, Homework, Notes, Fee, Leave) + attendance stats. Prompts for location/notification permission on first open.
4. **Homework / Notes** — Date Wise / Subject Wise tabs (Homework only), filter (This Week/Month/Custom Range — homework defaults to last 2 days), detail screen per item.
5. **Leave** — list of submitted leave requests + a request form (apply/delete).
6. **Fee Details** — pending/paid amount → Razorpay checkout → backend payment verification.
7. **Profile / Settings** — profile, school contacts, change password, device info, FAQ, about us.
8. **Notifications** — Firebase Cloud Messaging: foreground banner via `flutter_local_notifications`, background handler, tap-to-open handling, token refresh listener.

## 6. Student-facing API surface

All under `/api` except the pre-login tenant lookup (from `lib/app/core/utils/app_urls.dart`):

| Endpoint | Purpose |
|---|---|
| `GET /auth/tenant/{schoolCode}` | Resolve school by code (public, pre-login) |
| `POST /api/auth/login` | Login with `{username, password}` |
| `POST /api/auth/forgot-password` | Email a new password |
| `POST /api/auth/change-password` | Change password (authenticated) |
| `GET /api/auth/school/contact` | School contact details |
| `GET /api/student/home` | Home screen summary + attendance stats |
| `GET /api/student/{studentId}` | Full student profile |
| `GET /api/student/timetable` | Timetable (optional `day` query) |
| `GET /api/student/exams` | Upcoming/past exams |
| `GET /api/student/attendance` | Attendance records |
| `GET /api/student/homework` | Homework list (optional `fromDate`/`toDate`) |
| `GET /api/student/homework/{homeworkId}` | Homework detail |
| `GET /api/student/notes` | Notes list (optional `fromDate`/`toDate`) |
| `GET /api/student/notes/{noteId}` | Note detail |
| `GET /api/student/fee/detail` | Fee summary (total/paid/pending) |
| `POST /api/student/fee/create-order` | Create Razorpay order |
| `POST /api/student/fee/verify-payment` | Verify completed Razorpay payment |
| `GET /api/student/leave/list` | Submitted leave requests |
| `POST /api/student/leave` | Submit a leave request |
| `DELETE /api/student/leave/{leaveId}` | Delete/withdraw a leave request |

## 7. Environments

Selected in `lib/main.dart` via `EduNestEnvironment.initialize(env: 'dev')`; base URLs in `lib/flavors/edunest_environment.dart`:

| env | base URL |
|---|---|
| `dev` | `http://<local-ip>:8081` (cleartext HTTP, local backend) |
| `uat` | `https://uat-api.mynovian.com` |
| `prod` | `https://api.mynovian.com` |

⚠️ `dev` uses cleartext `http://`, which Android release / iOS block by default — network security config exceptions exist for this (`android/.../network_security_config.xml`, `ios/Runner/Info.plist`), but switching `env` to `dev` in a release build will fail without them.

## 8. Responsive design

As of the latest change, sizing is fully responsive with no external scaling package — `lib/app/core/utils/responsive.dart` provides a `BuildContext` extension:

- `context.rw(value)` / `context.rh(value)` — width/height scaling against a 375×812 reference, clamped 0.85×–1.35×
- `context.rf(value)` — font scaling that also honors the OS text-scale setting, clamped 0.9×–1.3×, floored/ceilinged 10–40px
- `context.isSmallPhone` / `isMediumPhone` / `isLargePhone` / `isFoldableOrTablet` breakpoints, `isPortrait`/`isLandscape`
- App-wide `TextScaler` clamp in `my_app.dart`; large-screen dialogs/cards get a `maxWidth` cap instead of stretching full-width

## 9. Notable gaps / risks

- **No automated tests** — `flutter_test` is a dependency and `test/` may exist per Flutter's default template, but no meaningful widget/unit tests were found covering repositories, models, or screens.
- **Repeated boilerplate** — because there's no shared state layer, loading/error/empty-state handling is re-implemented per screen (`edunest_empty_state.dart` and `edunest_confirm_dialog.dart` help, but each screen still wires its own `setState` flow).
- **Hardcoded `dev` IP** — `http://10.185.117.76:8081` is a developer's local machine IP baked into source; harmless for `uat`/`prod` builds but will silently fail for anyone else running `dev` without editing the file.
- **Cleartext HTTP in dev** — works only because of explicit network-security exceptions; a reminder to never point `prod`/`uat` at a non-HTTPS URL.
- **Debug `print` in production code** — `NotificationService`'s FCM handlers use `print` gated by `kDebugMode`, which is fine, but worth confirming no other `print`/`debugPrint` calls leak into release logs elsewhere.
- **Single environment switch point** — changing environments requires editing `lib/main.dart` and rebuilding, rather than a build-time flavor/dart-define; fine for the current team size but worth flagging if CI/CD per-environment builds are ever needed.

## 10. Summary

A small, pragmatic student-facing Flutter app: simple `StatefulWidget` + repository architecture (no state-management framework), a clear one-repo-per-domain data layer, Firebase push notifications, Razorpay payments, and — as of this analysis — a from-scratch responsive layout system covering phones through foldables. The main technical debt is the lack of automated tests and the per-screen repetition that comes from skipping a shared state/loading abstraction; everything else is consistent and easy to navigate for a codebase of this size.
