import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'widgets/rates.dart';
import 'classes/appmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);
  var model = AppModel(analytics: analytics, observer: observer);
  model.readRates();
  model.loadSettings();
  runApp(MyApp(model: model));
}

class MyApp extends StatelessWidget {
  final AppModel model;

  const MyApp({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: model,
      child: MaterialApp(
          title: 'Money Exchange Rate',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
          ),
          navigatorObservers: [model.observer],
          home: Rate(),
          routes: <String, WidgetBuilder>{
            '/rate': (BuildContext context) => Rate(),
          }),
    );
  }
}
