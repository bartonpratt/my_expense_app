import 'package:penniverse/app.dart';
import 'package:penniverse/helpers/db.helper.dart';
import 'package:penniverse/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getDBInstance();

  AppProvider appProvider = await AppProvider.getInstance();

  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_)=>appProvider)
          ],
          child: MyApp()
      )
  );
}


