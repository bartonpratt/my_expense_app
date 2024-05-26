import 'package:flutter/services.dart';
import 'package:penniverse/screens/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:penniverse/theme/colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: MediaQuery.of(context).platformBrightness
  ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Expense App',
      darkTheme: ThemeColors.darkTheme(),
      theme: ThemeColors.lightTheme(),
      home: const MainScreen(),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        // MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
