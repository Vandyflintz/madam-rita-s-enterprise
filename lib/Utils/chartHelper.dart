import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';

import '../products_model.dart';


class MyBarChart extends StatelessWidget {
  final List<List<double>> dataRows;
  final List<String> xUserLabels;
  final List<String> dataRowsLegends;
  final List<Color> colors;

  MyBarChart({
    required this.dataRows,
    required this.xUserLabels,
    required this.dataRowsLegends,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return VerticalBarChart(
      painter: VerticalBarChartPainter(
        verticalBarChartContainer: VerticalBarChartTopContainer(
          chartData: ChartData(
            dataRows: dataRows,
            xUserLabels: xUserLabels,
            dataRowsLegends: dataRowsLegends,
            chartOptions: ChartOptions(),
          ),
        ),
      ),
    );
  }


}