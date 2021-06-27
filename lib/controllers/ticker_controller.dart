import 'package:get/get.dart';
import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/utils/api.dart';
import 'package:meubitcoin/utils/loading.dart';

class TickerController extends GetxController {
  static TickerController get to => Get.find();

  List<Ticker> tickers = [];
  var status = Status.none;

  Future loadTickers() async {
    status = Status.loading;
    try {
      tickers = await Api.instance.getTicker();
      status = Status.ok;
    } catch (e) {
      status = Status.error;
      throw e;
    }
    update();
  }
}
