import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constant.dart';
import 'pallete.dart';

class SettingsService with ChangeNotifier {
  static final Map<String, dynamic> _settings = HashMap();

  Future get load async {
    PostgrestResponse res = await supabase.from("settings").select().execute();

    if (res.error != null && res.status != 406) {
      return false;
    }

    for (dynamic item in res.data as List<dynamic>) {
      _settings.putIfAbsent(item["name"], () => item["value"]["value"]);
    }

    return true;
  }

  Color get primaryColor => _settings.containsKey("primary_color")
      ? Pallete.hexToColor(_settings["primary_color"])
      : Colors.transparent;

  String get companyName => _settings.containsKey("company_name")
      ? _settings["company_name"]
      : "Better Serve";

  get logo => _settings.containsKey("logo")
      ? NetworkImage(
          _settings["logo"],
        )
      : const AssetImage("assets/icons/better_serve_logo.png");

  ThemeMode get theme {
    if (_settings.containsKey("app_theme")) {
      switch (_settings["app_theme"]) {
        case "dark":
          return ThemeMode.dark;
        case "light":
          return ThemeMode.light;
        case "system":
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }

  void toggleDarkMode(BuildContext context) {
    if (!context.isDarkMode) {
      _settings["app_theme"] = "dark";
    } else {
      _settings["app_theme"] = "light";
    }
    notifyListeners();
  }
}
