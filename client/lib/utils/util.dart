import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meubitcoin/models/Coin.dart';

class Util {
  Util._privateConstructor();

  static final Util _instance = Util._privateConstructor();

  static Util get instance => _instance;

  Future<bool> hasConnection() async {
    try {
      return (await InternetAddress.lookup("www.google.com")).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  NumberFormat real =
      NumberFormat.currency(locale: 'pt_BR', name: "R\$", decimalDigits: 5);
  String toReal([dynamic val]) {
    try {
      if (val.runtimeType == String) return real.format(double.parse(val));
      return real.format(val);
    } catch (e) {
      return val;
    }
  }

  MaterialColor toMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  void removeFocus([BuildContext? context]) {
    try {
      FocusScope.of(context!).unfocus();
      var tec = TextEditingController();
      tec.clear();
      tec.dispose();
    } catch (e) {}
  }

  Image imgOrPlaceholder(String pathImg, double? width, String pathPlaceholder,
      double? widthPlaceholder) {
    return Image.asset(
      pathImg,
      fit: BoxFit.contain,
      width: width ?? 24,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Image.asset(pathPlaceholder,
            fit: BoxFit.contain, width: widthPlaceholder ?? 24);
      },
    );
  }

  Future<String> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  void logMe(dynamic text, {String title: "LogMe"}) {
    print("${title.toString().padRight(100, '=')}");
    print(text);
    print("".padRight(100, "="));
  }

  ScaffoldFeatureController defaultSnackBar(BuildContext context, String text,
      {SnackBar? snackBar: null}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      snackBar == null ? SnackBar(content: Text(text)) : snackBar,
    );
  }

  DateFormat defaultDateFormat() {
    return DateFormat('dd-MM-yyyy HH:mm:ss');
  }
}
