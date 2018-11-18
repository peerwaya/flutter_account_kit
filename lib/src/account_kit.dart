import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_account_kit/src/access_token.dart';
import 'package:flutter_account_kit/src/account.dart';
import 'package:flutter_account_kit/src/login_result.dart';
import 'package:flutter_account_kit/src/config.dart';
import 'package:flutter_account_kit/src/login_type.dart';

/// AccountKit is a plugin for authenticating your users using the native
/// Android & iOS Facebook Accountkit Login SDKs
/// The login methods return a [LoginResult] that contains relevant
/// information about whether the user logged in, cancelled the login dialog,
/// or if the login flow resulted in an error.
///
/// For example, this sample code illustrates how to handle the different
/// cases:
///
/// ```dart
/// import 'package:flutter_account_kit/flutter_account_kit.dart';
///
/// AccountKit akt = new AccountKit();
/// LoginResult result =
///   await akt.logInWithPhone();
///
/// switch (result.status) {
///   case LoginStatus.loggedIn:
///     _sendTokenToServer(result.accessToken.token);
///     _showLoggedInUI();
///     break;
///   case LoginStatus.cancelledByUser:
///     _showConvincingMessageOnUI();
///     break;
///   case LoginStatus.error:
///     _showErrorOnUI();
///     break;
/// }
///```
/// Before using this plugin, some initial setup is required for the Android
/// and iOS clients. See the README for detailed instructions.
class FlutterAccountKit {
  static const MethodChannel channel =
      const MethodChannel('com.peerwaya/flutter_account_kit');

  /// The default configuration map
  ///
  /// see https://developers.facebook.com/docs/accountkit/android/accountkitconfigurationbuilder
  static final Config defaultConfig = Config();

  static String toNativeLoginType(LoginType type) {
    switch (type) {
      case LoginType.email:
        return 'email';
      case LoginType.phone:
        return 'phone';
    }
    throw new StateError('Invalid accountkit type.');
  }

  /// Enables the client access token flow
  ///
  /// Set to [ResponseType.token] if the Enable Client Access Token Flow switch in your app's dashboard is ON
  /// and [ResponseType.code] if it is OFF. It is set to [ResponseType.token] by default

  /// Sets the accountkit configuration options
  ///
  /// Options can be set to null. In this case, the default config [FlutterAccountKit.defaultConfig] is used

  Future<void> configure(Config options) async {
    var config = options;
    if (config == null) {
      config = defaultConfig;
    }
    await channel.invokeMethod('configure', {'configOptions': config.toMap()});
  }

  /// Returns whether the user is currently logged in or not.
  ///
  /// Convenience method for checking if the [currentAccessToken] is null.
  Future<bool> get isLoggedIn async => await currentAccessToken != null;

  /// Retrieves the current access token for the application.
  ///
  /// This could be useful for logging in the user automatically in the case
  /// where you don't persist the access token in your Flutter app yourself.
  ///
  /// For example:
  ///
  /// ```dart
  /// final AccessToken accessToken = await AccountKit.currentAccessToken;
  ///
  /// if (accessToken != null) {
  ///   Handle Returning User
  /// } else {
  ///   Handle new or logged out user
  /// }
  /// ```
  ///
  /// If the user is not logged in, this returns null.
  Future<AccessToken> get currentAccessToken async {
    final Map<dynamic, dynamic> accessToken =
        await channel.invokeMethod('getCurrentAccessToken');

    if (accessToken == null) {
      return null;
    }

    return AccessToken.fromMap(accessToken.cast<String, dynamic>());
  }

  /// Retrieves the current account for the application.
  ///
  /// If you began the login session with [ResponseType.token],
  /// it's possible to access the Account Kit ID, phone number and email of
  /// the current account via a call to currentAccount.
  ///
  /// ```dart
  /// final Account account = await AccountKit.currentAccount;
  ///
  /// if (account != null) {
  ///   Get Account Kit ID
  ///   String accountKitId = account.accountId;
  ///   Get phone number
  ///   PhoneNumber phoneNumber = account.phoneNumber;
  ///   Get email
  ///   String email = account.email;
  /// } else {
  ///   Handle null account
  /// }
  /// ```
  ///
  /// If the user is not logged in, this returns null.
  Future<Account> get currentAccount async {
    final Map<dynamic, dynamic> account =
        await channel.invokeMethod('getCurrentAccount');

    if (account == null) {
      return null;
    }

    return Account.fromMap(account.cast<String, dynamic>());
  }

  /// Logs the user in with email.
  ///
  /// This defaults to using the [ResponseType.token] access flow
  ///
  /// Returns a [LoginResult] that contains relevant information about
  /// the current login status. For sample code, see the [FlutterAccountKit] class-
  /// level documentation.
  Future<LoginResult> logInWithEmail() async {
    final Map<dynamic, dynamic> result = await channel.invokeMethod(
        'login', {'loginType': toNativeLoginType(LoginType.email)});

    return _deliverResult(
        new LoginResult.fromMap(result.cast<String, dynamic>()));
  }

  /// Logs the user in with phone number.
  ///
  /// This defaults to using the [ResponseType.token] access flow
  ///
  /// Returns a [LoginResult] that contains relevant information about
  /// the current login status. For sample code, see the [FlutterAccountKit] class-
  /// level documentation.
  Future<LoginResult> logInWithPhone() async {
    final Map<dynamic, dynamic> result = await channel.invokeMethod(
        'login', {'loginType': toNativeLoginType(LoginType.phone)});

    return _deliverResult(
        new LoginResult.fromMap(result.cast<String, dynamic>()));
  }

  /// Logs the currently logged in user out.
  Future<void> logOut() async => channel.invokeMethod('logOut');

  /// There's a weird bug where calling Navigator.push (or any similar method)
  /// straight after getting a result from the method channel causes the app
  /// to hang.
  ///
  /// As a hack/workaround, we add a new task to the task queue with a slight
  /// delay, using the [Future.delayed] constructor.
  ///
  /// For more context, see this issue:
  /// https://github.com/roughike/flutter_facebook_login/issues/14
  Future<T> _deliverResult<T>(T result) {
    return Future.delayed(const Duration(milliseconds: 500), () => result);
  }
}
