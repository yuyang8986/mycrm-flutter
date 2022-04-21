import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class MyPieChart extends StatelessWidget {
  List<charts.Series> seriesList;
  bool animate;

  MyPieChart(this.seriesList, {this.animate});

  // factory MyPieChart.withSampleData() {
  //   return new MyPieChart(
  //     _createSampleData(),
  //     animate: true,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        animationDuration: Duration(milliseconds: 700),
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 60,
            arcRendererDecorators: [new charts.ArcLabelDecorator()]
            // )
            ));
  }

  // static List<charts.Series<LinearSales, int>> _createSampleData() {
  //   final data = [
  //     new LinearSales(0, 100, Colors.red[400]),
  //     new LinearSales(1, 75, Colors.green[500]),
  //     new LinearSales(2, 50, Colors.yellow)
  //   ];

  //   return [
  //     new charts.Series<LinearSales, int>(
  //       id: 'Sales',
  //       domainFn: (LinearSales sales, _) => sales.index,
  //       measureFn: (LinearSales sales, _) => sales.sales,
  //       data: data,
  //       colorFn: (LinearSales sales, _) => sales.color,
  //     )
  //   ];
  // }

}

class LinearSales {
  final int index;
  final int sales;
  charts.Color color;

  LinearSales(this.index, this.sales, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
