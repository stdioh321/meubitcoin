import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:meubitcoin/controllers/tmp_controller.dart';
import 'package:meubitcoin/repositories/fcm_firebase_repository.dart';
import 'package:meubitcoin/services/firebase_notification_service.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:meubitcoin/views/home.dart';
import 'package:get/instance_manager.dart';

Future<bool> loadBeforeInit() async {
  var deviceId = await Util.instance.getId();

  loadControllers();

  // Firebase Setup BEGIN
  await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(
  //     FirebaseNotificaitonService.onBackgroundMessage);
  await FirebaseNotificaitonService.instance.init();
  Util.instance.logMe(deviceId, title: "Device ID");
  Util.instance
      .logMe(FirebaseNotificaitonService.instance.token, title: "FCM Token");
// Firebase Setup END
  return true;
}

void loadControllers() {
  // Get.put(TmpController());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadBeforeInit();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final FcmFirebaseRepository _fcmRepository = FcmFirebaseRepository();
  @override
  void initState() {
    super.initState();
    print("Doing ASYNC");
    doAsync();
  }

  Future doAsync() async {}

  GetMaterialApp materialApp = GetMaterialApp(
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
