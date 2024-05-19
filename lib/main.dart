import 'package:my_expense_app/app.dart';
import 'package:my_expense_app/helpers/db.helper.dart';
import 'package:my_expense_app/providers/app_provider.dart';
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


