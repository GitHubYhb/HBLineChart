import 'package:flutter/material.dart';
import 'hb_chart_config.dart';

enum HBKLineVolType { VOL, MACD, KDJ, BOLL }

class HBKLineVolPainter extends CustomPainter {
  final List datas;
  final double selectedX;
  final double scrollX;
  final double scale;
  final bool showBorder;
  final bool showDate;
  final bool isLongPress;
  final Function onSelected;
  final HBKLineVolType type;
  HBKLineVolPainter({
    this.selectedX,
    this.scrollX,
    this.scale = 1.0,
    this.showBorder = true,
    this.showDate = true,
    this.type,
    this.isLongPress,
    this.onSelected,
    @required this.datas,
  });

  double maxValue; //最大值
  double minValue; //最小值
  Map selectedMap;
  Paint _paint = new Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (datas.length <= 0) {
      return;
    }
    canvas.save();
    canvas.translate(0, 20);
    _paint.color = Colors.grey[300];
    Size newSize = size;
    //一页放几个
    int count = size.width ~/ (candleSpace * scale);
    count = count > datas.length ? datas.length : count;
    //滚动了几个
    int scrollIndex = scrollX ~/ (candleSpace * scale) >= 0
        ? scrollX ~/ (candleSpace * scale)
        : 0;
    if (scrollIndex > datas.length - count) {
      scrollIndex = datas.length - count;
    }
    //起始位置
    int beginIndex = datas.length - count - scrollIndex;
    String beginDate = datas[beginIndex]["date"];
    String endDate = datas[beginIndex + count - 1]["date"];

    if (showDate) {
      newSize = Size(size.width, size.height - 40);
      //画日期
      drawDate(canvas, newSize, beginDate, endDate);
    }
    if (showBorder)
      //画边框
      drawBorder(canvas, newSize);

    if (type == HBKLineVolType.VOL) {
      getVOLMaxMin(count, beginIndex);
      //左侧最高交易量
      drawVOLLeftText(canvas, size);
      //画交易量
      drawVolChart(canvas, newSize, count, beginIndex);
    } else if (type == HBKLineVolType.MACD) {
      getMACDMaxMin(count, beginIndex);
      drawMACDChart(canvas, newSize, count, beginIndex);
      drawLeftText(canvas, newSize);
    } else if (type == HBKLineVolType.KDJ) {
      getKDJMaxMin(count, beginIndex);
      drawKDJChart(canvas, newSize, count, beginIndex);
      drawLeftText(canvas, newSize);
    } else if (type == HBKLineVolType.BOLL) {
      //获取最大最小值
      getBOLLMaxMin(count, beginIndex);
      drawCandleLineChart(canvas, newSize, count, beginIndex);
      drawLeftText(canvas, newSize);
    }
    if (isLongPress) {
      drawCrossLine(canvas, newSize, count, beginIndex, selectedX ?? 0);
    }

