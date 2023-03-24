import 'package:flutter/foundation.dart';
import 'package:testing_rx_dart/thing.dart';

enum AnimalType { rabbit, dog, cat, unknown }

@immutable
class Animal extends Thing {
  final String type;

  const Animal({required this.type, required String name}) : super(name: name);

  @override
  String toString() {
    return 'Animal{type: $type, name:$name}';
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    final AnimalType animalType;

    switch ((json['type'] as String).toLowerCase().trim()) {
      case "rabbit":
        {
          animalType = AnimalType.rabbit;
        }
        break;
      case "dog":
        {
          animalType = AnimalType.dog;
        }
        break;
      case "cat":
        {
          animalType = AnimalType.cat;
        }
        break;
      default:
        {
          animalType = AnimalType.unknown;
        }
    }
    return Animal(type: animalType.toString(), name: json["name"]);
  }
}
