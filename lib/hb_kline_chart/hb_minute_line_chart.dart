import 'package:flutter/material.dart';

import 'hb_minute_line_chart_painter.dart';
import 'hb_vol_chart_painter.dart';

class HBMinuteLineChart extends StatefulWidget {
  final List datas;
  final double width;
  final double minuteLineheight;
  final double volHeight;

  const HBMinuteLineChart(
      {Key key,
      @required this.datas,
      this.width = double.infinity,
      this.minuteLineheight = 300,
      this.volHeight = 200})
      : super(key: key);
  @override
  _HBMinuteLineChartState createState() => _HBMinuteLineChartState();
}

class _HBMinuteLineChartState extends State<HBMinuteLineChart> {
  double maxPrice = 0, minPrice = double.infinity;
  int maxVol = 0;
  double selectedX;
  bool isLongPressing = false;
  @override
  Widget build(BuildContext context) {
    getMinMax();
    double width = widget.width;
    if (width == double.infinity) {
      width = MediaQuery.of(context).size.width;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double offsetX = (screenWidth - width) / 2;
    return Column(
      children: <Widget>[
        GestureDetector(
          onLongPressStart: (details) {
            //长按开始
            isLongPressing = true;
            if (selectedX != details.globalPosition.dx - offsetX) {
              selectedX = details.globalPosition.dx - offsetX;
            }
            setState(() {});
          },
          onLongPressMoveUpdate: (details) {
            //长按更新
            if (selectedX != details.globalPosition.dx - offsetX) {
              selectedX = details.globalPosition.dx - offsetX;
            }
            if (details.globalPosition.dx - offsetX >= width) {
              selectedX = width;
            }
            setState(() {});
          },
          onLongPressEnd: (details) {
            //长按结束
            isLongPressing = false;
            setState(() {});
          },
          child: Container(
            width: width,
            height: widget.minuteLineheight,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: CustomPaint(
                painter: HBMinuteLinePainter(
                    showBorder: true,
                    showTime: false,
                    datas: widget.datas,
                    maxValue: maxPrice,
                    minValue: minPrice,
                    isLongPress: isLongPressing,
                    selectedX: selectedX,
                    onSelected: (value) {
                      // print(value);
                    })),
          ),
        ),
        GestureDetector(
          onLongPressStart: (details) {
            isLongPressing = true;
            if (selectedX != details.globalPosition.dx - offsetX) {
              selectedX = details.globalPosition.dx - offsetX;
            }
            setState(() {});
          },
          onLongPressMoveUpdate: (details) {
            if (selectedX != details.globalPosition.dx - offsetX) {
              selectedX = details.globalPosition.dx - offsetX;
            }
            if (details.globalPosition.dx - offsetX >= width) {
              selectedX = width;
            }
            setState(() {});
          },
          onLongPressEnd: (details) {
            isLongPressing = false;
            setState(() {});
          },
          child: Container(
            width: width,
            height: widget.volHeight,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: CustomPaint(
                painter: HBVolPainter(
                    datas: widget.datas,
                    maxValue: maxVol,
                    isLongPress: isLongPressing,
                    selectedX: selectedX,
                    onSelected: (value) {
                      // print(value);
                    })),
          ),
        )
      ],
    );
  }

  getMinMax() {
    if (maxPrice != 0 && minPrice != double.infinity && maxVol != 0) {
      //算过一次就行。不需要反复计算
      return;
    }
    for (var item in widget.datas) {
      if (maxPrice < item["price"]) {
        maxPrice = item["price"];
      }
      if (minPrice > item["price"]) {
        minPrice = item["price"];
      }
      if (maxVol < item["vol"]) {
        maxVol = item["vol"];
      }
    }
  }
}
