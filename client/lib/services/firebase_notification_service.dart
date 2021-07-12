import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meubitcoin/main.dart';
import 'package:meubitcoin/views/ticker-detail.dart';

class FirebaseNotificaitonService {
  late FirebaseMessaging messaging;
  late String token;
  bool inited = false;

  FirebaseNotificaitonService._privateConstructor();

  static final FirebaseNotificaitonService instance =
      FirebaseNotificaitonService._privateConstructor();

  Future<void> init() async {
    if (inited == true) return;
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("all");
    messaging.onTokenRefresh.listen((event) {
      // token = event;
    });

    FirebaseMessaging.onBackgroundMessage(
        FirebaseNotificaitonService.onBackgroundMessage);

    token = (await messaging.getToken())!;

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

    inited = true;
  }

  void onMessage(RemoteMessage message) {
    print("Message Push Received: ${message.data}");
    print(message.notification!.body);
  }

  void onMessageOpenedApp(RemoteMessage message) {
    print("MessageOpenedApp Push Received: ${message.data}");
    String? coin = message.data["coin"];
    // print("onMessageOpenedApp");
    if (coin != null) {
      print("COIN: ${coin}");
      // Navigator.popUntil(
      //     navigatorKey.currentState!.context, (route) => route.isFirst);

      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TickerDetail(pair: coin!)));
    }
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    String coin = message.data["coin"];

    if (coin != null) {
      // Navigator.popUntil(context, (route) => route.isFirst);
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (_) => TickerDetail(pair: coin!)));
    }
  }
}
