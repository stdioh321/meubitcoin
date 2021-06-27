import 'dart:async';
import 'dart:developer';

import 'package:meubitcoin/controllers/ticker_controller.dart';
import 'package:meubitcoin/database/db.dart';
import 'package:meubitcoin/main.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:flutter/material.dart';

import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/utils/api.dart';
import 'package:meubitcoin/utils/loading.dart';
import 'package:meubitcoin/views/ticker-detail.dart';
// ignore: import_of_legacy_library_into_null_safe
import "package:simple_search_bar/simple_search_bar.dart";
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Ticker> _tickers = [];
  List<Ticker> tickers = [];
  Status status = Status.none;
  Timer? timer;
  int time = 5;
  final AppBarController appBarController = AppBarController();
  final controller = Get.put(TickerController());
  // final tmpController = Get.put(TmpController());

  @override
  void initState() {
    // TODO: implement initState
    init();

    // AFTER BRANCH tmp
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
    print("didUpdateWidget");
  }

  void init() async {
    var all = await DatabaseHelper.instance.queryAllRows();
    for (var c in all) {
      print(c.toJson());
    }
    TickerController.to.loadTickers();
    status = Status.none;
    loadTickers().then((value) {
      timer = Timer.periodic(Duration(seconds: time), (timer) async {
        try {
          if (appBarController.state || status == Status.error)
            throw Exception("Not now.");
          // print(timer.tick);
          await getTickers();
          setState(() {});
        } catch (e) {}
      });
    });
  }

  Future getTickers() async {
    _tickers = await Api.instance.getTicker();
    tickers = _tickers.toList();
  }

  Future loadTickers() async {
    if (status == Status.loading) return;
    try {
      status = Status.loading;
      setState(() {});
      await getTickers();
      status = Status.ok;
      setState(() {});
    } catch (e) {
      status = Status.error;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     await TmpController.to.increment();
        //   },
        //   child: Icon(
        //     Icons.add,
        //   ),
        // ),
        // body: _buildBody(),
        body: Container(
          child: _buildBody(),
        ),
        appBar: SearchAppBar(
          primary: Theme.of(context).primaryColor,
          mainAppBar: AppBar(
            // leading: GetBuilder<TmpController>(
            //     builder: (_) => Container(
            //           alignment: Alignment.center,
            //           child: Text(
            //             "${TmpController.to.count.value}",
            //             style: TextStyle(
            //               fontSize: 34,
            //             ),
            //           ),
            //         )),
            title: Text("MeuBitcoin"),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  onPressed: () {
                    loadTickers();
                  },
                  icon: Icon(
                    Icons.replay_outlined,
                  )),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: InkWell(
                  child: Icon(Icons.search),
                  onTap: () {
                    appBarController.stream.add(true);
                  },
                ),
              )
            ],
          ),
          appBarController: appBarController,
          onChange: (search) {
            // print("search: $search");
            tickers = _tickers.where((e) {
              return e.pair
                      .substring(3)
                      .toLowerCase()
                      .trim()
                      .indexOf(search.toLowerCase().trim()) >
                  -1;
            }).toList();
            setState(() {});
          },
        ));
  }

  Widget _buildBody() {
    if (status == Status.loading || status == Status.none)
      return Center(child: CircularProgressIndicator());
    else if (status == Status.ok)
      return Container(
        padding: EdgeInsets.all(5),
        child: ListView.separated(
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
            else if (double.parse(currTicker.last) <
                double.parse(currTicker.buy))
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
                  Text("Último: " + Util.instance.toReal(currTicker.last)),
                ],
              ),
              title: Text("${currTicker.pair}".substring(3)),
              leading: Wrap(
                children: [
                  SizedBox(
                    width: 45,
                    child: Image.asset(
                      "assets/images/coin_image/${currTicker.pair.substring(3)}.png",
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
                  Icon(
                    Icons.keyboard_arrow_right,
                  ),
                ],
              ),
              onTap: () async {
                Util.instance.removeFocus(context);

                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TickerDetail(
                              pair: currTicker.pair,
                            )));
              },
            );
          },
        ),
      );

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
