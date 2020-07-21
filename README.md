# HBLineChart
# 启
借鉴自[flutter_k_chart](https://www.jianshu.com/p/ba95a31bcc1e)

公司项目中有涉及到股票类K线及分时线，原先使用flutter_k_chart，但是由于样式及数据方面的问题，决定自己从头开始画一个。

移动端、WEB端都支持。
现有指标有`MACD`、`KDJ`、`BOLL`，

废话不多说。先上图
# 图
![分时线](https://upload-images.jianshu.io/upload_images/2395731-ade1d07a9cfaac75.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![K线](https://upload-images.jianshu.io/upload_images/2395731-a21596f98d81c940.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


点击K线图，VOL窗口进行切换指标。
![切换指标](https://upload-images.jianshu.io/upload_images/2395731-f8c7cf330deece12.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![MACD](https://upload-images.jianshu.io/upload_images/2395731-0093378e575fa85f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![KDJ](https://upload-images.jianshu.io/upload_images/2395731-f69fcd7650054b1e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![BOLL](https://upload-images.jianshu.io/upload_images/2395731-9d9965e14a50d065.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# HOW TO USE
###demo 地址
https://github.com/GitHubYhb/HBLineChart

###demo
```
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
          HBKLineChart(datas: klineDatas,)
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
        Map m = dataList[I];
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
      //计算各种指标
      HBDataUtil.calculate(klineDatas);
      setState(() {});
    });
  }
}

```

## 数据
####分时线

```
[
    {
        "price": 4542,
        "vol": 49722,
        "time": "20:00"
    },
    {
        "price": 4540,
        "vol": 26100,
        "time": "20:01"
    },
]
```
 ---
##***重要提示：***
分时线需要提前在`/lib/hb_chart_config.dart`中设置好整体长度`lineChartCount`，否则可能会出现显示错误的问题。
![image.png](https://upload-images.jianshu.io/upload_images/2395731-347337b7737deb69.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
---

#### K线
```
[
    {
        "open": "270.31",
        "high": "272.38",
        "low": "269.95",
        "close": "271.89",
        "vol": "66164",
        "date": "20170117"
    },
    {
        "open": "272.59",
        "high": "272.59",
        "low": "270.8",
        "close": "270.98",
        "vol": "71134",
        "date": "20170118"
    },
]
```
## UI

在文件`/lib/hb_chart_config.dart`中，有各种颜色、宽度、长度等等。
```
import 'package:flutter/material.dart';

//分时线数据总长度
int lineChartCount = 781;
//柱状图最大宽度
double colMaxWidth = 5;

//蜡烛间隔
double candleSpace = 10;
//蜡烛宽度
double candleWidth = 8.5;
//蜡烛中间线的宽度
double candleLineWidth = 1.5;

//长按字体底色
Color timePriceTextColor = Colors.white;
//长按背景底色
Color timePriceMarkColor = Colors.blue;

//涨颜色
Color upColor = Colors.red;
//跌颜色
Color dnColor = Colors.green;

//交叉线宽度
double crossLineWidth = 0.5;
//交叉线颜色
Color crossLineColor = Colors.black;
//交叉线中心颜色
Color dotColor = Colors.red;

//分时线均线颜色
Color aveColor = Colors.purple;

//现价颜色
Color currentPriceColor = Colors.black87;
//均价颜色
Color avePriceColor = Colors.brown;

//各种指标线 三种颜色
Color kValue1Color = Colors.brown;
Color kValue2Color = Colors.blue;
Color kValue3Color = Colors.purple;

double leftFontSize = 12.0;
double topFontSize = 12.0;
double bottomFontSize = 10.0;

```


