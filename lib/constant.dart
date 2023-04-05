import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

String publicPath(String path, [String bucket = "images"]) {
  return supabase.storage.from(bucket).getPublicUrl(path).data!;
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
