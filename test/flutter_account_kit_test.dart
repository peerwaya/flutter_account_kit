import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_account_kit/flutter_account_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'custom_matchers.dart';

void main() {
  group("FlutterAccountKit", () {
    const MethodChannel channel = const MethodChannel(
      'com.peerwaya/flutter_account_kit',
    );
    const countryCode = '234';
    const number = '8090000000';

    const kPhoneNumber =
        const PhoneNumber(countryCode: countryCode, number: number);

    const kPhoneNumberMap = {'countryCode': '234', 'number': '8090000000'};

    const kAccessToken = {
      'appId': 'test_app_id',
      'accountId': 'test_account_id',
      'token': 'test_token',
      'lastRefresh': 1532080630941,
      'refreshIntervalSeconds': 3600
    };

    const kAccount = {
      'accountId': 'test_account_id',
      'phoneNumber': const {'countryCode': countryCode, 'number': number},
      'email': 'you@example.com'
    };

    const kLoggedInResponseTypeToken = const {
      'status': 'loggedIn',
      'accessToken': kAccessToken,
    };

    const kLoggedInResponseTypeCode = const {
      'status': 'loggedIn',
      'code': 'test_code',
    };

    const kCancelledByUserResponse = const {'status': 'cancelledByUser'};

    const kErrorResponse = const {
      'status': 'error',
      'errorMessage': 'test error message',
    };

    final kTheme = AccountKitTheme(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      buttonBackgroundColor: Color.fromARGB(255, 0, 0, 0),
      buttonTextColor: Color.fromARGB(255, 255, 255, 255),
      inputTextColor: Color.fromARGB(255, 255, 255, 255),
      statusBarStyle: StatusBarStyle.lightStyle,
    );

    final kValidConfig = Config()
      ..facebookNotificationsEnabled = true
      ..receiveSMS = true
      ..readPhoneStateEnabled = true
      ..initialPhoneNumber = kPhoneNumber
      ..defaultCountry = "NG"
      ..theme = kTheme;

    final kValidConfigMap = {
      'facebookNotificationsEnabled': true,
      'readPhoneStateEnabled': true,
      'receiveSMS': true,
      'defaultCountry': 'NG',
      'responseType': 'token',
      'titleType': 'login',
      'initialPhoneCountryPrefix': '234',
      'initialPhoneNumber': '8090000000',
      'theme': {
        'backgroundColor': {'r': 1.0, 'g': 1.0, 'b': 1.0, 'a': 1.0},
        'buttonBackgroundColor': {'r': 0.0, 'g': 0.0, 'b': 0.0, 'a': 1.0},
        'buttonTextColor': {'r': 1.0, 'g': 1.0, 'b': 1.0, 'a': 1.0},
        'inputTextColor': {'r': 1.0, 'g': 1.0, 'b': 1.0, 'a': 1.0},
        'statusBarStyle': 1
      },
    };

    final Config kDefaultConfig = Config();

    final List<MethodCall> log = [];
    FlutterAccountKit akt;

    void setMethodCallResponse(Map<String, dynamic> response) {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return new Future.value(response);
      });
    }

    void expectPhoneNumberParsedCorrectly(PhoneNumber phoneNumber) {
      expect(phoneNumber.countryCode, countryCode);
      expect(phoneNumber.number, number);
    }

    void expectAccessTokenParsedCorrectly(AccessToken accessToken) {
      expect(accessToken.token, 'test_token');
      expect(accessToken.accountId, 'test_account_id');
      expect(accessToken.appId, 'test_app_id');
      expect(accessToken.lastRefresh, 1532080630941);
      expect(accessToken.refreshIntervalSeconds, 3600);
    }

    void expectAccountParsedCorrectly(Account account) {
      expect(account.accountId, 'test_account_id');
      expect(account.email, 'you@example.com');
      expectPhoneNumberParsedCorrectly(account.phoneNumber);
    }

    setUp(() async {
      akt = new FlutterAccountKit();
      log.clear();
    });

    test('$AccountKitTheme#toMap()', () async {
      setMethodCallResponse(null);
      final Map<String, dynamic> map = kTheme.toMap();
      expect(
        map,
        {
          'backgroundColor': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
          'buttonBackgroundColor': {'r': 0, 'g': 0, 'b': 0, 'a': 1},
          'buttonTextColor': {'r': 1.0, 'g': 1.0, 'b': 1.0, 'a': 1.0},
          'inputTextColor': {'r': 1.0, 'g': 1.0, 'b': 1.0, 'a': 1.0},
          'statusBarStyle': 1
        },
      );
    });

    test('$Config#toMap()', () async {
      setMethodCallResponse(null);
      final Map<String, dynamic> map = kValidConfig.toMap();
      expect(
        map,
        kValidConfigMap,
      );
    });

    test('$AccessToken#fromMap()', () async {
      setMethodCallResponse(null);
      final AccessToken accessToken = AccessToken.fromMap(kAccessToken);
      expectAccessTokenParsedCorrectly(accessToken);
    });

    test('$AccessToken#toMap()', () async {
      setMethodCallResponse(kLoggedInResponseTypeToken);

      final LoginResult result = await akt.logInWithEmail();
      final Map<String, dynamic> map = result.accessToken.toMap();

      expect(
        map,
        // Just copy-pasting the kAccessToken here. This is just in case;
        // we could accidentally make this test non-deterministic.
        {
          'appId': 'test_app_id',
          'accountId': 'test_account_id',
          'token': 'test_token',
          'lastRefresh': 1532080630941,
          'refreshIntervalSeconds': 3600
        },
      );
    });

    test('configure - with valid options', () async {
      setMethodCallResponse(null);
      await akt.configure(kValidConfig);
      expect(
          log,
          contains(
            isMethodCall(
              'configure',
              arguments: {
                'configOptions': kValidConfigMap,
              },
            ),
          ));
    });

    test('$Config - invalid blacklist (country code) array', () async {
      setMethodCallResponse(null);
      expect(() => Config()..countryBlacklist = ['NGN'], throwsAssertionError);
    });

    test('$Config - invalid whitelist (country code)  array', () async {
      setMethodCallResponse(null);
      expect(() => Config()..countryWhitelist = ['NGN'], throwsAssertionError);
    });

    test('$Config - invalid blacklist(lowercase country code) array', () async {
      setMethodCallResponse(null);
      expect(() => Config()..countryBlacklist = ['ng'], throwsAssertionError);
    });

    test('$Config - invalid whitelist (country code) array', () async {
      setMethodCallResponse(null);
      expect(() => Config()..countryWhitelist = ['NGN'], throwsAssertionError);
    });

    test('$Config - invalid whitelist (lowercase country code) array',
        () async {
      setMethodCallResponse(null);
      expect(() => Config()..countryWhitelist = ['ng'], throwsAssertionError);
    });

    test('configure - empty black list is removed', () async {
      setMethodCallResponse(null);
      final config = Config()..countryBlacklist = [];
      await akt.configure(config);
      expect(log, [
        isMethodCall(
          'configure',
          arguments: {
            'configOptions': kDefaultConfig.toMap(),
          },
        ),
      ]);
    });

    test('configure - empty white list is removed', () async {
      setMethodCallResponse(null);
      final config = Config()..countryWhitelist = [];
      await akt.configure(config);
      expect(log, [
        isMethodCall(
          'configure',
          arguments: {
            'configOptions': kDefaultConfig.toMap(),
          },
        ),
      ]);
    });

    test('$Config - null responseType is not allowed', () async {
      setMethodCallResponse(null);
      // Setting a null responseType is not allowed.
      expect(() => Config()..responseType = null, throwsAssertionError);
    });

    test('$Config - null titleType is not allowed', () async {
      setMethodCallResponse(null);
      // Setting a null titleType is not allowed.
      expect(() => Config()..titleType = null, throwsAssertionError);
    });

    test('$AccessToken equality test', () {
      final AccessToken first = new AccessToken.fromMap(kAccessToken);
      final AccessToken second = new AccessToken.fromMap(kAccessToken);
      expect(first, equals(second));
    });

    test('$Account equality test', () {
      final Account first = new Account.fromMap(kAccount);
      final Account second = new Account.fromMap(kAccount);
      expect(first, equals(second));
    });

    test('$PhoneNumber equality test', () {
      final PhoneNumber first = new PhoneNumber.fromMap(kPhoneNumberMap);
      final PhoneNumber second = new PhoneNumber.fromMap(kPhoneNumberMap);
      expect(first, equals(second));
    });

    test('$PhoneNumber#toMap()', () async {
      final Map<String, dynamic> map = kPhoneNumber.toMap();
      expect(
        map,
        kPhoneNumberMap,
      );
    });

    test('responseType - token is the default', () async {
      setMethodCallResponse(kCancelledByUserResponse);

      await akt.logInWithEmail();
      await akt.logInWithPhone();

      expect(
        log,
        [
          isMethodCall(
            'login',
            arguments: {
              'loginType': 'email',
            },
          ),
          isMethodCall(
            'login',
            arguments: {
              'loginType': 'phone',
            },
          ),
        ],
      );
    });

    test('responseType - test configure with all options', () async {
      final config = Config()..responseType = ResponseType.token;
      await akt.configure(config);

      config..responseType = ResponseType.code;
      await akt.configure(config);

      expect(
        log,
        [
          isConfiguredWithResponseType(ResponseType.token),
          isConfiguredWithResponseType(ResponseType.code),
        ],
      );
    });

    test('titleType - test configure with all options', () async {
      final config = Config()..titleType = TitleType.login;
      await akt.configure(config);

      config..titleType = TitleType.appName;
      await akt.configure(config);

      expect(
        log,
        [
          isConfiguredWithTitleType(TitleType.login),
          isConfiguredWithTitleType(TitleType.appName),
        ],
      );
    });

    test('loginWithEmail - user logged in with response type token', () async {
      setMethodCallResponse(kLoggedInResponseTypeToken);

      final LoginResult result = await akt.logInWithEmail();
      expect(result.status, LoginStatus.loggedIn);
      expectAccessTokenParsedCorrectly(result.accessToken);

      expect(
        log,
        [
          isMethodCall(
            'login',
            arguments: {
              'loginType': 'email',
            },
          ),
        ],
      );
    });

    test('loginWithEmail - cancelled by user with response type token',
        () async {
      setMethodCallResponse(kCancelledByUserResponse);

      final LoginResult result = await akt.logInWithEmail();

      expect(result.status, LoginStatus.cancelledByUser);
      expect(result.accessToken, isNull);
    });

    test('loginWithEmail - error with response type token', () async {
      setMethodCallResponse(kErrorResponse);

      final LoginResult result = await akt.logInWithEmail();

      expect(result.status, LoginStatus.error);
      expect(result.errorMessage, 'test error message');
      expect(result.accessToken, isNull);
    });

    test('loginWithPhone - user logged in with response type token', () async {
      setMethodCallResponse(kLoggedInResponseTypeToken);

      final LoginResult result = await akt.logInWithPhone();

      expect(result.status, LoginStatus.loggedIn);
      expectAccessTokenParsedCorrectly(result.accessToken);

      expect(
        log,
        [
          isMethodCall(
            'login',
            arguments: {
              'loginType': 'phone',
            },
          ),
        ],
      );
    });

    test('loginWithPhone - cancelled by user with response type token',
        () async {
      setMethodCallResponse(kCancelledByUserResponse);

      final LoginResult result = await akt.logInWithPhone();

      expect(result.status, LoginStatus.cancelledByUser);
      expect(result.accessToken, isNull);
    });

    test('loginWithPhone - error with response type token', () async {
      setMethodCallResponse(kErrorResponse);

      final LoginResult result = await akt.logInWithPhone();

      expect(result.status, LoginStatus.error);
      expect(result.errorMessage, 'test error message');
      expect(result.accessToken, isNull);
    });

    test('loginWithEmail - user logged in with response type code', () async {
      setMethodCallResponse(kLoggedInResponseTypeCode);
      final config = Config(responseType: ResponseType.code);
      await akt.configure(config);
      final LoginResult result = await akt.logInWithEmail();
      expect(result.status, LoginStatus.loggedIn);
      expect(result.code, 'test_code');

      expect(
        log,
        [
          isConfiguredWithResponseType(ResponseType.code),
          isMethodCall(
            'login',
            arguments: {
              'loginType': 'email',
            },
          ),
        ],
      );
    });

    test('loginWithEmail - cancelled by user with response type code',
        () async {
      setMethodCallResponse(kCancelledByUserResponse);

      final config = Config(responseType: ResponseType.code);
      await akt.configure(config);
      final LoginResult result = await akt.logInWithEmail();

      expect(result.status, LoginStatus.cancelledByUser);
      expect(result.code, isNull);
    });

    test('loginWithEmail - error with response type code', () async {
      setMethodCallResponse(kErrorResponse);
      final config = Config(responseType: ResponseType.code);
      await akt.configure(config);

      final LoginResult result = await akt.logInWithEmail();

      expect(result.status, LoginStatus.error);
      expect(result.errorMessage, 'test error message');
      expect(result.code, isNull);
    });

    test('loginWithPhone - user logged in with response type code', () async {
      setMethodCallResponse(kLoggedInResponseTypeCode);
      final config = Config(responseType: ResponseType.code);
      await akt.configure(config);

      final LoginResult result = await akt.logInWithPhone();

      expect(result.status, LoginStatus.loggedIn);
      expect(result.code, 'test_code');

      expect(
        log,
        [
          isConfiguredWithResponseType(ResponseType.code),
          isMethodCall(
            'login',
            arguments: {
              'loginType': 'phone',
            },
          ),
        ],
      );
    });

    test('loginWithPhone - cancelled by user with response type code',
        () async {
      setMethodCallResponse(kCancelledByUserResponse);
      final config = Config(responseType: ResponseType.code);
      await akt.configure(config);
      final LoginResult result = await akt.logInWithPhone();

      expect(result.status, LoginStatus.cancelledByUser);
      expect(result.code, isNull);
    });

    test('loginWithPhone - error with response type code', () async {
      setMethodCallResponse(kErrorResponse);
      final config = Config(responseType: ResponseType.code);
      await akt.configure(config);
      final LoginResult result = await akt.logInWithPhone();

      expect(result.status, LoginStatus.error);
      expect(result.errorMessage, 'test error message');
      expect(result.code, isNull);
    });

    test('logOut test', () async {
      setMethodCallResponse(null);

      await akt.logOut();

      expect(
        log,
        [
          isMethodCall(
            'logOut',
            arguments: null,
          ),
        ],
      );
    });

    test('get isLoggedIn - false when currentAccessToken null', () async {
      setMethodCallResponse(null);

      final bool isLoggedIn = await akt.isLoggedIn;
      expect(isLoggedIn, isFalse);
    });

    test('get isLoggedIn - true when currentAccessToken is not null', () async {
      setMethodCallResponse(kAccessToken);

      final bool isLoggedIn = await akt.isLoggedIn;
      expect(isLoggedIn, isTrue);
    });

    test('get currentAccessToken - handles null response gracefully', () async {
      setMethodCallResponse(null);

      final AccessToken accessToken = await akt.currentAccessToken;
      expect(accessToken, isNull);
    });

    test('get currentAccessToken - when token returned, parses it properly',
        () async {
      setMethodCallResponse(kAccessToken);

      final AccessToken accessToken = await akt.currentAccessToken;
      expectAccessTokenParsedCorrectly(accessToken);
    });

    test('get account - handles null response gracefully', () async {
      setMethodCallResponse(null);

      final Account account = await akt.currentAccount;
      expect(account, isNull);
    });

    test('get currentAccount - when account returned, parses it properly',
        () async {
      setMethodCallResponse(kAccount);

      final Account account = await akt.currentAccount;
      expectAccountParsedCorrectly(account);
    });
  });
}
