import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(          
          child: Container(
            height: 50,
            child:  Column(            
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
             //Image.asset('assets/logo/logo.png', scale: 2,),
             CircularProgressIndicator(
               //backgroundColor: Colors.grey,
               semanticsLabel: "Loading",
               strokeWidth: 5,
               valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
             )],
        ),
          )
         )
      ],
    );
  }
}
