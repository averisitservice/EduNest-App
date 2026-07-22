import 'package:edunest/app/data/model/set_config.dart';
import 'package:edunest/app/my_app.dart';
import 'package:edunest/flavors/edunest_environment.dart';
import 'package:edunest/flavors/global_configuration.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SetAppConfig activeConfig = EduNestEnvironment.initialize(env: 'uat');

  GlobalConfiguration().loadConfig(activeConfig);

  runApp(const MyApp());
}
