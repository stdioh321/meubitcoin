import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:meubitcoin/views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  MaterialApp materialApp = MaterialApp(
    title: 'MeuBitcoin',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: Home(),
  );
  @override
  Widget build(BuildContext context) {
    return materialApp;
  }
}
