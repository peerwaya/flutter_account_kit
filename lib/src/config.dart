import 'package:flutter/material.dart';
import 'response_type.dart';
import 'title_type.dart';
import 'countries.dart';
import 'account_kit_theme.dart';
import 'phone_number.dart';

/// Assert all specified country codes are supported.
void assertValidityOfCountryCodes(List<String> countryCodes, String fieldName) {
  if (countryCodes == null) {
    return;
  }
  countryCodes.forEach((String countryCode) {
    final label = '"$fieldName": Invalid value found.';

    assert(
        countryCode == countryCode.toUpperCase(),
        '$label Value should be in uppercase (${countryCode
        .toUpperCase()}), "$countryCode" found.');

    assert(supported_countries.contains(countryCode),
        '$label Country code "$countryCode" in "$fieldName" is not supported');
  });
}

/// This Configures the flutter accountkit plugin
///
class Config {
  /// returns the [String] representation of the current responseType
  String _responseTypeAsString() {
    assert(_responseType != null, 'The response type was unexpectedly null.');
    switch (_responseType) {
      case ResponseType.token:
        return 'token';
      case ResponseType.code:
        return 'code';
    }

    throw new StateError('Invalid response type.');
  }

  /// returns the [String] representation of the current [Config.titleType]
  String _titleTypeAsString() {
    assert(_titleType != null, 'The response type was unexpectedly null.');
    switch (_titleType) {
      case TitleType.login:
        return 'login';
      case TitleType.appName:
        return 'app_name';
    }

    throw new StateError('Invalid response type.');
  }

  Config({
    this.initialAuthState,
    this.initialEmail,
    this.initialPhoneNumber,
    this.facebookNotificationsEnabled,
    this.theme,
    this.readPhoneStateEnabled,
    this.receiveSMS,
    ResponseType responseType = ResponseType.token,
    TitleType titleType = TitleType.login,
  })  : this._responseType = responseType,
        this._titleType = titleType;

  /// The response type that determines whether to use access token or authorization code login flow
  /// based on the setting in the Facebook developer portal
  ResponseType _responseType = ResponseType.token;

  /// The title of the Login Screen
  ///
  /// Set [TitleType.appName] to use your application's name as the title for the login screen,
  /// or [TitleType.login] to use a localized translation of "Login" as the title.
  ///
  TitleType _titleType = TitleType.login;

  /// A developer-generated nonce used to verify that the received response matches the request
  ///
  /// Fill this with a random value at runtime; when the login call returns,
  /// check that the corresponding param in the response matches the one
  /// you set in this method.
  String initialAuthState;

  /// Pre-fill the user's email address in the email login flow.
  ///
  String initialEmail;

  /// Pre-fill the user's phone number in the SMS login flow.
  ///
  PhoneNumber initialPhoneNumber;

  /// Allows receiving confirmation message via facebook notification
  ///
  /// If this flag is set, Account Kit offers the user the option to receive their confirmation
  /// message via a Facebook notification in the event of an SMS failure,
  bool facebookNotificationsEnabled;

  /// Set the [Theme] to use. IOS only
  AccountKitTheme theme;

  /// If the READ_PHONE_STATE permission is granted and this flag is true,
  /// the app will pre-fill the user's phone number in the SMS login flow
  ///
  /// Set to false if you wish to use the READ_PHONE_STATE permission yourself,
  /// but you do not want the user's phone number pre-filled by Account Kit.
  ///
  /// Android  only
  bool readPhoneStateEnabled;

  /// If the RECEIVE_SMS permission is granted and this flag is true,
  /// the app will automatically read the Account Kit confirmation SMS
  /// and pre-fill the confirmation code in the SMS login flow
  bool receiveSMS;

  /// Use this to specify a list of country codes to exclude during the SMS login flow
  ///
  /// Only the country codes in the blacklist are unavailable.
  /// People can still use the rest of Account Kit's supported country codes.
  /// If a country code appears in both the whitelist and the blacklist,
  /// the blacklist takes precedence and the country code is not available.
  /// Just like the whitelist, the value is an array of short country codes as defined by ISO 3166-1 Alpha 2.
  List<String> _countryBlacklist;

  /// Use this to specify a list of permitted country codes for use in the SMS login flow
  ///
  /// The value is an array of short country codes as defined by ISO 3166-1 Alpha 2.
  /// To restrict availability to just the US (+1) and
  /// The Netherlands (+31), pass in ["US", "NL"].
  List<String> _countryWhitelist;

  /// Set the default country code shown in the SMS login flow.
  String _defaultCountry;

  set titleType(TitleType titleType) {
    assert(titleType != null, 'The titleType cannot be null.');
    _titleType = titleType;
  }

  TitleType get titleType {
    return _titleType;
  }

  set responseType(ResponseType responseType) {
    assert(responseType != null, 'The responseType type cannot be null.');
    _responseType = responseType;
  }

  ResponseType get responseType {
    return _responseType;
  }

  set countryBlacklist(List<String> countryBlacklist) {
    assertValidityOfCountryCodes(countryBlacklist, 'countryBlacklist');
    _countryBlacklist = countryBlacklist;
  }

  List<String> get countryBlacklist {
    return _countryBlacklist;
  }

  set countryWhitelist(List<String> countryWhitelist) {
    assertValidityOfCountryCodes(countryWhitelist, 'countryWhitelist');
    _countryWhitelist = countryWhitelist;
  }

  List<String> get countryWhitelist {
    return _countryWhitelist;
  }

  set defaultCountry(String defaultCountry) {
    assertValidityOfCountryCodes([defaultCountry], 'defaultCountry');
    _defaultCountry = defaultCountry;
  }

  String get defaultCountry {
    return _defaultCountry;
  }

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this account as JSON and then
  /// storing it locally
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'initialAuthState': initialAuthState,
      'facebookNotificationsEnabled': facebookNotificationsEnabled,
      'readPhoneStateEnabled': readPhoneStateEnabled,
      'receiveSMS': receiveSMS,
      'defaultCountry': defaultCountry,
      'responseType': _responseTypeAsString(),
      'titleType': _titleTypeAsString(),
      'initialEmail': initialEmail,
      'initialPhoneCountryPrefix': initialPhoneNumber != null ? initialPhoneNumber.countryCode : null,
      'initialPhoneNumber': initialPhoneNumber != null ? initialPhoneNumber.number : null,
    };
    if (theme != null) {
      map['theme'] = theme.toMap();
    }

    if (countryWhitelist != null && countryWhitelist.isNotEmpty) {
      map['countryWhitelist'] = countryWhitelist;
    }

    if (countryBlacklist != null && countryBlacklist.isNotEmpty) {
      map['countryWhitelist'] = countryBlacklist;
    }

    /// remove null or empty keys
    final keysToRemove = <String>[];
    for (String key in map.keys) {
      if (map[key] == null) {
        keysToRemove.add(key);
      }
    }

    map.removeWhere((String key, dynamic val) => keysToRemove.contains(key));
    return map;
  }
}
