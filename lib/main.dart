import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer' as devtools show log;

extension Log on Object{
  void log()=>devtools.log(toString());
}

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

void testIt() async{

  final stream1 =Stream.periodic(const Duration(seconds: 1),(computationCount) => "Stream 1, count = $computationCount",);
  final stream2 =Stream.periodic(const Duration(seconds: 5),(computationCount) => "Stream 2, count = $computationCount",);

  final result =Rx.zip2(stream1, stream2, (a, b) => 'Zip result a = $a ,b = $b');

  await for(final value in result){
    value.log();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    testIt();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
    );
  }
}
