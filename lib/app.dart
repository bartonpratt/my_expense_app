import 'package:dynamic_color/dynamic_color.dart';
import 'package:my_expense_app/screens/main.screen.dart';
import 'package:my_expense_app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  ThemeData _buildTheme({required Brightness brightness, Color? color}){
    String fontFamily = "Bobbers";
    ThemeData baseTheme = ThemeData(
      brightness: brightness,
      colorSchemeSeed: color ?? ThemeColors.primary,
      useMaterial3: true,
    );
    return baseTheme.copyWith(
       textTheme:  TextTheme(
         displayLarge: baseTheme.textTheme.displayLarge!.merge( TextStyle(fontFamily: fontFamily)),
         displayMedium: baseTheme.textTheme.displayMedium!.merge( TextStyle(fontFamily: fontFamily)),
         displaySmall: baseTheme.textTheme.displaySmall!.merge( TextStyle(fontFamily: fontFamily)),
         headlineLarge: baseTheme.textTheme.headlineLarge!.merge( TextStyle(fontFamily: fontFamily)),
         headlineMedium: baseTheme.textTheme.headlineMedium!.merge( TextStyle(fontFamily: fontFamily)),
         headlineSmall: baseTheme.textTheme.headlineSmall!.merge( TextStyle(fontFamily: fontFamily)),
         titleLarge: baseTheme.textTheme.titleLarge!.merge( TextStyle(fontFamily: fontFamily)),
         titleMedium: baseTheme.textTheme.titleMedium!.merge( TextStyle(fontFamily: fontFamily)),
         titleSmall: baseTheme.textTheme.titleSmall!.merge( TextStyle(fontFamily: fontFamily)),
         bodyLarge: baseTheme.textTheme.bodyLarge!.merge( TextStyle(fontFamily: fontFamily)),
         bodyMedium: baseTheme.textTheme.bodyMedium!.merge( TextStyle(fontFamily: fontFamily)),
         bodySmall: baseTheme.textTheme.bodySmall!.merge( TextStyle(fontFamily: fontFamily)),
         labelLarge: baseTheme.textTheme.labelLarge!.merge( TextStyle(fontFamily: fontFamily)),
         labelMedium: baseTheme.textTheme.labelMedium!.merge( TextStyle(fontFamily: fontFamily)),
         labelSmall: baseTheme.textTheme.labelSmall!.merge( TextStyle(fontFamily: fontFamily)),
       ),
    );
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode?  Brightness.light: Brightness.dark
    ));


          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Expense App',
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainScreen(),
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              // MonthYearPickerLocalizations.delegate,
            ],
          );

  }
}