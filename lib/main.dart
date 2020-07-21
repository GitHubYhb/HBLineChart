import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HBLineChart/hb_kline_chart/hb_chart_data_util.dart';
import 'package:HBLineChart/hb_kline_chart/hb_k_line_chart.dart';
import 'package:HBLineChart/hb_kline_chart/hb_minute_line_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HBLineChart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List datas = [];
  List klineDatas = [];

  @override
  void initState() {
    // getData();
    getMockMinuteData();
    getMockKlineData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("组件测试"),
      ),
      body: ListView(
        children: <Widget>[
          HBMinuteLineChart(datas: datas),
          HBKLineChart(
            datas: klineDatas,
          )
        ],
      ),
    );
  }

  getMockMinuteData() {
    rootBundle
        .loadString('lib/hb_kline_chart/mock_data/minute_line.json')
        .then((result) {
      List dataList = jsonDecode(result);
      List newData = [];
      double maxPrice = 0, minPrice = double.infinity;
      double sumPirce = 0;
      double avePirce = 0;
      int maxv = 0;
      for (var i = 0; i < dataList.length; i++) {
        double prePrice =
            HBDataUtil.valueToNum(i == 0 ? "0" : dataList[i - 1]["price"])
                .toDouble();
        double price = HBDataUtil.valueToNum(dataList[i]["price"]).toDouble();
        int vol = HBDataUtil.valueToNum(dataList[i]["vol"]).toInt();
        // //涨跌状态
        bool upDown = price > prePrice;
        sumPirce += price;
        avePirce = sumPirce / (i + 1);
        if (price > maxPrice) {
          maxPrice = price;
        }
        if (price < minPrice) {
          minPrice = price;
        }
        if (vol > maxv) {
          maxv = vol;
        }
        Map m = {
          "price": price,
          "vol": vol,
          "time": dataList[i]["time"],
          "upDown": upDown,
          "ave": avePirce
        };
        newData.add(m);
      }
      datas = newData;
      setState(() {});
    });
  }

  getMockKlineData() async {
    rootBundle
        .loadString('lib/hb_kline_chart/mock_data/k_line.json')
        .then((result) {
      List dataList = jsonDecode(result);
      List data = [];
      for (var i = 0; i < dataList.length; i++) {
        Map m = dataList[i];
        Map newMap = {
          "open": HBDataUtil.valueToNum(m["open"]).toDouble(),
          "high": HBDataUtil.valueToNum(m["high"]).toDouble(),
          "low": HBDataUtil.valueToNum(m["low"]).toDouble(),
          "close": HBDataUtil.valueToNum(m["close"]).toDouble(),
          "vol": HBDataUtil.valueToNum(m["vol"]).toDouble(),
          "date": m["date"],
        };
        data.add(newMap);
      }
      klineDatas = data;
      HBDataUtil.calculate(klineDatas);
      setState(() {});
    });
  }
}
