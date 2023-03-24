import 'dart:convert';
import 'dart:io';

import 'package:testing_rx_dart/animal.dart';
import 'package:testing_rx_dart/person.dart';
import 'package:testing_rx_dart/thing.dart';

typedef SearchTerm = String;

class Api {
  List<Animal>? _animals;
  List<Person>? _persons;

  Api();
  Future<List<Thing>> search(SearchTerm searchTerm) async {
    final term = searchTerm.trim().toLowerCase();
    final cachedResults = _extractThingUsingSearchTerm(term);
    if (cachedResults != null) {
      return cachedResults;
    }
    final persons =  await _getData("https://cde26b5a-728d-4f32-8c7c-534d77a15b77.mock.pstmn.io/person")
        .then((json) {
          return json.map((value) => Person.fromJson(value));
        });
    _persons = persons.toList();
    final animals = await _getData("https://cde26b5a-728d-4f32-8c7c-534d77a15b77.mock.pstmn.io/animal")
        .then((json) => json.map((value) => Animal.fromJson(value)));
    _animals = animals.toList();

    return _extractThingUsingSearchTerm(term) ?? [];
  }

  List<Thing>? _extractThingUsingSearchTerm(SearchTerm searchTerm) {
    final cachedAnimals = _animals;
    final cachedPersons = _persons;
    List<Thing> result = [];
    if (cachedAnimals != null || cachedPersons != null) {
      for (final animal in cachedAnimals!) {
        if (animal.name.trimmedContains(searchTerm) ||
            animal.type.trimmedContains(searchTerm)) {
          result.add(animal);
        }
      }
      for (final person in cachedPersons!) {
        if (person.name.trimmedContains(searchTerm) ||
            person.age.toString().trimmedContains(searchTerm)) {
          result.add(person);
        }
      }
      return result;
    } else {
      return null;
    }
  }

  Future<List<dynamic>> _getData(String url) => HttpClient()
      .getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then((response) => response.transform(utf8.decoder).join())
      .then((jsonString) => json.decode(jsonString) as List<dynamic>);
}

extension TrimmedCaseInsentitive on String {
  bool trimmedContains(String other) =>
      trim().toLowerCase().contains(other.trim().toLowerCase());
}
