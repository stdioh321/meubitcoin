import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/route_manager.dart';
import 'package:meubitcoin/repositories/fcm_firebase_repository.dart';
import 'package:meubitcoin/services/firebase_notification_service.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:meubitcoin/views/home.dart';
import 'package:meubitcoin/views/ticker-detail.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

Future<bool> loadBeforeInit() async {
  // Firebase Setup BEGIN
  await Firebase.initializeApp();
  await FirebaseNotificaitonService.instance.init();
  loadControllers();

  Util.instance.logMe(await Util.instance.getId(), title: "Device ID");
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
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MeuBitcoin",
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch:
              Util.instance.toMaterialColor(Colors.amberAccent.shade700)),
      home: Home(),
    );
  }
}
