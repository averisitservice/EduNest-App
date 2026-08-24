# EduNest — Student Mobile App

Flutter mobile app for **students** of the EduNest school ERP. Students connect to
their school with a school code, sign in with a username and password, and can view
their profile, timetable, homework, notes, exam schedule, results, fee status, and
school contact info — and pay pending fees via Razorpay.

Part of a three-app system:

| Project | Role |
|---|---|
| **EduNest-App** (this repo) | Flutter mobile app — **students** |
| `EduNest-Web` | React admin panel — teachers / staff |
| `EduNest-Api` | Spring Boot REST API (serves both) |

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
| `device_info_plus` | Real device details on the Device Info screen; also used to derive the `deviceId` sent when registering an FCM token |
| `permission_handler` | Location/notification permission requests on first Home open |
| `package_info_plus` | App version |
| `google_fonts`, `intl` | Typography, date formatting |
| `razorpay_flutter` | In-app checkout UI for the Fee Payment screen |
| `url_launcher` | Opening external links (e.g. school contact phone/email) |
| `table_calendar` | Calendar widget (attendance / date-range pickers) |
| `firebase_core`, `firebase_messaging` | Firebase init + push notification delivery (`NotificationService`) |

## Architecture

Screens are `StatefulWidget` + `setState`, holding a repository directly — no GetX
controllers, no result-wrapper types.

