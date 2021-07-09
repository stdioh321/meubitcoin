import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/utils/api.dart';

class TmpController extends GetxController {
  static TmpController get to => Get.find();
  int count = 0;
  Ticker? ticker;
  TmpController() {}

  void increment() {
    count++;
    update();
  }
}
