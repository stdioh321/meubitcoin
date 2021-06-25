import 'dart:async';

import 'package:flutter/material.dart';

import 'package:meubitcoin/models/Coin.dart';
import 'package:meubitcoin/utils/api.dart';
import 'package:meubitcoin/utils/loading.dart';
import 'package:meubitcoin/utils/util.dart';
import 'package:meubitcoin/views/ticker-detail.dart';
import 'package:simple_search_bar/simple_search_bar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Ticker> _tickers = [];
  List<Ticker> tickers = [];
  List<Ticker> _oldTickers = [];
  Status status = Status.none;
  Timer? timer;
  int time = 5;
  bool _isConnected = false;
  final AppBarController appBarController = AppBarController();

  @override
  void initState() {
    // TODO: implement initState
    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
  }

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    // TODO: implement didUpdateWidget
    print("didUpdateWidget");
  }

  void init() {
    status = Status.none;
    loadTickers().then((value) {
      timer = Timer.periodic(Duration(seconds: time), (timer) async {
        try {
          if (appBarController.state || status == Status.error)
            throw Exception("Not now.");
          print(timer.tick);
          await getTickers();
          setState(() {});
        } catch (e) {}
      });
    });
  }

  Future getTickers() async {
    var response = await Api.instance.getTicker();
    if (_tickers.length > 0) _oldTickers = _tickers.toList();
    _tickers = coinFromJson(response.body).ticker;
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
        body: GestureDetector(
          child: _buildBody(),
          onTap: () {
            // appBarController.stream.add(false);
          },
        ),
        appBar: SearchAppBar(
          primary: Theme.of(context).primaryColor,
          mainAppBar: AppBar(
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
            print("search: $search");
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
        child: ListView(
          children: tickers.length < 1
              ? [
                  ListTile(
                    title: Text("Vazio"),
                  )
                ]
              : tickers.map((e) {
                  Widget tmp;
                  if (double.parse(e.last) > double.parse(e.buy))
                    tmp = Icon(
                      Icons.arrow_drop_down,
                      color: Colors.red.shade900,
                    );
                  else if (double.parse(e.last) < double.parse(e.buy))
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
                        Text("Compra: R\$ ${e.buy}"),
                        Text("Venda: R\$ ${e.sell}"),
                        Text("Último: R\$ ${e.buy}"),
                      ],
                    ),
                    title: Text("${e.pair}".substring(3)),
                    leading: Wrap(
                      children: [
                        Icon(Icons.attach_money),
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
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TickerDetail(
                                    pair: e.pair,
                                  )));
                    },
                  );
                }).toList(),
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
