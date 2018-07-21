import 'package:flutter_account_kit/src/countries.dart';

/// Assert valid types for selected option [propName].
void assertArray(dynamic prop, String propName) {
  assert(prop == null || prop is List,
      "'$propName' should be an array, '$prop' given.");
}

/// Assert valid types for selected option props.
void assertString(dynamic prop, String propName) {
  assert(prop == null || prop is String,
      "'$propName' should be a String, '$prop' given.");
}

/// Assert all specified country codes are supported.
void assertValidityOfCountryCodes(Map<String, dynamic> options) {
  final countryBlacklist = options['countryBlacklist'];
  final countryWhitelist = options['countryWhitelist'];
  final defaultCountry = options['defaultCountry'];
  <String, dynamic>{
    "countryBlacklist": countryBlacklist == null ? [] : countryBlacklist,
    "countryWhitelist": countryWhitelist == null ? [] : countryWhitelist,
    "defaultCountry": defaultCountry == null ? [] : [defaultCountry]
  }.forEach((String collectionName, dynamic collection) {
    assertArray(collection, collectionName);
    collection.forEach((dynamic countryCode) {
      final label = '"$collectionName": Invalid value found.';

      assert(countryCode is String,
          '$label Value should be String, "$countryCode" found.');

      assert(
          countryCode == countryCode.toUpperCase(),
          '$label Value should be in uppercase (${countryCode
          .toUpperCase()}), "$countryCode" found.');

      assert(supported_countries.contains(countryCode),
          '$label Country code "$countryCode" in "$collectionName" is not supported');
    });
  });
}
