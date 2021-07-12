import 'dart:async';

import 'package:get/get.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/models/fcm.dart';
import 'package:meubitcoin/repositories/fcm_repository.dart';
import 'package:meubitcoin/utils/api.dart';
import 'package:meubitcoin/utils/loading.dart';

class TickerDetailController extends GetxController {
  String? coin;
  String? idDevice;
  Ticker? ticker;
  List<Fcm> fcms = [];
  Set<String> removedFcms = Set();
  Timer? timer;
  int secondsRefreshTicker = 10;
  Map addAlertData = {};
  var status = Status.none;
  var statusAddFcm = Status.none;
  var statusRemoveFcm = Status.none;

  FcmRepository _fcmRepository = FcmRepository();
  TickerDetailController() {}
  init(String coin, String idDevice) {
    this.coin = coin;
    this.idDevice = idDevice;
    addAlertData = resetAddAlertDate();
  }

  Map resetAddAlertDate() {
    addAlertData = {"price": "0.0000", "above": true};
    return addAlertData;
  }

  Future loadResources() async {
    try {
      status = Status.loading;
      update();
      await loadTicker();
      await loadFcms();
      status = Status.ok;
    } catch (e) {
      status = Status.error;
    }
    update();
  }

  Future loadTicker() async {
    ticker = (await Api.instance.getTickers(coin)).first;
    update();
  }

  Future loadFcms() async {
    fcms = await _fcmRepository.getByCoinIdDevice(
        idDevice: idDevice!, coin: coin!);
    update();
  }

  Future<bool> addFcm() async {
    try {
      statusAddFcm = Status.loading;
      update();
      var newFcm = await _fcmRepository.add(Fcm(
          idDevice: idDevice!,
          coin: coin!,
          price: double.parse(addAlertData["price"]),
          above: addAlertData["above"]));
      fcms.add(newFcm);
      statusAddFcm = Status.ok;
    } catch (e) {
      statusAddFcm = Status.error;
      update();
      return false;
    }

    update();
    return true;
  }

  Future<bool> removeFcm(String id) async {
    try {
      statusRemoveFcm = Status.loading;
      removedFcms.add(id);
      update();
      await _fcmRepository.remove(id);
      fcms.removeWhere((el) => el.id == id);
      statusRemoveFcm = Status.ok;
    } catch (e) {
      statusRemoveFcm = Status.error;
      removedFcms.remove(id);
      update();
      return false;
    }
    removedFcms.remove(id);
    update();
    return true;
  }
}
