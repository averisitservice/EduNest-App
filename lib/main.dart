import 'package:edunest/app/core/services/push_notification_service.dart';
import 'package:edunest/app/data/model/set_config.dart';
import 'package:edunest/app/my_app.dart';
import 'package:edunest/flavors/edunest_environment.dart';
import 'package:edunest/flavors/global_configuration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SetAppConfig activeConfig = EduNestEnvironment.initialize(env: 'dev');

  GlobalConfiguration().loadConfig(activeConfig);

  await Firebase.initializeApp();
  await PushNotificationService.init();

  runApp(const MyApp());
}
