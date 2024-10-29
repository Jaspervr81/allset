

import 'package:shared_preferences/shared_preferences.dart';

class Settings {

  Future<bool> setNightMode(bool nightMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nightMode = !nightMode;
    prefs.setBool('nightMode', nightMode);
    return nightMode;
  }

  Future<bool> checkNightMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('nightMode') ?? false;
  }
}