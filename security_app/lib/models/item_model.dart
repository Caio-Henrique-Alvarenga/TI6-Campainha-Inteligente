import 'package:flutter/foundation.dart';

class Item {
  final String uid;
  final String description;
  final bool safe;

  Item({
    required this.uid,
    required this.description,
    required this.safe,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      uid: json['uid'] as String,
      description: json['description'] as String,
      safe: json['safe'] as bool,
    );
  }
}