import 'dart:collection';
import 'dart:convert';
import 'dart:io';

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

  MaterialColor toMaterialColor(Color c) {
    var mapColors = {
      50: Color.fromRGBO(136, 14, 79, .1),
      100: Color.fromRGBO(136, 14, 79, .2),
      200: Color.fromRGBO(136, 14, 79, .3),
      300: Color.fromRGBO(136, 14, 79, .4),
      400: Color.fromRGBO(136, 14, 79, .5),
      500: Color.fromRGBO(136, 14, 79, .6),
      600: Color.fromRGBO(136, 14, 79, .7),
      700: Color.fromRGBO(136, 14, 79, .8),
      800: Color.fromRGBO(136, 14, 79, .9),
      900: Color.fromRGBO(136, 14, 79, 1),
    };
    return MaterialColor(c.value, mapColors);
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
}
