import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class MyBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  MyBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  // factory MyBarChart.withSampleData() {
  //   return new MyBarChart(
  //     _createSampleData(),
  //     // Disable animations for image tests.
  //     animate: true,
  //   );
  // }

  // [BarLabelDecorator] will automatically position the label
  // inside the bar if the label will fit. If the label will not fit and the
  // area outside of the bar is larger than the bar, it will draw outside of the
  // bar. Labels can always display inside or outside using [LabelPosition].
  //
  // Text style for inside / outside can be controlled independently by setting
  // [insideLabelStyleSpec] and [outsideLabelStyleSpec].
  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      animationDuration: Duration(milliseconds: 800),
      vertical: false,
      // Set a bar label decorator.
      // Example configuring different styles for inside/outside:
      //       barRendererDecorator: new charts.BarLabelDecorator(
      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [
        new charts.SeriesLegend(
          // Positions for "start" and "end" will be left and right respectively
          // for widgets with a build context that has directionality ltr.
          // For rtl, "start" and "end" will be right and left respectively.
          // Since this example has directionality of ltr, the legend is
          // positioned on the right side of the chart.
          position: charts.BehaviorPosition.end,
          // For a legend that is positioned on the left or right of the chart,
          // setting the justification for [endDrawArea] is aligned to the
          // bottom of the chart draw area.
          outsideJustification: charts.OutsideJustification.endDrawArea,
          // By default, if the position of the chart is on the left or right of
          // the chart, [horizontalFirst] is set to false. This means that the
          // legend entries will grow as new rows first instead of a new column.
          horizontalFirst: false,
          // By setting this value to 2, the legend entries will grow up to two
          // rows before adding a new column.
          desiredMaxRows: 2,
          // This defines the padding around each legend entry.
          cellPadding: new EdgeInsets.only(right: 1.0, bottom: 1.0),
          // Render the legend entry text with custom styles.
          entryTextStyle: charts.TextStyleSpec(
              color: charts.Color(r: 12, g: 63, b: 91),
              fontFamily: 'QuickSand',
              fontWeight: "bold",
              fontSize: 20),
        )
      ],
      // Hide domain axis.
      // domainAxis:
      //     new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }

  /// Create one series with sample hard coded data.
  // static List<charts.Series<OrdinalSales, String>> _createSampleData() {
  //   final data = [
  //     new OrdinalSales('Q1', 5, 10),
  //     new OrdinalSales('Q2', 25, 10),
  //     new OrdinalSales('Q3', 100, 11),
  //     new OrdinalSales('Q4', 75, 120),
  //   ];

  //   return [
  //     new charts.Series<OrdinalSales, String>(
  //         id: 'Sales',
  //         domainFn: (OrdinalSales sales, _) => sales.quarter,
  //         // domainLowerBoundFn: (OrdinalSales sales, _) =>
  //         //     sales.target.toString(),
  //         // domainUpperBoundFn: (OrdinalSales sales, _) =>
  //         //     sales.achieved.toString(),
  //         measureFn: (OrdinalSales sales, _) => sales.achieved,
  //         data: data,
  //         // Set a label accessor to control the text of the bar label.
  //         labelAccessorFn: (OrdinalSales sales, _) =>
  //             '${sales.quarter}: \$${sales.target.toString()}')
  //   ];
  // }
}

class OrdinalSales {
  final String quarter;
  final double amount;

  OrdinalSales(this.quarter, this.amount);
}
