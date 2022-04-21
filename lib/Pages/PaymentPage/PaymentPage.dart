// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:mycrm/Http/HttpRequest.dart';
// import 'package:mycrm/Models/Dto/Payment/Payment.dart';
// import 'package:stripe_payment/stripe_payment.dart';
// import 'dart:io';

// class PaymentPage extends StatefulWidget {

//   final CreditCard creditCard;

//   PaymentPage({this.creditCard});
//   @override
//   _PaymentPageState createState() => new _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   //Token _paymentToken;
//   PaymentMethod _paymentMethod;
//   //String _error;
//   String _currentSecret = ''; //set this yourself, e.g using curl
//   PaymentIntentResult _paymentIntent;
//   CreditCard currentCard ;
//   //Source _source;

//   ScrollController _controller = ScrollController();

//   // final CreditCard testCard = CreditCard(
//   //   number: '4242424242424242',
//   //   expMonth: 12,
//   //   expYear: 21,
//   // );

//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   @override
//   initState() {
//     currentCard = widget.creditCard; 
//     super.initState();

//     StripePayment.setOptions(StripeOptions(
//       publishableKey: "pk_test_194pxhRSJ8jifbP8Mx6yJVa100wUpNMt8H",
//       //merchantId: "Test",
//       //androidPayMode: 'test'
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: new AppBar(
//         title: new Text('Billing Information'),
//         actions: <Widget>[
//           // IconButton(
//           //   icon: Icon(Icons.clear),
//           //   onPressed: () {
//           //     setState(() {
//           //       //_source = null;
//           //      // _paymentIntent = null;
//           //       //_paymentMethod = null;
//           //      // _paymentToken = null;
//           //     });
//           //   },
//           // )
//         ],
//       ),
//       body: ListView(
//         controller: _controller,
//         padding: const EdgeInsets.all(20),
//         children: <Widget>[
//           // RaisedButton(
//           //   child: Text("Create Source"),
//           //   onPressed: () {
//           //     StripePayment.createSourceWithParams(SourceParams(
//           //       card: testCard,
//           //       type: 'ideal',
//           //       amount: 1099,
//           //       currency: 'aud',
//           //       returnURL: 'example://stripe-redirect',
//           //     )).then((source) {
//           //       _scaffoldKey.currentState.showSnackBar(
//           //           SnackBar(content: Text('Received ${source.sourceId}')));
//           //       setState(() {
//           //         _source = source;
//           //       });
//           //     }).catchError(setError);
//           //   },
//           // ),
//           Divider(),
//           RaisedButton(
//             child: Text("Create Token with Card Form"),
//             onPressed: () async {
//               var createForm = await StripePayment.paymentRequestWithCardForm(
//                   CardFormPaymentRequest());
//               setState(() {
//                 _paymentMethod = createForm;
//               });
//               var paymentRequest =
//                   InitialPaymentDto(100, "dealo-subscription-monthly", createForm.id, HttpRequest.appUser.email);
//               var result = await HttpRequest.post(
//                   (HttpRequest.baseUrl + "/payment/charge"), paymentRequest);
//               if (result.statusCode == 200) {
//                 _currentSecret = result.data.toString();
//               }
//               print(result);
//               // StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
//               //     .then((paymentMethod) async{
//               //   _scaffoldKey.currentState.showSnackBar(
//               //       SnackBar(content: Text('Received ${paymentMethod.id}')));
//               //   setState(() {
//               //     _paymentMethod = paymentMethod;
//               //   });
//               // }).catchError(setError);
//             },
//           ),
//           // RaisedButton(
//           //   child: Text("Create Token with Card"),
//           //   onPressed: () {
//           //     StripePayment.createTokenWithCard(
//           //       testCard,
//           //     ).then((token) {
//           //       _scaffoldKey.currentState.showSnackBar(
//           //           SnackBar(content: Text('Received ${token.tokenId}')));
//           //       setState(() {
//           //         _paymentToken = token;
//           //       });

//           //       var paymentRequest = PaymentDto(
//           //           100, "dealo-subscription-monthly", _paymentToken.tokenId);
//           //       HttpRequest.post(
//           //               (HttpRequest.baseUrl + "/payment"), paymentRequest)
//           //           .then((r) => print(r));

//           //       //print(result);
//           //     }).catchError(setError);
//           //   },
//           // ),
//           // Divider(),
//           // RaisedButton(
//           //   child: Text("Create Payment Method with Card"),
//           //   onPressed: () {
//           //     StripePayment.createPaymentMethod(
//           //       PaymentMethodRequest(
//           //         card: testCard,
//           //       ),
//           //     ).then((paymentMethod) {
//           //       _scaffoldKey.currentState.showSnackBar(
//           //           SnackBar(content: Text('Received ${paymentMethod.id}')));
//           //       setState(() {
//           //         _paymentMethod = paymentMethod;
//           //       });
//           //     }).catchError(setError);
//           //   },
//           // ),
//           // RaisedButton(
//           //   child: Text("Create Payment Method with existing token"),
//           //   onPressed: _paymentToken == null
//           //       ? null
//           //       : () {
//           //           StripePayment.createPaymentMethod(
//           //             PaymentMethodRequest(
//           //               card: CreditCard(
//           //                 token: _paymentToken.tokenId,
//           //               ),
//           //             ),
//           //           ).then((paymentMethod) {
//           //             _scaffoldKey.currentState.showSnackBar(SnackBar(
//           //                 content: Text('Received ${paymentMethod.id}')));
//           //             setState(() {
//           //               _paymentMethod = paymentMethod;
//           //             });
//           //           }).catchError(setError);
//           //         },
//           // ),
//           //Divider(),
//           RaisedButton(
//             child: Text("Confirm Payment Intent"),
//             onPressed: _paymentMethod == null || _currentSecret == null
//                 ? null
//                 : () async {
//                     var result = await StripePayment.confirmPaymentIntent(
//                       PaymentIntent(
//                         clientSecret: _currentSecret,
//                         paymentMethodId: _paymentMethod.id,
//                       ),
//                     );

//                     if (result.status == "succeeded") {
//                       var subcriptionDto =
//                           SubcriptionDto(_paymentMethod.id, "premium", 10);
//                       var subResult = await HttpRequest.post(
//                           (HttpRequest.baseUrl + "/payment/subscribe"),
//                           subcriptionDto);
//                       print(subResult);
//                     }
//                   },
//           ),
//           // RaisedButton(
//           //   child: Text("Authenticate Payment Intent"),
//           //   onPressed: _currentSecret == null
//           //       ? null
//           //       : () {
//           //           StripePayment.authenticatePaymentIntent(
//           //                   clientSecret: _currentSecret)
//           //               .then((paymentIntent) {
//           //             _scaffoldKey.currentState.showSnackBar(SnackBar(
//           //                 content: Text(
//           //                     'Received ${paymentIntent.paymentIntentId}')));
//           //             setState(() {
//           //               _paymentIntent = paymentIntent;
//           //             });
//           //           }).catchError(setError);
//           //         },
//           // ),
//           // Divider(),
//           // RaisedButton(
//           //   child: Text("Native payment"),
//           //   onPressed: () {
//           //     if (Platform.isIOS) {
//           //       _controller.jumpTo(450);
//           //     }
//           //     StripePayment.paymentRequestWithNativePay(
//           //       androidPayOptions: AndroidPayPaymentRequest(
//           //         total_price: "1.20",
//           //         currency_code: "EUR",
//           //       ),
//           //       applePayOptions: ApplePayPaymentOptions(
//           //         countryCode: 'DE',
//           //         currencyCode: 'EUR',
//           //         items: [
//           //           ApplePayItem(
//           //             label: 'Test',
//           //             amount: '13',
//           //           )
//           //         ],
//           //       ),
//           //     ).then((token) {
//           //       setState(() {
//           //         _scaffoldKey.currentState.showSnackBar(
//           //             SnackBar(content: Text('Received ${token.tokenId}')));
//           //         _paymentToken = token;
//           //       });
//           //     }).catchError(setError);
//           //   },
//           // ),
//           // RaisedButton(
//           //   child: Text("Complete Native Payment"),
//           //   onPressed: () {
//           //     StripePayment.completeNativePayRequest().then((_) {
//           //       _scaffoldKey.currentState.showSnackBar(
//           //           SnackBar(content: Text('Completed successfully')));
//           //     }).catchError(setError);
//           //   },
//           // ),
//           //Divider(),
//           // Text('Current source:'),
//           // Text(
//           //   JsonEncoder.withIndent('  ').convert(_source?.toJson() ?? {}),
//           //   style: TextStyle(fontFamily: "Monospace"),
//           // ),
//           Divider(),
//           // Text('Current token:'),
//           // Text(
//           //   JsonEncoder.withIndent('  ').convert(_paymentToken?.toJson() ?? {}),
//           //   style: TextStyle(fontFamily: "Monospace"),
//           // ),
//           // Divider(),
//           Text('Current payment method:'),
//           Text(
//             JsonEncoder.withIndent('  ')
//                 .convert(_paymentMethod?.toJson() ?? {}),
//             style: TextStyle(fontFamily: "Monospace"),
//           ),
//           Divider(),
//           // Text('Current payment intent:'),
//           // Text(
//           //   JsonEncoder.withIndent('  ')
//           //       .convert(_paymentIntent?.toJson() ?? {}),
//           //   style: TextStyle(fontFamily: "Monospace"),
//           // ),
//           // Divider(),
//           // Text('Current error: $_error'),
//         ],
//       ),
//     );
//   }
// }
