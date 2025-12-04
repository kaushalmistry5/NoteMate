import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/db/database_helper.dart';
import 'package:notes/providers/note_provider.dart';
import 'package:notes/providers/settings_provider.dart';
import 'package:notes/providers/theme_provider.dart';
import 'package:notes/repository/note_repository.dart';
import 'package:notes/screens/splash_screen.dart';
import 'package:notes/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await DatabaseHelper.instance.database;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
         ChangeNotifierProvider(create: (_) => ThemeProvider()),
         ChangeNotifierProvider(create: (_) => SettingsProvider()),
         ChangeNotifierProvider(create: (_) => NoteProvider(repository: NoteRepository()))
        ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _){
          return MaterialApp(
            title: 'NoteMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}