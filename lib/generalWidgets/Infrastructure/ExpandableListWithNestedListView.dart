import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ExpandableListWithNestListView extends StatefulWidget {
  final Widget header;
  final Widget expanded;

  ExpandableListWithNestListView(this.header, this.expanded);

  @override
  _ExpandableListWithNestListViewState createState() =>
      _ExpandableListWithNestListViewState();
}

class _ExpandableListWithNestListViewState
    extends State<ExpandableListWithNestListView> {
  final ExpandableController expandableController = ExpandableController();
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      controller: expandableController,
      child: ScrollOnExpand(
        scrollOnExpand: false,
        scrollOnCollapse: false,
        child: ExpandablePanel(
          controller: expandableController,
          header: widget.header,
          expanded: widget.expanded,
          tapHeaderToExpand: true,
        ),
      ),
    );
  }
}
