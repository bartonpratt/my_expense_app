import 'package:penniverse/screens/main.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:penniverse/theme/colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Expense App',
      darkTheme: ThemeColors.darkTheme(),
      theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
         primaryColor: Colors.blue
        
      ),
      home: const MainScreen(),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        // MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}
