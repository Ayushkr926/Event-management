import 'package:event_management/Auth/auth_gate.dart';
import 'package:event_management/provider/explore_provider.dart';
import 'package:event_management/services/auth_service.dart';
import 'package:event_management/services/event_service.dart';
import 'package:event_management/services/user_service.dart';
import 'package:event_management/upcoming_events/Date/date_provider.dart';
import 'package:event_management/upcoming_events/event_provider.dart';
import 'package:event_management/Home/home_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create UserService first (AuthService depends on it)
  final userService = UserService();

  runApp(
    ProviderScope(
      child: provider_pkg.MultiProvider(
        providers: [
          provider_pkg.ChangeNotifierProvider.value(value: userService),
          provider_pkg.ChangeNotifierProvider(
            create: (_) => AuthService(userService: userService),
          ),
          provider_pkg.ChangeNotifierProvider(create: (_) => EventService()),
          provider_pkg.ChangeNotifierProvider(create: (_) => HomeProvider()),
          provider_pkg.ChangeNotifierProvider(create: (_) => DateProvider()),
          provider_pkg.ChangeNotifierProvider(create: (_) => EventProvider()),
          provider_pkg.ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const AuthGate(),
    );
  }
}