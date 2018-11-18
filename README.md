
# flutter_account_kit
[![pub package](https://img.shields.io/pub/v/flutter_account_kit.svg)](https://pub.dartlang.org/packages/flutter_account_kit)
 [![Build Status](https://travis-ci.org/peerwaya/flutter_account_kit.svg?branch=master)](https://travis-ci.org/peerwaya/flutter_account_kit) 
[![Coverage Status](https://coveralls.io/repos/github/peerwaya/flutter_account_kit/badge.svg?branch=master)](https://coveralls.io/github/peerwaya/flutter_account_kit?branch=master)
A Flutter plugin for allowing users to authenticate with the native Android &amp; iOS AccountKit SDKs

## How do I use it?

For complete API documentation, just see the [source code](https://github.com/peerwaya/flutter-account-kit/blob/master/lib/src/account_kit.dart).

```dart
import 'package:flutter_account_kit/flutter_account_kit.dart';

AccountKit akt = new AccountKit();
LoginResult result = await akt.logInWithPhone();

switch (result.status) {
  case LoginStatus.loggedIn:
    _sendTokenToServer(result.accessToken.token);
    _showLoggedInUI();
    break;
  case LoginStatus.cancelledByUser:
    _showCancelledMessage();
    break;
  case LoginStatus.error:
    _showErrorOnUI();
    break;
}
```

## Installation

To get things up and running, you'll have to declare a pubspec dependency in your Flutter project.
Also some minimal Android & iOS specific configuration must be done, otherwise your app will crash.

### On your Flutter project

See the [installation instructions on pub](https://pub.dartlang.org/packages/flutter_account_kit#-installing-tab-).

#### Configuration
Find out your _Facebook App ID_ and _AccountKit Client Token_ from Facebook App's dashboard in the Facebook developer console.
<details>
    <summary>Android</summary>
    <br/>
1.  In **\<your project root\>/android/app/src/main/res/values/strings.xml**

```xml
  ...
  <string name="fb_app_id">YOUR_FACEBOOK_APP_ID</string>
  <string name="ak_client_token">YOUR_CLIENT_TOKEN</string>
```

2.  In **\<your project root\>/android/app/src/main/AndroidManifest.xml**

```xml
  ...
  <application>

      ...
      <meta-data
          android:name="com.facebook.sdk.ApplicationId"
          android:value="@string/fb_app_id" />
      <meta-data
          android:name="com.facebook.accountkit.ApplicationName"
          android:value="@string/app_name" />
      <meta-data
          android:name="com.facebook.accountkit.ClientToken"
          android:value="@string/ak_client_token" />
   </application>
   ...
```
This is the minimal required configuration. Take a look to the [Account Kit documentation for Android](https://developers.facebook.com/docs/accountkit/android) for a more detailed guide.

#### (Optional) Exclude backup for Access Tokens on Android >= 6.0

As per this [documentation](https://developers.facebook.com/docs/accountkit/accesstokens), Account Kit does not support automated backup (introduced in Android 6.0). The following steps will exclude automated backup

1.  Create a file **\<your project root\>/android/app/src/main/res/xml/backup_config.xml** that contains the following:

```java
  <?xml version="1.0" encoding="utf-8"?>
  <full-backup-content>
    <exclude domain="sharedpref" path="com.facebook.accountkit.AccessTokenManager.SharedPreferences.xml"/>
  </full-backup-content>
```

2.  In your `AndroidManifest.xml` add the following to exclude backup of Account Kit's Access Token.

```java
  <application
    //other configurations here
    android:fullBackupContent="@xml/backup_config" // add this line
   >
```
</details>

<details>
    <summary>iOS</summary>
    <br/>

Add your Facebook credentials to your project's `Info.plist` file

```xml
  <plist version="1.0">
    <dict>
      ...
      <key>FacebookAppID</key>
      <string>{your-app-id}</string>
      <key>AccountKitClientToken</key>
      <string>{your-account-kit-client-token}</string>
      <key>CFBundleURLTypes</key>
      <array>
        <dict>
          <key>CFBundleURLSchemes</key>
          <array>
            <string>ak{your-app-id}</string>
          </array>
        </dict>
      </array>
      ...
    </dict>
  </plist>
```

_This is the minimal required configuration. Take a look to the [Account Kit documentation for iOS](https://developers.facebook.com/docs/accountkit/ios) for a more detailed guide._

</details>
Done!


## Themes

<details>
    <summary>iOS</summary>
<br/>

```dart
import 'package:flutter/material.dart';
import 'package:flutter_account_kit/flutter_account_kit.dart';

final theme = AccountKitTheme(
    // Background
    backgroundColor: Color.fromARGB(0.1, 0, 120, 0,),
    backgroundImage: 'background.png',
    // Button
    buttonBackgroundColor: Color.fromARGB(1.0, 0, 153, 0),
    buttonBorderColor: Color.fromARGB(1, 0, 255, 0),
    buttonTextColor: Color.fromARGB(1, 0, 255, 0),
    // Button disabled
    buttonDisabledBackgroundColor: Color.fromARGB(0.5, 100, 153, 0),
    buttonDisabledBorderColor: Color.fromARGB(0.5, 100, 153, 0),
    buttonDisabledTextColor: Color.fromARGB(0.5, 100, 153, 0),
    // Header
    headerBackgroundColor: Color.fromARGB( 1.0, 0, 153, 0),
    headerButtonTextColor: Color.fromARGB(0.5, 0, 153, 0),
    headerTextColor: Color.fromARGB(1, 0, 255, 0),
    // Input
    inputBackgroundColor: Color.fromARGB(1, 0, 255, 0),
    inputBorderColor: Color.hex('#ccc'),
    inputTextColor: Color(0xFFb74093),
    // Others
    iconColor: Color(0xFFFFFFFF),
    textColor: Color(0xFFb74093),
    titleColor: Color(0xFFb74093),
    // Header
    statusBarStyle: StatusBarStyle.lightStyle, // or StatusBarStyle.defaultStyle
   );
AccountKit akt = new AccountKit();
Config cfg = Config()
             ..theme = theme;
akt.configure(cfg);
```

> To see the statusBarStyle reflected you must set the **UIViewControllerBasedStatusBarAppearance** property to **true** on your app's _Info.plist_ file.
> You can do it from XCode <img width="507" alt="screen shot 2016-08-02 at 11 44 07 am" src="https://cloud.githubusercontent.com/assets/1652196/17332979/0fa632b2-58a7-11e6-9aa3-a669ae44f2e6.png">

</details>

<details>
    <summary>Android</summary>

<br/>

> Check [this commit](https://github.com/underscopeio/react-native-facebook-account-kit/commit/77df35ae20f251e7c29285e8820da2ff498d9400) to see how it's done in our sample app

1.  In your application _styles.xml_ file (usually located in _\<your project root\>/android/app/src/main/res/values_ folder) create a **Theme** with the following schema

```xml
<style name="LoginThemeYellow" parent="Theme.AccountKit">
    <item name="com_accountkit_primary_color">#f4bf56</item>
    <item name="com_accountkit_primary_text_color">@android:color/white</item>
    <item name="com_accountkit_secondary_text_color">#44566b</item>
    <item name="com_accountkit_status_bar_color">#ed9d00</item>

    <item name="com_accountkit_input_accent_color">?attr/com_accountkit_primary_color</item>
    <item name="com_accountkit_input_border_color">?attr/com_accountkit_primary_color</item>
</style>
```

> See the full set of customizable fields [here](https://developers.facebook.com/docs/accountkit/android/customizing)

2.  In your app _AndroidManifest.xml_ file (usually under _\<your project root\>/android/app/src/main_ folder) set that **Theme** to the **AccountKitActivity**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools" <-- Add this line
    ...>

    <!-- Set the AccountKitActivity theme -->
    <activity
      tools:replace="android:theme"
      android:name="com.facebook.accountkit.ui.AccountKitActivity"
      android:theme="@style/LoginThemeYellow" />

</manifest>
```

</details>

## Troubleshooting

<details>
    <summary>"A system issue occured, Please try again" when sending SMS</summary>
<br/>

A. Check your `FacebookAppID` and `AccountKitClientToken` on iOS `Info.plist` and Android `strings.xml` are correct

B. If you have enabled the **client access token flow in fb account kit dashboard**, then `responseType` should be set to `code` when calling `configure`

```dart
// Configures the SDK with some options
import 'package:flutter_account_kit/flutter_account_kit.dart';

AccountKit akt = new AccountKit();
Config cfg = Config()
             ..responseType = ResponseType.code;
akt.configure(cfg);


```
</details>

## Inspiration
This project was inspired by 
[flutter_facebook_login](https://github.com/roughike/flutter_facebook_login) and
[react-native-facebook-account-kit](https://github.com/underscopeio/react-native-facebook-account-kit)