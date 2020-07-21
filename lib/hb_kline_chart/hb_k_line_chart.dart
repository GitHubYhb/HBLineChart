import 'package:flutter/material.dart';
import 'hb_chart_config.dart';
import 'hb_k_line_chart_painter.dart';
import 'hb_k_line_vol_chart_painter.dart';

class HBKLineChart extends StatefulWidget {
  final List datas;
  final double width;
  final double kLineheight;
  final double volHeight;

  const HBKLineChart(
      {Key key,
      @required this.datas,
      this.width = double.infinity,
      this.kLineheight = 300,
      this.volHeight = 200})
      : super(key: key);
  @override
  _HBKLineChartState createState() => _HBKLineChartState();
}

class _HBKLineChartState extends State<HBKLineChart> {
  double kSelectedX;
  double scrollX = 0.0;
  bool isLongPressing = false;
  bool kIsLongPressing = false;
  bool isScaling = false;
  bool isDraging = false;
  int typeListIndex = 0;
  double scale = 1.0;
  double lastScale = 1.0;
  List<HBKLineVolType> typeList = [
    HBKLineVolType.VOL,
    HBKLineVolType.MACD,
    HBKLineVolType.KDJ,
    HBKLineVolType.BOLL,
  ];

  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    if (width == double.infinity) {
      width = MediaQuery.of(context).size.width;
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double offsetX = (screenWidth - width) / 2;
    double maxScrollX =
        (widget.datas.length - (width ~/ candleSpace)) * candleSpace;
    return Column(
      children: <Widget>[
        GestureDetector(
          child: Container(
            width: widget.width,
            height: widget.kLineheight,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: CustomPaint(
                painter: HBKLinePainter(
                    scrollX: scrollX,
                    selectedX: kSelectedX,
                    isLongPress: kIsLongPressing,
                    scale: scale,
                    showDate: false,
                    showBorder: true,
                    datas: widget.datas,
                    onSelected: (m) {})),
          ),
          onHorizontalDragStart: (detail) {
            isDraging = true;
            //水平拖拽开始
          },
          onHorizontalDragUpdate: (detail) {
            if (isScaling == true) {
              return;
            }
            //水平拖拽更新
            scrollX = (detail.primaryDelta + scrollX).clamp(0.0, maxScrollX);
            setState(() {});
          },
          onHorizontalDragEnd: (detail) {
            //水平拖拽结束
            isDraging = false;
          },
          onLongPressStart: (details) {
            kIsLongPressing = true;
            if (kSelectedX != details.globalPosition.dx - offsetX) {
              kSelectedX = details.globalPosition.dx - offsetX;
            }
            if (details.globalPosition.dx >= width + offsetX) {
              kSelectedX = width + offsetX;
            }
            setState(() {});
          },
          onLongPressMoveUpdate: (details) {
            if (kSelectedX != details.globalPosition.dx - offsetX) {
              kSelectedX = details.globalPosition.dx - offsetX;
            }
            if (details.globalPosition.dx >= width + offsetX) {
              kSelectedX = width + offsetX;
            }
            setState(() {});
          },
          onLongPressEnd: (details) {
            kIsLongPressing = false;
            setState(() {});
          },
          onScaleStart: (_) {
            isScaling = true;
          },
          onScaleUpdate: (details) {
            if (isDraging || kIsLongPressing) return;
            scale = (lastScale * details.scale).clamp(0.5, 2.2);
            setState(() {});
          },
          onScaleEnd: (_) {
            isScaling = false;
            lastScale = scale;
          },
        ),
        GestureDetector(
          child: Container(
            width: widget.width,
            height: widget.volHeight,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: CustomPaint(
                painter: HBKLineVolPainter(
                    scale: scale,
                    showBorder: true,
                    showDate: true,
                    datas: widget.datas,
                    type: typeList[typeListIndex],
                    isLongPress: kIsLongPressing,
                    selectedX: kSelectedX,
                    scrollX: scrollX,
                    onSelected: (value) {})),
          ),
          onTap: () {
            typeListIndex++;
            if (typeListIndex >= typeList.length) {
              typeListIndex = 0;
            }
            setState(() {});
          },
          onHorizontalDragStart: (detail) {
            isDraging = true;
            //水平拖拽开始
          },
          onHorizontalDragUpdate: (detail) {
            if (isScaling == true) {
              return;
            }
            //水平拖拽更新
            scrollX = (detail.primaryDelta + scrollX).clamp(0.0, maxScrollX);
            setState(() {});
          },
          onHorizontalDragEnd: (detail) {
            //水平拖拽结束
            isDraging = false;
          },
          onLongPressStart: (details) {
            kIsLongPressing = true;
            if (kSelectedX != details.globalPosition.dx - 10) {
              kSelectedX = details.globalPosition.dx - 10;
            }
            if (details.globalPosition.dx - 10 >= width) {
              kSelectedX = width;
            }
            setState(() {});
          },
          onLongPressMoveUpdate: (details) {
            if (kSelectedX != details.globalPosition.dx - 10) {
              kSelectedX = details.globalPosition.dx - 10;
            }
            if (details.globalPosition.dx - 10 >= width) {
              kSelectedX = width;
            }
            setState(() {});
          },
          onLongPressEnd: (details) {
            kIsLongPressing = false;
            setState(() {});
          },
          onScaleStart: (_) {
            isScaling = true;
          },
          onScaleUpdate: (details) {
            if (isDraging || kIsLongPressing) return;
            scale = (lastScale * details.scale).clamp(0.5, 2.2);
            setState(() {});
          },
          onScaleEnd: (_) {
            isScaling = false;
            lastScale = scale;
          },
        )
      ],
    );
  }
}
