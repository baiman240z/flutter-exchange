import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppModel extends Model {
  static const _url = 'https://www.gaitameonline.com/rateaj/getrate';
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  bool _loaded = false;
  Map<String, Map<String, double>> _rates = {};
  Map<String, bool> _settings = {};
  bool _notification = false;
  final FirebaseMessaging _fm = FirebaseMessaging();

  AppModel({this.analytics, this.observer});

  static AppModel of(BuildContext context, {
    bool rebuildOnChange = false,
  }) => ScopedModel.of<AppModel>(context, rebuildOnChange: rebuildOnChange);

  Map<String, bool> get settings => _settings;
  bool get notification => _notification;
  bool get loaded => _loaded;

  void readRates() async {
    _loaded = false;
    notifyListeners();

    http.Response response = await http.get(_url);
    JsonDecoder decoder = JsonDecoder();
    try {
      var decoded = decoder.convert(response.body);
      var _list = {};
      List<String> keys = [];
      for (var rate in decoded['quotes']) {
        _list[rate['currencyPairCode']] = {
          'high': double.parse(rate['high']),
          'open': double.parse(rate['open']),
          'bid': double.parse(rate['bid']),
          'ask': double.parse(rate['ask']),
          'low': double.parse(rate['low']),
        };
        keys.add(rate['currencyPairCode']);
      }
      keys.sort();

      for (String key in keys) {
        _rates[key] = _list[key];
      }

      _loaded = true;

      notifyListeners();
    } on FormatException catch (e) {
      print(json);
      throw e;
    }
  }

  void loadSettings() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String json = sp.getString('setting');
    if (json != null) {
      JsonDecoder decoder = JsonDecoder();
      Map<String, dynamic> _decoded = decoder.convert(json);
      _decoded.forEach((key, val) {
        _settings[key] = val as bool;
      });
    }

    _notification = sp.getBool('notification');
    if (_notification == null) { _notification = false; }

    notifyListeners();
  }

  void saveSetting(String pairCode, bool checked) async {
    _settings[pairCode] = checked;
    JsonEncoder encoder = JsonEncoder();
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('setting', encoder.convert(_settings));
    notifyListeners();
  }

  void saveNotification(bool flag) async {
    _notification = flag;
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('notification', _notification);
    const String DEFAULT_PAIR = 'USDJPY';
    if (_notification) {
      _fm.subscribeToTopic(DEFAULT_PAIR);
      print('@@@@@@@@@@@@@ subscribeToTopic');
    } else {
      _fm.unsubscribeFromTopic(DEFAULT_PAIR);
      print('@@@@@@@@@@@@@ unsubscribeFromTopic');
    }
    notifyListeners();
  }

  Iterable<String> codes() {
    return _rates.keys;
  }

  Map<String, Map<String, double>> enableRates() {
    Map<String, Map<String, double>> _results = {};
    _rates.forEach((String key, Map<String, double> rate) {
      if (_settings.containsKey(key) && _settings[key]) {
        _results[key] = rate;
      }
    });
    return _results;
  }

  Future<void> logFb(String name, Map<String, dynamic> parameters) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
