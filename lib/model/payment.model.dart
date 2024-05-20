import 'dart:io';
import 'package:my_expense_app/model/account.model.dart';
import 'package:my_expense_app/model/category.model.dart';
import 'package:intl/intl.dart';

enum PaymentType {
  debit,
  credit
}

class Payment {
  int? id;
  Account account;
  Category category;
  double amount;
  PaymentType type;
  DateTime datetime;
  String title;
  String description;
  File? receipt; // New field for the image receipt

  Payment({
    this.id,
    required this.account,
    required this.category,
    required this.amount,
    required this.type,
    required this.datetime,
    required this.title,
    required this.description,
    this.receipt, // Optional image receipt
  });

  factory Payment.fromJson(Map<String, dynamic> data) {
    return Payment(
      id: data['id'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      account: Account.fromJson(data['account']),
      category: Category.fromJson(data['category']),
      amount: data['amount'],
      type: data['type'] == 'CR' ? PaymentType.credit : PaymentType.debit,
      datetime: DateTime.parse(data['datetime']),
      // Deserialize the receipt file if present
      receipt: data['receipt'] != null ? File(data['receipt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'account': account.id,
    'category': category.id,
    'amount': amount,
    'datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
    'type': type == PaymentType.credit ? 'CR' : 'DR',
    // Include the receipt file path if it exists
    if (receipt != null) 'receipt': receipt!.path,
  };
}
