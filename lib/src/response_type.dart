/// Represents your application's authorization setting in the Facebook developer portal dashboard
enum ResponseType {
  /// use [token] if the Enable Client Access Token Flow switch in your app's dashboard is ON
  token,

  /// use [code] if the Enable Client Access Token Flow switch in your app's dashboard is OFF
  code,
}
