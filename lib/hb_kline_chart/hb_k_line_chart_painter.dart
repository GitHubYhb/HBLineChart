import 'package:flutter/material.dart';
import 'hb_chart_config.dart';

class HBKLinePainter extends CustomPainter {
  final List datas;
  final double selectedX;
  final double scrollX;
  final double scale;
  final bool showDate;
  final bool showBorder;
  final bool isLongPress;
  final Function onSelected;
  HBKLinePainter({
    this.showDate = true,
    this.showBorder = true,
    this.scrollX,
    this.selectedX,
    this.scale,
    this.isLongPress,
    this.onSelected,
    this.datas,
  });
  double maxValue; //最大值
  double minValue; //最小值
  double top = 20.0; //用于
  double bottom = 20.0; //用于放置时间
  Map selectedMap;
  Paint _paint = new Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.fill;

  Paint _avePaint = new Paint()
    ..color = aveColor
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

    //根据是否显示时间设置Size
    Size newSize = Size(size.width, size.height - 20);
    // if (showDate == false) {
    //   newSize = size;
    // }

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

    if (showBorder)
      //画边框
      drawBorder(canvas, newSize);

    //画虚线
    drawDashLine(canvas, newSize);

    //画K线
    drawCandleLineChart(canvas, newSize, count, beginIndex);
    //画MA线
    drawMALine(canvas, newSize, count, beginIndex);
    if (showDate) {
      //画日期
      drawDate(canvas, size, beginDate, endDate);
    }
    //画左侧文字
    drawLeftText(canvas, newSize);
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

  drawCandleLineChart(Canvas canvas, Size size, int count, int beginIndex) {
    //获取最大最小值
    getMaxMin(size, count, beginIndex);
    //遍历画蜡烛
    for (var i = 0; i < count; i++) {
      drawCandle(canvas, datas[beginIndex + i], size,
          i * candleSpace * scale + candleSpace * scale / 2);
    }
  }

  drawMALine(Canvas canvas, Size size, int count, int beginIndex) {
    //遍历画蜡烛
    Path ma5Path = Path();
    Path ma10Path = Path();
    Path ma20Path = Path();
    Path ma30Path = Path();
    bool hasMA5 = false, hasMA10 = false, hasMA20 = false, hasMA30 = false;
    for (var i = 0; i < count; i++) {
      Map data = datas[beginIndex + i];
      double ma5 = data["ma5"];
      double ma10 = data["ma10"];
      double ma20 = data["ma20"];
      double ma30 = data["ma30"];
      double x = (i + 1) * candleSpace * scale - candleSpace * scale / 2;
      if (ma5 != 0) {
        if (hasMA5 == false) {
          ma5Path.moveTo(x, getY(ma5, size));
          hasMA5 = true;
        } else {
          ma5Path.lineTo(x, getY(ma5, size));
        }
      }

      if (ma10 != 0) {
        if (hasMA10 == false) {
          ma10Path.moveTo(x, getY(ma10, size));
          hasMA10 = true;
        } else {
          ma10Path.lineTo(x, getY(ma10, size));
        }
      }
      if (ma20 != 0) {
        if (hasMA20 == false) {
          ma20Path.moveTo(x, getY(ma20, size));
          hasMA20 = true;
        } else {
          ma20Path.lineTo(x, getY(ma20, size));
        }
      }
      if (ma30 != 0) {
        if (hasMA30 == false) {
          ma30Path.moveTo(x, getY(ma30, size));
          hasMA30 = true;
        } else {
          ma30Path.lineTo(x, getY(ma30, size));
        }
      }
    }
    _avePaint.color = kValue1Color;
    canvas.drawPath(ma5Path, _avePaint);
    _avePaint.color = kValue2Color;
    canvas.drawPath(ma10Path, _avePaint);
    _avePaint.color = kValue3Color;
    canvas.drawPath(ma30Path, _avePaint);
  }

