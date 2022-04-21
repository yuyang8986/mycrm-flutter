import 'package:flutter/material.dart';

class CustomInheritedWidget extends InheritedWidget {
   CustomInheritedWidget({
      Key key,
      @required Widget child,
      this.data,
   }): super(key: key, child: child);
	
   final data;
	
   static CustomInheritedWidget of(BuildContext context) {
      return context.inheritFromWidgetOfExactType(CustomInheritedWidget);
   }

   @override
   bool updateShouldNotify(CustomInheritedWidget oldWidget) => data != oldWidget.data;
}