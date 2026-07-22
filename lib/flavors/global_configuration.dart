import 'package:edunest/app/data/model/set_config.dart';

class GlobalConfiguration {
  static final GlobalConfiguration _instance = GlobalConfiguration._internal();

  factory GlobalConfiguration() {
    return _instance;
  }

  GlobalConfiguration._internal();

  late SetAppConfig appConfig;

  GlobalConfiguration loadConfig(SetAppConfig envConfig) {
    appConfig = envConfig;
    return _instance;
  }
}
