import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:penniverse/helpers/migrations/migrations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Database? database;

Future<Database> getDBInstance() async {
  if (database == null) {
    Database db;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      db = await databaseFactory.openDatabase("myexpense.db", options: OpenDatabaseOptions(
        version: 1,
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      ));
    } else {
      String databasesPath = await getDatabasesPath();
      String dbPath = join(databasesPath, 'myexpense.db');
      db = await openDatabase(dbPath, version: 1, onCreate: onCreate, onUpgrade: onUpgrade);
    }

    database = db;
    return db;
  } else {
    Database db = database!;
    return db;
  }
}

typedef MigrationCallback = Function(Database database);
List<MigrationCallback> migrations = [
  v1
];

void onCreate(Database database, int version) async {
  for (MigrationCallback callback in migrations) {
    await callback(database);
  }
}

void onUpgrade(Database database, int oldVersion, int version) async {
  for (int index = oldVersion; index < version; index++) {
    MigrationCallback callback = migrations[index];
    await callback(database);
  }
}

Future<void> resetDatabase() async {
  try {
    final db = await getDBInstance();

    await db.delete("payments", where: "id > 0");
    await db.delete("accounts", where: "id > 0");
    await db.delete("categories", where: "id > 0");

    await db.insert("accounts", {
      "name": "Cash",
      "icon": Icons.wallet.codePoint,
      "color": Colors.blue.value,
      "isDefault": 1
    });

    // Pre-fill all categories
    List<Map<String, dynamic>> categories = [
      {"name": "Housing", "icon": Icons.house.codePoint, "type": "DR"}, // Expense category with budget
      {"name": "Salary", "icon": Icons.attach_money.codePoint, "type": "CR"},
      {"name": "Allowance", "icon": Icons.money_rounded.codePoint,"type": "CR"},
      {"name": "Bonus", "icon": Icons.monetization_on_rounded.codePoint,"type": "CR"},
      {"name": "Transportation", "icon": Icons.emoji_transportation.codePoint

        , "type": "DR"},
      {"name": "Food", "icon": Icons.restaurant.codePoint, "type": "DR"},
      {"name": "Utilities", "icon": Icons.category.codePoint, "type": "DR"},
      {"name": "Insurance", "icon": Icons.health_and_safety.codePoint, "type": "DR"},
      {"name": "Petty Cash", "icon": Icons.money_rounded.codePoint,"type": "CR"},
      {"name": "Medical & Healthcare", "icon": Icons.medical_information.codePoint, "type": "DR"},
      {"name": "Education", "icon": Icons.school.codePoint, "type": "DR"},
      {"name": "Savings & Investing", "icon": Icons.attach_money.codePoint, "type": "DR"},
      {"name": "Personal Spending", "icon": Icons.shopping_bag.codePoint, "type": "DR"},
      {"name": "Recreation & Entertainment", "icon": Icons.tv.codePoint, "type": "DR"},
      {"name": "Miscellaneous", "icon": Icons.library_books_sharp.codePoint, "type": "DR"},
    ];

    for (Map<String, dynamic> category in categories) {
      await db.insert("categories", {
        "name": category["name"],
        "icon": category["icon"],
        "color": Colors.primaries[categories.indexOf(category) % Colors.primaries.length].value,
        "type": category["type"],
        "budget": category["budget"] ?? 0.0,  // Default budget to 0.0 if not specified
      });
    }
  } catch (e) {
    print("Error resetting database: $e");
    // Optionally, rethrow or handle the error further
  }
}

