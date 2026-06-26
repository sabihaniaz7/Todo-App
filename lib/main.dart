import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase/firebase_options.dart';
import 'package:flutter_firebase/providers/notification_provider.dart';
import 'package:flutter_firebase/providers/task_filter_provider.dart';
import 'package:flutter_firebase/providers/theme_provider.dart';
import 'package:flutter_firebase/screens/auth_screen.dart';
import 'package:flutter_firebase/screens/home_screen.dart';
import 'package:flutter_firebase/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase Connection
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // locks the app in potrait mode always
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Allows Google Fonts to load from bundled assets when offline
  GoogleFonts.config.allowRuntimeFetching = true; // fetch when online
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskFilterProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            // StreamBuilder handles session token reading on disk boot entirely by itself
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return TaskScreen(userId: snapshot.data!.uid);
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
