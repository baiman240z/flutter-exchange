import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import '../classes/appmodel.dart';
import '../classes/util.dart';
import 'selector.dart';

class Rate extends StatefulWidget {
  @override
  RateState createState() => new RateState();
}

class RateState extends State<Rate> {

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink?.link;
        if (deepLink != null) {
          print(deepLink);
          Util.buildDialog(context, 'DeepLink', deepLink.toString());
        }
      },
      onError: (OnLinkErrorException e) async {
        print('@@@@@@@@@@@@@ onLinkError @@@@@@@@@@@@@@@@@@');
        print(e.message);
      }
    );

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('@@@@@@@@@@@@@ getInitialLink @@@@@@@@@@@@@@@@@@');
      print(deepLink);
    }
  }

  @override
  Widget build(BuildContext context) {
    Util.build(context);
    AppModel model = AppModel.of(context, rebuildOnChange: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rate'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () {
              model.readRates();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String val) {
              if (val == 'select') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Selector(),
                  ),
                );
              } else if (val == 'notification') {
                model.saveNotification(!model.notification);
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: 'select',
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Select'),
                  ),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'notification',
                  checked: model.notification,
                  child: Text('Notification'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    AppModel model = AppModel.of(context, rebuildOnChange: true);

    if (!model.loaded) {
      return _buildLoading(context);
    }

    List<Widget> _widgets = List<Widget>();
    model.enableRates().forEach((key, rate) {
      _widgets.add(_buildRate(
          context, key.substring(0, 3), key.substring(3, 6), rate['bid'], rate['ask']
      ));
      _widgets.add(Divider(
        color: Colors.green,
        height: 20.0,
      ));
    });

    model.logFb('rate', {
      'count': model.enableRates().length
    });

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'EUR',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.blueGrey.withOpacity(0.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.0,
                  color: Colors.blueGrey.withOpacity(0.0),
                ),
              ),
              Text(
                'JPY',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.blueGrey.withOpacity(0.0),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('bid')
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('ask')
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ListView(
              children: _widgets,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20.0),
            child: const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildRate(BuildContext context, String from, String to, double bid, double ask) {
    return Row(
      children: <Widget>[
        Text(
          from,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.blueGrey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 14.0,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          to,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.blueGrey,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              bid.toString(),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              ask.toString(),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
