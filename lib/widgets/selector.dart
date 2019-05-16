import 'package:flutter/material.dart';
import '../classes/appmodel.dart';

class Selector extends StatefulWidget {
  @override
  SelectorState createState() => new SelectorState();
}

class SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Currency'),
      ),
      body: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    AppModel model = AppModel.of(context);
    List<Widget> _widgets = [];
    for (String code in model.codes()) {
      _widgets.add(_buildCheckbox(context, code));
      _widgets.add(Divider());
    }

    return ListView(
      children: _widgets,
    );
  }

  Widget _buildCheckbox(BuildContext context, String pairCode) {
    AppModel model = AppModel.of(context, rebuildOnChange: true);

    return Row(
      children: <Widget>[
        Checkbox(
          value: model.settings.containsKey(pairCode)
            ? model.settings[pairCode] : false,
          onChanged: (bool val) {
            model.saveSetting(pairCode, val);
          },
        ),
        Text(
          pairCode.substring(0, 3),
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.blueGrey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16.0,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          pairCode.substring(3, 6),
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
