import 'package:penniverse/exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getDBInstance();
  AppProvider appProvider = await AppProvider.getInstance();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_)=>appProvider)
          ],
          child: const MyApp()
      )
  );
}