    canvas.restore();
    drawTopText(canvas, size);
  }

  drawBorder(Canvas canvas, Size size) {
    _paint.color = Colors.grey[300];
    //画边框
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), _paint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), _paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), _paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), _paint);
  }

  drawVolChart(Canvas canvas, Size size, int count, int beginIndex) {
    double pwidth = candleSpace * scale;
    Path ma5VolPath = Path();
    Path ma10VolPath = Path();
    for (var i = 0; i < count; i++) {
      // bool upDown = data[i]["upDown"];
      Map data = datas[beginIndex + i];
      double open = getVolY(data["open"], size);
      double close = getVolY(data["close"], size);

      if (open > close) {
        _paint.color = upColor;
      } else {
        _paint.color = dnColor;
      }
      double x = pwidth * i;
      double linex = pwidth * i + pwidth / 2;
      double y = getVolY(data["vol"], size);
      double ma5Vol = data["ma5Volume"];
      double ma10Vol = data["ma10Volume"];
      if (i == 0) {
        ma5VolPath.moveTo(linex, getVolY(ma5Vol, size));
        ma10VolPath.moveTo(linex, getVolY(ma10Vol, size));
      } else {
        ma5VolPath.lineTo(linex, getVolY(ma5Vol, size));
        ma10VolPath.lineTo(linex, getVolY(ma10Vol, size));
      }

      double endY = size.height;
      _paint.style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromPoints(Offset(x, y), Offset(x + pwidth - 1, endY)), _paint);
    }
    _paint.color = kValue1Color;
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(ma5VolPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(ma10VolPath, _paint);
  }

  drawMACDChart(Canvas canvas, Size size, int count, int beginIndex) {
    double pwidth = candleSpace * scale;
    Path difPath = Path();
    Path deaPath = Path();
    _paint.color = Colors.black54;
    canvas.drawLine(Offset(0, getY(0.0, size)),
        Offset(size.width, getY(0.0, size)), _paint);
    for (var i = 0; i < count; i++) {
      Map data = datas[beginIndex + i];
      double open = getY(data["open"], size);
      double close = getY(data["close"], size);

      if (open > close) {
        _paint.color = upColor;
      } else {
        _paint.color = dnColor;
      }

      double linex = pwidth * i + pwidth / 2;
      double y = getY(data["macd"], size);
      double dif = data["dif"];
      double dea = data["dea"];
      if (i == 0) {
        difPath.moveTo(linex, getY(dif, size));
        deaPath.moveTo(linex, getY(dea, size));
      } else {
        difPath.lineTo(linex, getY(dif, size));
        deaPath.lineTo(linex, getY(dea, size));
      }

      _paint.style = PaintingStyle.fill;
      if (data["macd"] > 0) {
        _paint.color = upColor;
      } else {
        _paint.color = dnColor;
      }
      canvas.drawLine(Offset(linex, y), Offset(linex, getY(0, size)), _paint);
    }

    _paint.color = kValue1Color;
    _paint.style = PaintingStyle.stroke;
    canvas.drawPath(difPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(deaPath, _paint);
  }

  drawKDJChart(Canvas canvas, Size size, int count, int beginIndex) {
    double pwidth = candleSpace * scale;
    Path kPath = Path();
    Path dPath = Path();
    Path jPath = Path();

    for (var i = 0; i < count; i++) {
      Map data = datas[beginIndex + i];
      double linex = pwidth * i + pwidth / 2;
      double k = getY(data["k"], size);
      double d = getY(data["d"], size);
      double j = getY(data["j"], size);
      if (i == 0) {
        kPath.moveTo(linex, k);
        dPath.moveTo(linex, d);
        jPath.moveTo(linex, j);
      } else {
        kPath.lineTo(linex, k);
        dPath.lineTo(linex, d);
        jPath.lineTo(linex, j);
      }
    }
    _paint.style = PaintingStyle.stroke;
    _paint.color = kValue1Color;
    canvas.drawPath(kPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(dPath, _paint);
    _paint.color = kValue3Color;
    canvas.drawPath(jPath, _paint);
  }

  drawCandleLineChart(Canvas canvas, Size size, int count, int beginIndex) {
    _paint.style = PaintingStyle.fill;
    double pwidth = candleSpace * scale;
    Path upPath = Path();
    Path mbPath = Path();
    Path dnPath = Path();
    //遍历画蜡烛
    for (var i = 0; i < count; i++) {
      Map data = datas[beginIndex + i];
      _paint.style = PaintingStyle.fill;
      drawCandle(canvas, data, size, i * candleSpace + candleSpace / 2);

      double linex = pwidth * i + pwidth / 2;
      double up = getY(data["up"], size);
      double mb = getY(data["mb"], size);
      double dn = getY(data["dn"], size);
      if (i == 0) {
        upPath.moveTo(linex, up);
        mbPath.moveTo(linex, mb);
        dnPath.moveTo(linex, dn);
      } else {
        upPath.lineTo(linex, up);
        mbPath.lineTo(linex, mb);
        dnPath.lineTo(linex, dn);
      }
    }
    _paint.style = PaintingStyle.stroke;
    _paint.color = kValue1Color;

    canvas.drawPath(mbPath, _paint);
    _paint.color = kValue2Color;
    canvas.drawPath(upPath, _paint);
    _paint.color = kValue3Color;
    canvas.drawPath(dnPath, _paint);
  }

  drawCandle(Canvas canvas, Map data, Size size, double curX) {
    double high = getY(data["high"], size);
    double low = getY(data["low"], size);
    double open = getY(data["open"], size);
    double close = getY(data["close"], size);
    double r = candleWidth / 2 * scale;
    double lineR = candleLineWidth / 2 * scale;

    if (open > close) {
      _paint.color = upColor;
      canvas.drawRect(Rect.fromLTRB(curX - r, close, curX + r, open), _paint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), _paint);
    } else {
      _paint.color = dnColor;
      canvas.drawRect(Rect.fromLTRB(curX - r, open, curX + r, close), _paint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), _paint);
    }
  }

  drawVOLLeftText(Canvas canvas, Size size) {
    TextSpan span = TextSpan(
        text: maxValue.toStringAsFixed(0),
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }

  drawLeftText(Canvas canvas, Size size) {
    TextSpan span = TextSpan(
        text: maxValue.toStringAsFixed(2),
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
    TextSpan span2 = TextSpan(
        text: minValue.toStringAsFixed(2),
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize));
    TextPainter tp2 =
        TextPainter(text: span2, textDirection: TextDirection.ltr);
    tp2.layout();
    tp2.paint(canvas, Offset(2, size.height - 15));
  }

  drawCrossLine(Canvas canvas, Size size, int count, int beginIndex, double x) {
    Paint _paint = new Paint()
      ..color = crossLineColor
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true
      ..strokeWidth = crossLineWidth
      ..style = PaintingStyle.stroke;

    if (x > size.width) {
      x = size.width;
    }
    if (x <= 0) {
      x = 0;
    }

    //double y = getY(data[getIndex(x, size)]["price"],size);
    int index = getIndex(x, size, datas);
    String time = datas[index + beginIndex]["date"];
    onSelected(datas[index + beginIndex]);
    selectedMap = datas[index + beginIndex];
    double pwidth = candleSpace * scale;
    double sx = index * pwidth + pwidth / 2;
    canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), _paint);

    //画选中时间框和时间text
    _paint
      ..color = timePriceMarkColor
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
        text: time,
        style: TextStyle(color: timePriceTextColor, fontSize: bottomFontSize));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    double cWidth = tp.width + 10;
    double cHeight = 16;
    Rect rect = Rect.fromCenter(
        center: Offset(sx, size.height + 10), width: cWidth, height: cHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)), _paint);

    tp.paint(
        canvas,
        Offset(rect.left + (cWidth - tp.width) / 2,
            rect.top + (cHeight - tp.height) / 2));
  }

  drawTopText(Canvas canvas, Size size) {
    Map data;
    String title1, title2, title3;
    String value1, value2, value3;
    if (isLongPress && selectedMap != null) {
      data = selectedMap;
    } else {
      data = datas.last;
    }
    if (type == HBKLineVolType.VOL) {
      title1 = "VOL:";
      title2 = "MA5:";
      title3 = "MA10:";
      double vol = data["vol"];
      double ma5 = data["ma5Volume"];
      double ma10 = data["ma10Volume"];
      value1 = vol.toStringAsFixed(0);
      value2 = ma5.toStringAsFixed(0);
      value3 = ma10.toStringAsFixed(0);
    } else if (type == HBKLineVolType.MACD) {
      title1 = "MACD:";
      title2 = "DIFF:";
      title3 = "DEA:";
      double macd = data["macd"];
      double diff = data["dif"];
      double dea = data["dea"];
      value1 = macd.toStringAsFixed(2);
      value2 = diff.toStringAsFixed(2);
      value3 = dea.toStringAsFixed(2);
    } else if (type == HBKLineVolType.KDJ) {
      title1 = "KDJ K:";
      title2 = "D:";
      title3 = "J:";
      double k = data["k"];
      double d = data["d"];
      double j = data["j"];
      value1 = k.toStringAsFixed(2);
      value2 = d.toStringAsFixed(2);
      value3 = j.toStringAsFixed(2);
    } else if (type == HBKLineVolType.BOLL) {
      title1 = "BOLL MID:";
      title2 = "UPPER:";
      title3 = "LOWER:";
      double mb = data["mb"];
      double up = data["up"];
      double dn = data["dn"];
      value1 = mb.toStringAsFixed(2);
      value2 = up.toStringAsFixed(2);
      value3 = dn.toStringAsFixed(2);
    }

    double fontSize = topFontSize;
    TextSpan span1 = TextSpan(
        text: title1 + value1 + "  ",
        style: TextStyle(color: kValue1Color, fontSize: fontSize));
    TextSpan span2 = TextSpan(
        text: title2 + value2 + "  ",
        style: TextStyle(color: kValue2Color, fontSize: fontSize));
    TextSpan span3 = TextSpan(
        text: title3 + value3 + "  ",
        style: TextStyle(color: kValue3Color, fontSize: fontSize));
    TextSpan span = TextSpan(children: [span1, span2, span3]);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }

  drawDate(Canvas canvas, Size size, String beginDate, String endDate) {
    TextStyle style = TextStyle(color: Colors.grey, fontSize: bottomFontSize);
    TextSpan span = TextSpan(text: "$beginDate", style: style);
    TextSpan span2 = TextSpan(text: "$endDate", style: style);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    TextPainter tp2 =
        TextPainter(text: span2, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, size.height));
    tp2.layout();
    tp2.paint(canvas, Offset(size.width - tp2.width, size.height));
  }

  int getIndex(double x, Size size, List data) {
    double pwidth = candleSpace * scale;
    int index = x ~/ pwidth - 1;
    if (index > lineChartCount - 1) {
      index = lineChartCount - 1;
    }
    if (index < 0) {
      index = 0;
    }

    if (index > data.length - 1) {
      index = data.length - 1;
    }
    return index;
  }

  double getVolY(double value, Size size) {
    return size.height * (1 - (value / maxValue));
  }

  double getY(double value, Size size) {
    double d = maxValue - minValue;
    double currentD = value - minValue;
    double p = 1 - currentD / d;
    return size.height * p;
  }

  getVOLMaxMin(int count, int index) {
    maxValue = 0;
    minValue = 9999999999;
    for (var i = 0; i < count; i++) {
      Map m = datas[index + i];
      if (maxValue < m["vol"]) {
        maxValue = m["vol"];
      }
      if (maxValue < m["ma5Volume"]) {
        maxValue = m["ma5Volume"];
      }
      if (maxValue < m["ma10Volume"]) {
        maxValue = m["ma10Volume"];
      }
      if (minValue > m["vol"]) {
        minValue = m["vol"];
      }

      if (minValue > m["ma5Volume"]) {
        minValue = m["ma5Volume"];
      }
      if (minValue > m["ma10Volume"]) {
        minValue = m["ma10Volume"];
      }
    }
  }

  getMACDMaxMin(int count, int index) {
    maxValue = 0;
    minValue = 9999999999;
    for (var i = 0; i < count; i++) {
      Map m = datas[index + i];
      if (maxValue < m["macd"]) {
        maxValue = m["macd"];
      }
      if (maxValue < m["dif"]) {
        maxValue = m["dif"];
      }
      if (maxValue < m["dea"]) {
        maxValue = m["dea"];
      }
      if (minValue > m["macd"]) {
        minValue = m["macd"];
      }

      if (minValue > m["dif"]) {
        minValue = m["dif"];
      }
      if (minValue > m["dea"]) {
        minValue = m["dea"];
      }
    }
  }

  getKDJMaxMin(int count, int index) {
    maxValue = 0;
    minValue = 9999999999;
    for (var i = 0; i < count; i++) {
      Map m = datas[index + i];
      if (maxValue < m["k"]) {
        maxValue = m["k"];
      }
      if (maxValue < m["d"]) {
        maxValue = m["d"];
      }
      if (maxValue < m["j"]) {
        maxValue = m["j"];
      }
      if (minValue > m["k"]) {
        minValue = m["k"];
      }

      if (minValue > m["d"]) {
        minValue = m["d"];
      }
      if (minValue > m["j"]) {
        minValue = m["j"];
      }
    }
  }

  getBOLLMaxMin(int count, int index) {
    maxValue = 0;
    minValue = 9999999999;
    for (var i = 0; i < count; i++) {
      Map m = datas[index + i];
      if (maxValue < m["high"]) {
        maxValue = m["high"];
      }
      if (maxValue < m["up"]) {
        maxValue = m["up"];
      }

      if (minValue > m["low"]) {
        minValue = m["low"];
      }
      if (minValue > m["dn"]) {
        minValue = m["dn"];
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return true;
  }
}
