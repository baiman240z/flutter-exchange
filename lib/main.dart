import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'widgets/rates.dart';
import 'classes/appmodel.dart';

void main() async {
  var model = AppModel();
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
          home: Rate(),
          routes: <String, WidgetBuilder>{
            '/rate': (BuildContext context) => Rate(),
          }),
    );
  }
}