  drawCandle(Canvas canvas, Map data, Size size, double curX) {
    double high = getY(data["high"], size);
    double low = getY(data["low"], size);
    double open = getY(data["open"], size);
    double close = getY(data["close"], size);
    double r = candleWidth * scale / 2;
    double lineR = candleLineWidth * scale / 2;

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

  drawDashLine(Canvas canvas, Size size) {
    _paint.color = Colors.grey[300];
    var maxWidth = size.width - 10;
    var maxHeight = size.height - 10;
    var dashWidth = 5;
    var dashSpace = 5;
    double x = 0;
    double y = 0;
    final space = (dashSpace + dashWidth);
    if (x < maxWidth) {
      while (x < maxWidth) {
        canvas.drawLine(Offset(x + dashSpace, size.height / 2),
            Offset(x + dashWidth + dashSpace, size.height / 2), _paint);
        x += space;
      }
    }
    if (y < maxHeight) {
      while (y < maxHeight) {
        canvas.drawLine(Offset(size.width / 2, y + dashSpace),
            Offset(size.width / 2, y + dashWidth + colMaxWidth), _paint);
        y += space;
      }
    }
  }

  drawLeftText(Canvas canvas, Size size) {
    double midValue = (maxValue + minValue) / 2;
    TextStyle style = TextStyle(color: Colors.grey, fontSize: leftFontSize);
    TextSpan span = TextSpan(text: maxValue.toStringAsFixed(2), style: style);
    TextSpan span2 = TextSpan(text: minValue.toStringAsFixed(2), style: style);
    TextSpan span3 = TextSpan(text: midValue.toStringAsFixed(2), style: style);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    TextPainter tp2 =
        TextPainter(text: span2, textDirection: TextDirection.ltr);
    TextPainter tp3 =
        TextPainter(text: span3, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
    tp2.layout();
    tp2.paint(canvas, Offset(2, size.height - 15));
    tp3.layout();
    tp3.paint(canvas, Offset(2, size.height / 2 - 15));
  }

  drawTopText(Canvas canvas, Size size) {
    Map data;

    if (isLongPress && selectedMap != null) {
      data = selectedMap;
    } else {
      data = datas.last;
    }
    double ma5 = data["ma5"];
    double ma10 = data["ma10"];
    double ma30 = data["ma30"];
    double fontSize = topFontSize;
    TextSpan span1 = TextSpan(
        text: "MA5:" + ma5.toStringAsFixed(2) + "  ",
        style: TextStyle(color: kValue1Color, fontSize: fontSize));
    TextSpan span2 = TextSpan(
        text: "MA10:" + ma10.toStringAsFixed(2) + "  ",
        style: TextStyle(color: kValue2Color, fontSize: fontSize));
    TextSpan span3 = TextSpan(
        text: "MA30:" + ma30.toStringAsFixed(2) + "  ",
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
    tp.paint(canvas, Offset(2, size.height - 20));
    tp2.layout();
    tp2.paint(canvas, Offset(size.width - tp2.width, size.height - 20));
  }

  getY(double value, Size size) {
    double d = maxValue - minValue;
    double currentD = value - minValue;
    double p = 1 - currentD / d;
    return size.height * p;
  }

  getMaxMin(Size size, int count, int index) {
    // if (isLongPress) return;
    maxValue = 0;
    minValue = double.infinity;
    for (var i = 0; i < count; i++) {
      Map m = datas[index + i];
      if (maxValue < m["high"]) {
        maxValue = m["high"];
      }
      if (maxValue < m["ma5"]) {
        minValue = m["ma5"];
      }
      if (maxValue < m["ma10"]) {
        maxValue = m["ma10"];
      }
      if (maxValue < m["ma20"]) {
        maxValue = m["ma20"];
      }
      if (maxValue < m["ma30"]) {
        maxValue = m["ma30"];
      }

      if (minValue > m["low"]) {
        minValue = m["low"];
      }
      if (minValue > m["ma5"]) {
        minValue = m["ma5"];
      }
      if (minValue > m["ma10"]) {
        minValue = m["ma10"];
      }
      if (minValue > m["ma20"]) {
        minValue = m["ma20"];
      }
      if (minValue > m["ma30"]) {
        minValue = m["ma30"];
      }
    }
  }

  drawCrossLine(Canvas canvas, Size size, int count, int beginIndex, double x) {
    Paint _paint = new Paint()
      ..color = crossLineColor
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = true
      ..strokeWidth = crossLineWidth
      ..style = PaintingStyle.stroke;

    int index = getIndex(x, size, count);
    double y = getY(datas[index + beginIndex]["close"], size);
    onSelected(datas[index + beginIndex]);
    selectedMap = datas[index + beginIndex];
    double pwidth = candleSpace * scale;
    double sx = index * pwidth + pwidth / 2;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), _paint);
    _paint.color = dotColor;
    _paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sx, y), 3.0, _paint);

    //画选中价格框和价格text
    _paint
      ..color = timePriceMarkColor
      ..style = PaintingStyle.fill;
    TextSpan span = TextSpan(
        text: "${datas[index + beginIndex]["close"]}",
        style: TextStyle(color: timePriceTextColor, fontSize: bottomFontSize));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    double cWidth = tp.width + 10;
    double cHeight = 16;
    Rect rect;
    if (sx < size.width / 2) {
      rect = Rect.fromCenter(
          center: Offset(size.width - cWidth / 2, y),
          width: cWidth,
          height: cHeight);
    } else {
      rect = Rect.fromCenter(
          center: Offset(cWidth / 2, y), width: cWidth, height: cHeight);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(8)), _paint);

    tp.paint(
        canvas,
        Offset(rect.left + (cWidth - tp.width) / 2,
            rect.top + (cHeight - tp.height) / 2));

    if (showDate) {
      String time = datas[index + beginIndex]["date"];
      TextSpan span = TextSpan(
          text: time,
          style:
              TextStyle(color: timePriceTextColor, fontSize: bottomFontSize));
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      double cWidth = tp.width + 10;
      double cHeight = 16;
      Rect rect = Rect.fromCenter(
          center: Offset(sx, size.height + 10), width: cWidth, height: cHeight);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(8)), _paint);

      tp.paint(
          canvas,
          Offset(rect.left + (cWidth - tp.width) / 2,
              rect.top + (cHeight - tp.height) / 2));
    }
  }

  int getIndex(double x, Size size, int count) {
    double pwidth = candleSpace * scale;
    int index = x ~/ pwidth - 1;
    if (index > count - 1) {
      index = count - 1;
    }
    if (index < 0) {
      index = 0;
    }
    return index;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
