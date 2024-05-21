import 'package:flutter/material.dart';

class Category {
  int? id;
  String name;
  IconData icon;
  Color color;
  double? budget;
  double? expense;
  String? type;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budget,
    this.expense,
    this.type,
  });

  factory Category.fromJson(Map<String, dynamic> data) => Category(
    id: data["id"],
    name: data["name"],
    icon: IconData(data["icon"], fontFamily: 'MaterialIcons'),
    color: Color(data["color"]),
    budget: data["budget"] ?? 0,
    expense: data["expense"] ?? 0,
    type: data["type"], // Include type
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon": icon.codePoint,
    "color": color.value,
    "budget": budget,
    "type": type, // Include type
  };

}