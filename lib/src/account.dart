import 'phone_number.dart';

/// The account information of the device.
///
/// Includes relevant information such as the accountId, phoneNumber or email
class Account {
  /// The accountId that is associated with this account.
  final String accountId;

  /// The phoneNumber that is associated with this account.
  final PhoneNumber phoneNumber;

  /// The email that is associated with this account.
  final String email;

  /// Constructs a new account instance from a [Map].
  ///
  /// This is used mostly internally by this library, but could be useful if
  /// storing the account locally by using the [toMap] method.
  Account.fromMap(Map<String, dynamic> map)
      : accountId = map['accountId'],
        phoneNumber = map['phoneNumber'] != null
            ? new PhoneNumber.fromMap(
          map['phoneNumber'].cast<String, dynamic>(),
        )
            : null,
        email = map['email'];

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this account as JSON and then
  /// storing it locally
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accountId': accountId,
      'phoneNumber': phoneNumber.toMap(),
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Account &&
              runtimeType == other.runtimeType &&
              phoneNumber == other.phoneNumber &&
              accountId == other.accountId;

  @override
  int get hashCode =>
      accountId.hashCode ^ phoneNumber.hashCode ^ email.hashCode;
}