import 'package:better_serve_kitchen/order_service.dart';
import 'package:better_serve_kitchen/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'orders_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  String? supbaseAnonKey = dotenv.env['SUPABASE_ANON'];

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supbaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => OrderService(),
          ),
          ChangeNotifierProvider(
            create: (context) => SettingsService(),
          )
        ],
        builder: (context, _) {
          return FutureBuilder(
              future: Provider.of<SettingsService>(context, listen: false).load,
              builder: (context, snapshot) {
                return Consumer<SettingsService>(
                    builder: (context, settings, _) {
                  return MaterialApp(
                    theme: ThemeData(
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: settings.primaryColor),
                        ),
                      ),
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: settings.primaryColor,
                      ),
                    ),
                    darkTheme: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: settings.primaryColor,
                        brightness: Brightness.dark,
                      ),
                    ),
                    themeMode: settings.theme,
                    home: const HomePage(),
                  );
                });
              });
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: OrdersPage(),
      ),
    );
  }
}
