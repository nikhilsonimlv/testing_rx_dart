import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

enum TypeOfThing { animal, person }

@immutable
class Thing {
  final TypeOfThing type;
  final String name;

  const Thing({required this.type, required this.name});
}

@immutable
class Bloc {
  final Sink<TypeOfThing?> setTypeOfThing; //write-only
  final Stream<TypeOfThing?> currentTypeOfThing; // read-only
  final Stream<Iterable<Thing>> things; //read-only

  //We created this as PRIVATE CONSTRUCTOR because this is not job of the bloc consumer to provide all above three values ,
  // factory constructor should pass these values to this const private constructor
  const Bloc._({
    required this.setTypeOfThing,
    required this.currentTypeOfThing,
    required this.things,
  });

  void dispose() {
    setTypeOfThing.close();
  }

  factory Bloc({
    required Iterable<Thing> things,
  }) {
    final typeOfThingSubject = BehaviorSubject<TypeOfThing?>();

    final filteredThings = typeOfThingSubject.debounceTime(const Duration(milliseconds: 300)).map<Iterable<Thing>>((typeOfThing) {
      if (typeOfThing != null) {
        return things.where((thing) => thing.type == typeOfThing);
      } else {
        return things;
      }
    }).startWith(things);

    return Bloc._(
      setTypeOfThing: typeOfThingSubject.sink,
      currentTypeOfThing: typeOfThingSubject.stream,
      things: filteredThings,
    );
  }
}

const things = [
  Thing(type: TypeOfThing.animal, name: "Dog"),
  Thing(type: TypeOfThing.animal, name: "Lion"),
  Thing(type: TypeOfThing.animal, name: "Tiger"),
  Thing(type: TypeOfThing.person, name: "Nikhil"),
  Thing(type: TypeOfThing.person, name: "Ram"),
  Thing(type: TypeOfThing.person, name: "Shyam"),
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Bloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = Bloc(things: things);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Chips"),
      ),
      body: Column(
        children: [
          StreamBuilder<TypeOfThing?>(
            builder: (context, snapshot) {
              final selectedTypeOfThing = snapshot.data;
              return Wrap(
                children: TypeOfThing.values
                    .map(
                      (typeOfThing) => FilterChip(
                        selectedColor: Colors.blueAccent,
                        onSelected: (selected) {
                          final type = selected ? typeOfThing : null;
                          bloc.setTypeOfThing.add(type);
                        },
                        label: Text(typeOfThing.name),
                        selected: selectedTypeOfThing == typeOfThing,
                      ),
                    )
                    .toList(),
              );
            },
            stream: bloc.currentTypeOfThing,
          ),
          Expanded(
            child: StreamBuilder(
                builder: (context, snapshot) {
                  final things = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: things.length,
                    itemBuilder: (context, index) {
                      final thing = things.elementAt(index);
                      return ListTile(
                        title: Text(thing.name),
                        subtitle: Text(thing.type.name),
                      );
                    },
                  );
                },
                stream: bloc.things),
          ),
        ],
      ),
    );
  }
}
