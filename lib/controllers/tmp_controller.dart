import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TmpController extends GetxController {
  static TmpController get to => Get.find();

  var count = 0.obs;

  void increment() {
    count++;
  }
}
