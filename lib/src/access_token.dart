/// The access token for using Facebook APIs.
///
/// Includes the token itself, along with useful metadata about it, such as the
/// associated accountId that the token contains.
class AccessToken {
  /// The app id
  final String appId;

  /// The access token returned by the Facebook login, which can be used to
  /// access Facebook APIs.
  final String token;

  /// The id for the accountId that is associated with this access token.
  final String accountId;

  /// The time [AccessToken.token] was last refreshed in milliseconds
  final int lastRefresh;

  /// The interval between between token refresh in seconds
  final int refreshIntervalSeconds;

  /// Constructs a new access token instance from a [Map].
  ///
  /// This is used mostly internally by this library, but could be useful if
  /// storing the token locally by using the [toMap] method.
  AccessToken.fromMap(Map<String, dynamic> map)
      : appId = map['appId'],
        token = map['token'],
        accountId = map['accountId'],
        lastRefresh = map['lastRefresh'],
        refreshIntervalSeconds = map['refreshIntervalSeconds'];

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this access token as JSON and then
  /// storing it locally
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appId': appId,
      'token': token,
      'accountId': accountId,
      'lastRefresh': lastRefresh,
      'refreshIntervalSeconds': refreshIntervalSeconds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessToken &&
          runtimeType == other.runtimeType &&
          appId == other.appId &&
          token == other.token &&
          accountId == other.accountId &&
          lastRefresh == other.lastRefresh &&
          refreshIntervalSeconds == other.refreshIntervalSeconds;

  @override
  int get hashCode =>
      appId.hashCode ^
      token.hashCode ^
      accountId.hashCode ^
      lastRefresh.hashCode ^
      refreshIntervalSeconds.hashCode;
}
