import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_account_kit/src/response_type.dart';
import 'package:flutter_account_kit/src/title_type.dart';

Matcher isConfiguredWithDefaultOptions() {
  return isMethodCall(
    'configure',
    arguments: {
      'configOptions': {
        'responseType': 'token',
        'titleType': 'login'
      },
    },
  );
}

Matcher isConfiguredWithTitleType(TitleType type) {
  return isMethodCall(
    'configure',
    arguments: {
      'configOptions': {
        'responseType': 'token',
        'titleType': type == TitleType.appName ? "app_name" : "login"
      },
    },
  );
}

Matcher isConfiguredWithResponseType(ResponseType type) {
  return isMethodCall(
    'configure',
    arguments: {
      'configOptions': {
        'responseType': type == ResponseType.token ? "token" : "code",
        'titleType': 'login'
      },
    },
  );
}

Matcher isEmailLogin() {
  return isMethodCall(
    'login',
    arguments: {'loginType': 'email'},
  );
}

Matcher isPhoneNumberLogin() {
  return isMethodCall(
    'login',
    arguments: {'loginType': 'phone'},
  );
}
