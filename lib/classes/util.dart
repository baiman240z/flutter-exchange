import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Util {
  static final FirebaseMessaging _fcm = FirebaseMessaging();

  static void build(BuildContext context) {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("@@@@@@@@@@@@@@@@@@@@@ onMessage] $message");
        buildDialog(context, message['notification']['title'], message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("@@@@@@@@@@@@@@@@@@@@@ onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("@@@@@@@@@@@@@@@@@@@@@ onResume: $message");
        Navigator.pushReplacementNamed(context, message['data']['url']);
      },
    );
    _fcm.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
      print("@@@@@@@@@@@@@@@@@ Settings registered: $settings");
    });
  }

  static void buildDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

}
