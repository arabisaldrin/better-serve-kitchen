import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

String publicPath(String? path) {
  return "https://zshwkohgxpaaonnogbem.supabase.co/storage/v1/object/public${path ?? ''}";
}

const List<Color> orderStatusColor = [
  Colors.grey, // onhold
  Colors.orange, // pending
  Colors.blue, // processing
  Colors.green, //  done
];

extension DarkMode on BuildContext {
  /// is dark mode currently enabled?
  bool get isDarkMode {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark;
  }
}
