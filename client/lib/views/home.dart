import 'dart:async';

import 'package:get/route_manager.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:meubitcoin/repositories/fcm_repository.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:flutter/material.dart';

import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/utils/api.dart';
import 'package:meubitcoin/utils/loading.dart';
import 'package:meubitcoin/views/ticker-detail.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FcmRepository fcmRepository = FcmRepository();

  List<Ticker> _tickers = [];
  List<Ticker> tickers = [];
  Status status = Status.none;
  Timer? timer;
  int time = 5;

  FloatingSearchBarController _floatingSearchBarController =
      FloatingSearchBarController();

  @override
  void initState() {
    // TODO: implement initState
    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    // TODO: implement didUpdateWidget
  }

  void init() async {
    status = Status.none;
    loadTickers();
  }

  Future getTickers() async {
    _tickers = await Api.instance.getTickers();
    tickers = _tickers.toList();
  }

  Future loadTickers() async {
    if (status == Status.loading) return;
    try {
      status = Status.loading;
      setState(() {});
      await getTickers();
      _startTimer();

      status = Status.ok;
      setState(() {});
    } catch (e) {
      status = Status.error;
      setState(() {});
    }
  }

  void _startTimer() {
    if (timer == null)
      timer = Timer.periodic(Duration(seconds: time), (timer) async {
        try {
          if (status == Status.ok && _floatingSearchBarController.isClosed) {
            await getTickers();
            setState(() {});
          }
        } catch (e) {}
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingSearchAppBar(
        title: Text(
          "MeuBitcoin",
          style: TextStyle(color: Colors.white),
        ),
        controller: _floatingSearchBarController,
        clearQueryOnClose: true,
        color: Theme.of(context).accentColor,
        colorOnScroll: Theme.of(context).accentColor,
        iconColor: Colors.white,
        hintStyle: TextStyle(
          color: Colors.white.withAlpha(60),
        ),
        hint: "BTC",
        titleStyle: TextStyle(color: Colors.white),
        debounceDelay: Duration(milliseconds: 300),
        elevation: 5,
        onQueryChanged: _onSearch,
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: _buildBody(),
        ),
        hideKeyboardOnDownScroll: true,
      ),
    );
  }

  _onSearch(String query) {
    setState(() {
      tickers = _tickers
          .where((e) =>
              e.pair
                  .trim()
                  .toLowerCase()
                  .indexOf((query).trim().toLowerCase()) >
              -1)
          .toList();
    });
  }

  // FloatingSearchAppBar _buildAppBar() {
  //   return FloatingSearchAppBar(
  //     body: Text("Search"),
  //   );
  // }

  Widget _buildBody() {
    if (status == Status.loading || status == Status.none)
      return Center(child: CircularProgressIndicator());
    else if (status == Status.ok) {
      if (tickers.isEmpty)
        return Center(
          child: Text(
            "Nada encontrado.",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
          ),
        );
      return ListView.separated(
        itemCount: tickers.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          Ticker currTicker = tickers[index];
          Widget tmp;
          if (double.parse(currTicker.last) > double.parse(currTicker.buy))
            tmp = Icon(
              Icons.arrow_drop_down,
              color: Colors.red.shade900,
            );
          else if (double.parse(currTicker.last) < double.parse(currTicker.buy))
            tmp = Icon(
              Icons.arrow_drop_up,
              color: Colors.green.shade900,
            );
          else
            tmp = Container(
              width: 24,
              height: 24,
              // decoration: BoxDecoration(color: Colors.red),
              child: Icon(
                Icons.remove,
                color: Colors.blue.shade900,
                size: 15,
              ),
            );

          return ListTile(
            dense: true,
            isThreeLine: true,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Compra: " + Util.instance.toReal(currTicker.buy)),
                Text("Venda: " + Util.instance.toReal(currTicker.sell)),
                // Text("??ltimo: " + Util.instance.toReal(currTicker.last)),
              ],
            ),
            title: Text(
              "${currTicker.pair}",
              style: TextStyle(fontSize: 22),
            ),
            leading: Wrap(
              children: [
                SizedBox(
                  width: 45,
                  child: Image.asset(
                    "assets/images/coin_image/${currTicker.pair}.png",
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        "assets/images/coin_image/placeholder.png",
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                )
              ],
            ),
            trailing: Wrap(
              alignment: WrapAlignment.start,
              children: [
                tmp,
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
            onTap: () async {
              Util.instance.removeFocus(context);
              await Get.to(TickerDetail(pair: currTicker.pair));
            },
          );
        },
      );
    }
    return FutureBuilder(
      future: Util.instance.hasConnection(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.hasError)
          return Center(
            child: CircularProgressIndicator(),
          );
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(snapshot.data == false ? "Sem Internet" : "Algo deu errado"),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    loadTickers();
                  },
                  child: Text("Tentar novamente."))
            ],
          ),
        );
      },
    );
  }
}
