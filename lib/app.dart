import 'package:penniverse/exports.dart';

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
