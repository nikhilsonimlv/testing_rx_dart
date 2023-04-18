import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Stream<String> getContent({required String filePath}) {
  final stream = rootBundle.loadString(filePath);
  return Stream.fromFuture(stream).transform(const LineSplitter());
}

Stream<String> getData() {
  final file1 = getContent(filePath: "assets/text/cats.txt");
  final file2 = getContent(filePath: "assets/text/dogs.txt");
  return file1.concatWith([file2]).delay(Duration(seconds: 2));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              final name = snapshot.requireData;

              return ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(name[index].toString()),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(color: Colors.green),
                  itemCount: name.length);
          }
        },
        future: getData().toList(),
      ),
    );
  }
}
