import 'package:flutter/material.dart';
import 'hb_chart_config.dart';

class HBVolPainter extends CustomPainter {
  final List datas; //数据
  final int maxValue; //最大值
  final double selectedX; //选中后X偏移
  final bool isLongPress; //是否长按
  final Function onSelected; //长按回调
  final bool showBorder;
  final bool showTime;
  HBVolPainter({
    this.selectedX,
    this.isLongPress,
    this.maxValue,
    this.onSelected,
    this.showBorder = true,
    this.showTime = true,
    @required this.datas,
  });

  Paint _paint = new Paint()
    ..color = Colors.grey
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

    Size chartSize = Size(size.width, size.height - 20);
    if (showTime) {
      chartSize = Size(size.width, size.height - 40);
      //画日期
      drawDate(canvas, chartSize);
    }

    if (showBorder)
      //画边框
      drawBorder(canvas, chartSize);
    //左侧最高交易量
    drawLeftText(canvas, chartSize);
    //画虚线
    drawDashLine(canvas, chartSize);
    //画交易量
    drawChart(canvas, chartSize, datas);
    //如果长按
    if (isLongPress) {
      //交叉线
      drawCrossLine(canvas, chartSize, datas, selectedX);
    }
    canvas.restore();
    drawTopText(canvas, size);
  }

  //画边框
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

  drawChart(Canvas canvas, Size size, List data) {
    double pwidth = size.width / lineChartCount;
    for (var i = 0; i < data.length; i++) {
      bool upDown = data[i]["upDown"];
      _paint.color = upDown ? upColor : dnColor;
      double x = pwidth * i;
      double y = getY(data[i]["vol"], size);
      double endY = size.height;
      if (pwidth > colMaxWidth) {
        pwidth = colMaxWidth;
      }
      _paint.style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromPoints(Offset(x, y), Offset(x + pwidth, endY)), _paint);
      // canvas.drawLine(Offset(x, y), Offset(x, endY), _paint);
      if (i == data.length - 2) {
        break;
      }
    }
  }

  drawCrossLine(Canvas canvas, Size size, List data, double x) {
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
    int index = getIndex(x, size, data);
    String time = data[index]["time"];
    onSelected(data[index]);
    selectedMap = data[index];
    double pwidth = size.width / lineChartCount;
    if (pwidth > colMaxWidth) {
      pwidth = colMaxWidth;
    }
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
    if (isLongPress && selectedMap != null) {
      data = selectedMap;
    } else {
      data = datas.last;
    }
    int vol = data["vol"];
    double fontSize = topFontSize;
    TextSpan span1 = TextSpan(
        text: "交易量:" + vol.toString() + "  ",
        style: TextStyle(color: currentPriceColor, fontSize: fontSize));

    TextPainter tp = TextPainter(text: span1, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(2, 2));
  }

  drawLeftText(Canvas canvas, Size size) {
    TextSpan span = TextSpan(
        text: "$maxValue",
        style: TextStyle(color: Colors.grey, fontSize: leftFontSize));
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

    double y = size.height;
    tp.layout();
    tp.paint(canvas, Offset(0, y));
    tp2.layout();
    tp2.paint(canvas, Offset(size.width / 2 - tp2.width / 2, y));
    tp3.layout();
    tp3.paint(canvas, Offset(size.width - tp3.width, y));
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

  double getY(int value, Size size) {
    return size.height * (1 - (value / maxValue));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return true;
  }
}
