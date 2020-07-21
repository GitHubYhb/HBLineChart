import 'package:flutter/material.dart';
import 'hb_chart_config.dart';

class HBMinuteLinePainter extends CustomPainter {
  final List datas;
  final double maxValue; //最大值
  final double minValue; //最小值
  final double selectedX;
  final bool isLongPress;
  final bool showTime;
  final bool showBorder;
  final Function onSelected;
  HBMinuteLinePainter({
    this.selectedX,
    this.isLongPress,
    this.onSelected,
    this.maxValue,
    this.showTime = true,
    this.showBorder = true,
    this.minValue,
    @required this.datas,
  });
  Paint _paint = new Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  Paint _avePaint = new Paint()
    ..color = aveColor
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  Map selectedMap;

  @override
  void paint(Canvas canvas, Size size) {
    if (datas.length <= 0) {
      return;
    }
    canvas.save();
    canvas.translate(0, 20);
    _paint.color = Colors.grey[300];

    Size newSize = Size(size.width, size.height - 20);
    if (showTime) {
      newSize = Size(size.width, size.height - 40);
      drawDate(canvas, size);
    }
    if (showBorder) {
      //画边框
      drawBorder(canvas, newSize);
    }

    //画虚线
    drawDashLine(canvas, newSize);

    //画分时线
    drawLineChart(canvas, newSize);
    //画左侧文字
    drawLeftText(canvas, newSize);
    if (isLongPress) {
      drawCrossLine(canvas, newSize, selectedX ?? 0);
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

  drawDashLine(Canvas canvas, Size size) {
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

  drawLineChart(Canvas canvas, Size size) {
    _paint.color = Colors.black;

    double pwidth = size.width / lineChartCount;
    if (pwidth > colMaxWidth) {
      pwidth = colMaxWidth;
    }
    Path path = Path();
    Path avePath = Path();
    for (var i = 0; i < datas.length; i++) {
      double x = pwidth * i + pwidth / 2;
      double y = getY(datas[i]["price"], size);
      double aveY = getY(datas[i]["ave"], size);

      if (i == 0) {
        path.moveTo(x, y);
        avePath.moveTo(x, aveY);
      } else {
        path.lineTo(x, y);
        avePath.lineTo(x, aveY);
      }
    }
    canvas.drawPath(path, _paint);
    canvas.drawPath(avePath, _avePaint);
  }

  drawLeftText(Canvas canvas, Size size) {
    double midValue = (maxValue + minValue) / 2;
    double fontSize = leftFontSize;
    TextSpan span = TextSpan(
        text: "$maxValue",
        style: TextStyle(color: upColor, fontSize: fontSize));
    TextSpan span2 = TextSpan(
        text: "$minValue",
        style: TextStyle(color: dnColor, fontSize: fontSize));
    TextSpan span3 = TextSpan(
        text: midValue.toStringAsFixed(2),
        style: TextStyle(color: Colors.grey, fontSize: fontSize));
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
    double price = data["price"];
    double ave = data["ave"];

    double fontSize = topFontSize;
    TextSpan span1 = TextSpan(
        text: "现价:" + price.toStringAsFixed(2) + "   ",
        style: TextStyle(color: currentPriceColor, fontSize: fontSize));
    TextSpan span2 = TextSpan(
        text: "均价:" + ave.toStringAsFixed(2) + "   ",
        style: TextStyle(color: avePriceColor, fontSize: fontSize));

    TextSpan span = TextSpan(children: [span1, span2]);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }

  drawDate(Canvas canvas, Size size) {
    TextStyle style = TextStyle(color: Colors.grey, fontSize: bottomFontSize);

    TextSpan span = TextSpan(text: "20:00", style: style);
    TextSpan span2 = TextSpan(text: "02:30|09:00", style: style);
    TextSpan span3 = TextSpan(text: "15:30", style: style);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    TextPainter tp2 =
        TextPainter(text: span2, textDirection: TextDirection.ltr);
    TextPainter tp3 =
        TextPainter(text: span3, textDirection: TextDirection.ltr);

    double y = size.height - 15;
    tp.layout();
    tp.paint(canvas, Offset(0, y));
    tp2.layout();
    tp2.paint(canvas, Offset(size.width / 2 - tp2.width / 2, y));
    tp3.layout();
    tp3.paint(canvas, Offset(size.width - tp3.width, y));
  }

  drawCrossLine(Canvas canvas, Size size, double x) {
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
    int index = getIndex(x, size, datas);

    double y = getY(datas[index]["price"], size);
    onSelected(datas[index]);
    selectedMap = datas[index];
    double pwidth = size.width / lineChartCount;
    if (pwidth > colMaxWidth) {
      pwidth = colMaxWidth;
    }
    double sx = index * pwidth + pwidth / 2;
    if (y < 0) {
      y = 0;
    }
    if (y > size.height) {
      y = size.height;
    }

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
        text: "${datas[index]["price"]}",
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

    if (showTime) {
      int index = getIndex(x, size, datas);
      String time = datas[index]["time"];
      //画选中时间框和时间text
      _paint
        ..color = timePriceMarkColor
        ..style = PaintingStyle.fill;

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

  int getIndex(double x, Size size, List data) {
    double pwidth = size.width / lineChartCount;
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

  double getY(double value, Size size) {
    // print(value);
    // 最高的时候 y = 0 最低的时候 y = 1
    //  401.25 - 398.9 = n
    //  400.68 - 398.9 = x
    // x/n 百分比
    // 翻转 1-百分比 * 高度
    double d = maxValue - minValue;
    double currentD = value - minValue;
    double p = 1 - currentD / d;
    return size.height * p;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return true;
  }
}
