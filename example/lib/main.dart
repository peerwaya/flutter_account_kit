import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_account_kit/flutter_account_kit.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterAccountKit akt = FlutterAccountKit();
  int _state = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initAccountkit();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAccountkit() async {
    print('Init account kit called');
    bool initialized = false;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final theme = AccountKitTheme(
          headerBackgroundColor: Colors.green,
          buttonBackgroundColor: Colors.yellow,
          buttonBorderColor: Colors.yellow,
          buttonTextColor: Colors.black87);
      await akt.configure(Config()
        ..facebookNotificationsEnabled = true
        ..receiveSMS = true
        ..readPhoneStateEnabled = true
        ..theme = theme
        );
      initialized = true;
    } on PlatformException {
      print('Failed to initialize account kit');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _isInitialized = initialized;
      print("isInitialied $_isInitialized");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: RaisedButton(
            padding: EdgeInsets.all(0.0),
            color: _state == 2 ? Colors.green : Colors.blue,
            child: buildButtonChild(),
            onPressed: _isInitialized ? this.login : null,
          ),
        ),
      ),
    );
  }

  Widget buildButtonChild() {
    if (_state == 0) {
      return Text(
        'Login',
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      );
    } else if (_state == 1) {
      return SizedBox(
          height: 24.0,
          width: 24.0,
          child: CircularProgressIndicator(
            value: null,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ));
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  Future<void> login() async {
    if (_state == 1) {
      return;
    }
    setState(() {
      _state = 1;
    });
    final result = await akt.logInWithPhone();
    if (result.status == LoginStatus.cancelledByUser) {
      print('Login cancelled by user');
      setState(() {
        _state = 0;
      });
    } else if (result.status == LoginStatus.error) {
      print('Login error');
      setState(() {
        _state = 0;
      });
    } else {
      print('Login success');
      setState(() {
        _state = 2;
      });
    }
  }
}
