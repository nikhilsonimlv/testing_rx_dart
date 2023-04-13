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

//Bloc class
@immutable
class Bloc {
  final Sink<String?> setFirstName; //write only
  final Sink<String?> setLastName; //write only
  final Stream<String> fullName; //read only

  const Bloc._({
    required this.setFirstName,
    required this.setLastName,
    required this.fullName,
  });

  void dispose() {
    setFirstName.close();
    setLastName.close();
  }

  factory Bloc() {
    final firstName = BehaviorSubject<String?>();
    final lastName = BehaviorSubject<String?>();

    final Stream<String> fullName = Rx.combineLatest2(firstName.startWith(null), lastName.startWith(null), (
      String? firstName,
      String? lastName,
    ) {
      if (firstName != null && lastName != null && firstName.isNotEmpty && lastName.isNotEmpty) {
        return "$firstName $lastName";
      } else {
        return " first name and last name must be provided";
      }
    });

    return Bloc._(
      setFirstName: firstName.sink,
      setLastName: lastName.sink,
      fullName: fullName,
    );
  }
}

typedef AsyncSnapShotBuilderCallBack<T> = Widget Function(BuildContext context, T? value);

class AsyncSnapShotBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncSnapShotBuilderCallBack<T>? onNone;
  final AsyncSnapShotBuilderCallBack<T>? onWaiting;
  final AsyncSnapShotBuilderCallBack<T>? onActive;
  final AsyncSnapShotBuilderCallBack<T>? onDone;

  const AsyncSnapShotBuilder({
    Key? key,
    required this.stream,
    this.onNone,
    this.onWaiting,
    this.onActive,
    this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            final callback = onNone ?? (_, __) => const SizedBox();
            return callback(context, snapshot.data);
          case ConnectionState.waiting:
            final callback = onWaiting ?? (_, __) => const CircularProgressIndicator();
            return callback(context, snapshot.data);
          case ConnectionState.active:
            final callback = onActive ?? (_, __) => const SizedBox();
            return callback(context, snapshot.data);
          case ConnectionState.done:
            final callback = onDone ?? (_, __) => const SizedBox();
            return callback(context, snapshot.data);
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Bloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = Bloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Combine Latest with rx Dart"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "First Name"),
              onChanged: (value) {
                _bloc.setFirstName.add(value);
              },
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Last Name"),
              onChanged: (value) {
                _bloc.setLastName.add(value);
              },
            ),
            AsyncSnapShotBuilder<String>(
              stream: _bloc.fullName,
              onActive: ((context, String? value) => Text(value ?? "")),
            ),
          ],
        ),
      ),
    );
  }
}
