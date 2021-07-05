import 'package:firebase_messaging/firebase_messaging.dart';

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
    FirebaseMessaging.onBackgroundMessage(
        FirebaseNotificaitonService.onBackgroundMessage);
    token = (await messaging.getToken())!;
    print("Token: $token");

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);

    inited = true;
  }

  void onMessage(RemoteMessage message) {
    print("Message Received");
    print(message.notification!.body);
  }

  void onMessageOpenedApp(RemoteMessage message) {
    print("MessageOpenedApp Received");
    print(message.notification!.body);
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    print('background message ${message.notification!.body}');
  }
}