```
lib/
  main.dart                       app entry — Firebase init, NotificationService.initialize(),
                                    selects env, runs MyApp
  firebase_options.dart           generated Firebase platform config (flutterfire configure)
  app/
    my_app.dart                   GetMaterialApp, theme
    core/
      base/base_repo.dart         BaseRepo (marker base class)
      network/
        dio_client.dart           DioClient.getInstance() -> fresh Dio + interceptor
        edunest_interceptors.dart attaches Bearer token; 401 -> clear + TenantPage
        error_helper.dart         ApiException + ErrorHelper.toApiException(e)
      services/
        common_service.dart       SharedPreferences: token, tenant, student, schoolCode
        subject_icon_service.dart maps a subject name -> icon + color pair
        notification_service.dart FCM init, foreground/background/tap handlers, local banner
                                    display, permission request, token sync on login/refresh
      helper/
        date_util.dart            date formatting helpers
        homework_status_helper.dart due-date -> "Due Today"/"Due Tomorrow"/"Due Completed" badge
      utils/
        app_urls.dart              AppUrls.someCall() -> full URL strings, grouped by module
        app_constants.dart         misc shared constants
      values/                      app_colors.dart, app_values.dart
    data/
      model/                       auth/, student/, homework/, exam/, fee/, timetable/, profile/,
                                    leave/, notification/, announcement/, attendance/
      repository/                  auth_repo, tenant_repo, profile_repo, features_repo, fee_repo,
                                    leave_repo, fcm_repo
    global_widgets/
      edunest_button / _text_field / _divider / _confirm_dialog / _date_picker / _empty_state
      edunest_filter.dart          shared bottom-sheet filter (This Week/Month/Custom Range),
                                    used by Homework, Notes, and Attendance
    UI/
      splash/                      SplashScreen (routes by stored token/tenant)
      login/                       tenant_page, login_page, forgot_password widget
      home/                        home_page (feature grid + attendance stats) + drawer_menu
      features/
        homework/                  homework_page (Date Wise / Subject Wise tabs + filter),
                                    homework_detail_page
        notes/                     notes_page (+ filter), notes_detail_page
        fee/                       fee_payment_page, fee_amount_dialog, fee_payment_handler
        leave/                     leave_list_page (own leave requests), leave_request_page (submit)
        announcement/              announcements_page, announcement_detail_page
        attendance_page.dart, exam_schedule_page.dart, results_page.dart (+ result_detail_page),
        timetable_page.dart
      profile/                     profile, school_contacts, faq, about_us, settings*
      notifications/               notification_page (paged list, mark-as-read)
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
   (name, logos, banner) to local storage.
2. **Login** — username + password → `POST /api/auth/login` → saves session/refresh
   tokens, student profile, and tenant. Shows the school's logo and name.
   *Forgot password* emails a new password to the registered address. On success,
   `NotificationService.syncFcmToken()` uploads the device's current FCM token so pushes
   can be delivered to this session.
3. **Home** — feature grid (Time Table, Exam, Marks & Results, Announcements, Home
   Work, Notes, Fee Details, Leave) plus today's/monthly/average attendance stats. On
   first open, prompts for location and notification permissions (native OS dialogs,
   asked once — `NotificationService.requestNotificationPermission()`).
4. **Homework / Notes** — list with **Date Wise** and **Subject Wise** tabs (Homework
   only; Notes is a flat list), a filter (This Week / This Month / Custom Date Range —
   Homework defaults to "last 2 days" on first open) that re-queries the API with
   `fromDate`/`toDate`, and a detail screen per item.
5. **Attendance** — dedicated screen (reachable from Home) showing the same
   today's/monthly/average stats plus a per-day history.
6. **Announcements** — list + detail screen for announcements published by the school.
7. **Leave** — `leave_list_page` shows the student's own submitted leave requests
   (pending/approved) with delete for still-pending ones; `leave_request_page` submits a
   new request (date + reason).
8. **Notifications** — `notification_page` shows a paged list of in-app notifications
   (announcements, exam scheduling/results, homework/notes, leave status changes,
   birthdays), each markable as read. Pushes arrive via `NotificationService`
   (Firebase Messaging): shown as a local banner in foreground, handled by the OS in
   background, and tapping one — foreground, background, or from a terminated state —
   opens this screen.
9. **Fee Details** — shows pending/paid amount, then "Pay" opens the Razorpay checkout
   UI; on success the app verifies the payment with the backend and shows the result.
10. **Profile / Settings** — student profile, school contacts, change password, device
    info, FAQ, about us. Logging out calls `NotificationService.unregisterFcmToken()` to
    remove this device's token from the backend first.

## Student-facing API (all under `/api`, except the pre-login school lookup)

| Endpoint | Purpose |
|---|---|
| `GET /auth/tenant/{schoolCode}` | Resolve school by code (public, pre-login) |
| `POST /api/auth/login` | Login with `{username, password}` |
| `POST /api/auth/forgot-password` | Email a new password |
| `POST /api/auth/change-password` | Change password (authenticated) |
| `GET /api/auth/school/contact` | School contact details |
| `GET /api/student/home` | Home screen summary + attendance stats |
| `GET /api/student/{studentId}` | Full student profile |
| `GET /api/student/timetable` | Timetable (optional `day` query param) |
| `GET /api/student/exams` | Upcoming/past exams |
| `GET /api/student/homework` | Homework list (optional `fromDate`/`toDate`) |
| `GET /api/student/homework/{homeworkId}` | Homework detail |
| `GET /api/student/notes` | Notes list (optional `fromDate`/`toDate`) |
| `GET /api/student/notes/{noteId}` | Note detail |
| `GET /api/student/attendance` | Attendance history |
| `GET /api/student/results` | Exam results summary |
| `GET /api/student/results/{examId}` | Report card detail |
| `GET /api/student/announcements` | Announcements list |
| `GET /api/student/notifications` | Paged in-app notifications |
| `PATCH /api/student/notifications/{notificationId}/read` | Mark a notification read |
| `GET /api/student/notifications/unread-count` | Unread notification count |
| `GET /api/student/leave/list` | The logged-in student's own leave requests |
| `POST /api/student/leave` | Submit a new leave request (`leaveDate`, `reason`) |
| `DELETE /api/student/leave/{leaveId}` | Delete a still-pending leave request |
| `POST /api/student/fcm-token` | Register this device's FCM token (`fcmToken`, `deviceId`, `platform`) |
| `DELETE /api/student/fcm-token` | Unregister this device's FCM token (before logout) |
| `GET /api/student/fee/detail` | Fee summary (total/paid/pending) |
| `POST /api/student/fee/create-order` | Create a Razorpay order for a fee payment |
| `POST /api/student/fee/verify-payment` | Verify a completed Razorpay payment |

## Assets

Bundled images live in `assets/images/` and are declared in `pubspec.yaml`
(`full-icon.png`, `BackGroud.png`, `ChangePassword.png`).
