import 'package:flutter/material.dart';

/// This class is used to customize the account kit theme.
///
class AccountKitTheme {
  static Map<String, double> colorToMap(Color color) {
    if (color == null) {
      return null;
    }
    return <String, double>{
      'r': color.red / 0xFF,
      'g': color.green / 0xFF,
      'b': color.blue / 0xFF,
      'a': color.alpha / 0xFF
    };
  }

  /// returns the native statusBarStyle
  dynamic _toNativeStatusBarStyle() {
    if (statusBarStyle == null) {
      return null;
    }
    switch (statusBarStyle) {
      case StatusBarStyle.defaultStyle:
        return 0;
      case StatusBarStyle.lightStyle:
        return 1;
    }

    throw new StateError('Invalid response type.');
  }

  AccountKitTheme(
      {this.backgroundColor,
      this.backgroundImage,
      this.headerBackgroundColor,
      this.headerTextColor,
      this.headerButtonTextColor,
      this.buttonBackgroundColor,
      this.buttonBorderColor,
      this.buttonTextColor,
      this.buttonDisabledBackgroundColor,
      this.buttonDisabledBorderColor,
      this.buttonDisabledTextColor,
      this.iconColor,
      this.inputBackgroundColor,
      this.inputBorderColor,
      this.inputTextColor,
      this.textColor,
      this.statusBarStyle,
      this.titleColor});

  /// The name of the background image resource file
  String backgroundImage;

  /// The style to use for the status bar
  StatusBarStyle statusBarStyle;

  /// Color for the background of the UI if an image is not used
  Color backgroundColor;

  /// Color for the header background
  Color headerBackgroundColor;

  /// Color for the header text
  Color headerTextColor;

  /// Color for the header button text
  Color headerButtonTextColor;

  /// Color for the background of the buttons
  Color buttonBackgroundColor;

  /// Color for the borders of buttons
  Color buttonBorderColor;

  /// Color for the buttonText
  Color buttonTextColor;

  /// Color for the disabled background color
  Color buttonDisabledBackgroundColor;

  /// Color for the borders of the disabled buttons
  Color buttonDisabledBorderColor;

  /// Color for the disabled text on buttons
  Color buttonDisabledTextColor;

  /// Color for icons
  Color iconColor;

  /// Color for the background of the input boxes.
  Color inputBackgroundColor;

  /// Color of the input boxes' border
  Color inputBorderColor;

  /// Text color of the input text for Phone Number and Confirmation Code
  Color inputTextColor;

  /// Color for text
  Color textColor;

  /// Color for title
  Color titleColor;

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this account as JSON and then
  /// storing it locally
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'backgroundColor': colorToMap(backgroundColor),
      'backgroundImage': backgroundImage,
      'headerBackgroundColor': colorToMap(headerBackgroundColor),
      'headerTextColor': colorToMap(headerTextColor),
      'headerButtonTextColor': colorToMap(headerButtonTextColor),
      'buttonBackgroundColor': colorToMap(buttonBackgroundColor),
      'buttonTextColor': colorToMap(buttonTextColor),
      'buttonBorderColor': colorToMap(buttonBorderColor),
      'buttonDisabledBackgroundColor':
          colorToMap(buttonDisabledBackgroundColor),
      'buttonDisabledBorderColor': colorToMap(buttonDisabledBorderColor),
      'buttonDisabledTextColor': colorToMap(buttonDisabledTextColor),
      'iconColor': colorToMap(iconColor),
      'inputBackgroundColor': colorToMap(inputBackgroundColor),
      'inputBorderColor': colorToMap(inputBorderColor),
      'inputTextColor': colorToMap(inputTextColor),
      'textColor': colorToMap(textColor),
      'titleColor': colorToMap(titleColor),
      'statusBarStyle': _toNativeStatusBarStyle(),
    };

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

/// The style to use for the status bar
enum StatusBarStyle {
  /// Dark status bar
  defaultStyle,

  /// Light status bar
  lightStyle
}
