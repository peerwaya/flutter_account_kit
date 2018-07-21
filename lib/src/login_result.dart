import 'package:flutter_account_kit/src/access_token.dart';
import 'login_status.dart';

/// The result when the Facebook login flow has completed.
///
/// The login methods always return an instance of this class, whether the
/// user logged in, cancelled or the login resulted in an error. To handle
/// the different possible scenarios, first see what the [status] is.
///
/// To see a comprehensive example on how to handle the different login
/// results, see the [FacebookLogin] class-level documentation.
class LoginResult {
  /// The status after a Facebook login flow has completed.
  ///
  /// This affects the [accessToken], [code] and [errorMessage] variables and whether
  /// they're available or not. If the user cancelled the login flow,
  /// [accessToken], [code] and [errorMessage] are null.
  final LoginStatus status;

  /// The access token obtained after the user has
  /// successfully logged in.
  ///
  /// Only available when the [status] equals [LoginStatus.loggedIn] and responseType is [ResponseType.token]
  /// otherwise null.
  final AccessToken accessToken;

  /// The code obtained after the user has
  /// successfully logged in.
  ///
  /// Only available when the [status] equals [LoginStatus.loggedIn], and responseType is [ResponseType.code],
  /// /// otherwise null.
  final String code;

  /// The error message when the log in flow completed with an error.
  ///
  /// Only available when the [status] equals [FacebookLoginStatus.error],
  /// otherwise null.
  final String errorMessage;

  LoginResult.fromMap(Map<String, dynamic> map)
      : status = _parseStatus(map['status']),
        accessToken = map['accessToken'] != null
            ? new AccessToken.fromMap(
                map['accessToken'].cast<String, dynamic>(),
              )
            : null,
        code = map['code'],
        errorMessage = map['errorMessage'];

  static LoginStatus _parseStatus(String status) {
    switch (status) {
      case 'loggedIn':
        return LoginStatus.loggedIn;
      case 'cancelledByUser':
        return LoginStatus.cancelledByUser;
      case 'error':
        return LoginStatus.error;
    }

    throw new StateError('Invalid status: $status');
  }
}
