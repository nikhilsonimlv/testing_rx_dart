import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:testing_rx_dart/thing.dart';


@immutable
class Person extends Thing{
  final int age;

  const Person({required this.age, required String name}) : super(name: name);

  @override
  String toString() {
    return 'Person{age: $age, name:$name}';
  }
  Person.fromJson(Map<String, dynamic> json):age=json["age"] as int,super(name:json['name']);

}
