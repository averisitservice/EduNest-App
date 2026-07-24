import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/set_config.dart';

class EduNestEnvironment {
  static SetAppConfig initialize({required String env}) {
    late String serverApiUrl;

    switch (env.toLowerCase()) {
      case 'dev':
        serverApiUrl = 'http://10.185.117.76:8081';
        break;
      case 'uat':
        serverApiUrl = 'https://uat-api.mynovian.com';
        break;
      case 'prod':
        serverApiUrl = 'https://api.mynovian.com';
        break;
      default:
        serverApiUrl = 'https://api.mynovian.com';
    }

    AppUrls.baseUrl = serverApiUrl;

    return SetAppConfig(environment: env, apiUrl: serverApiUrl);
  }
}
