import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/Account/AccountBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Dto/Payment/Payment.dart';
import 'package:mycrm/Pages/WebViewPage/WebViewPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CustomPaymentIntentResult {
  // String status;
  // String paymentIntentId;
  // String paymentMethodId;
  //String clientSecret;
  String last4Digits;

  CustomPaymentIntentResult({this.last4Digits});

  factory CustomPaymentIntentResult.fromJson(Map<dynamic, dynamic> json) {
    return CustomPaymentIntentResult(
        // status: json['status'],
        // paymentIntentId: json['paymentIntentId'],
        //  paymentMethodId: json['paymentMethodId'],
        //clientSecret: json["clientSecret"],
        last4Digits: json["last4Digits"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //if (this.paymentIntentId != null) data['paymentIntentId'] = this.paymentIntentId;
    // if (this.status != null) data['status'] = this.status;
    //if (this.paymentMethodId != null) data['paymentMethodId'] = this.paymentMethodId;
    //if (this.clientSecret != null) data['clientSecret'] = this.clientSecret;
    if (this.last4Digits != null) data['last4Digits'] = this.last4Digits;

    return data;
  }
}

class SubscriptionPurchasePage extends StatefulWidget {
  @override
  _SubscriptionPurchasePageState createState() =>
      _SubscriptionPurchasePageState();
}

class _SubscriptionPurchasePageState extends State<SubscriptionPurchasePage> {
  AccountBloc accountBloc;
  PaymentMethod _paymentMethod;
  CustomPaymentIntentResult paymentIntentResult;
  String subId;
  final quantityController = TextEditingController();
  //String _error;
  //String _currentSecret = '';
  bool isInit;
  String planSelected;
  int quantity;
  @override
  void initState() {
    isInit = true;
    paymentIntentResult = new CustomPaymentIntentResult();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await DialogService().show(context,
          "Your Subscription has expired, please renew to continue using Dealo");
    });
  }

  calculateTotalAmount() {
    switch (planSelected) {
      case "Premium":
        return (quantity * 27.99).toStringAsFixed(2);
        break;
      case "Advanced":
        return (quantity * 18.99).toStringAsFixed(2);
        break;
      case "Essential":
        return (quantity * 9.99).toStringAsFixed(2);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      subId = ModalRoute.of(context).settings.arguments;
      accountBloc = AccountBloc(subId: subId);
      isInit = false;
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Subscription"),
        ),
        body: CustomStreamBuilder(
          retryCallback: accountBloc.getRenewInfo,
          stream: accountBloc.accountInfoStream,
          builder: (ctx, asyncdata) {
            var accountInfo = asyncdata.data as AccountInfoDto;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // VEmptyView(20),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(120),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Text(
                      "MY ORGANIZATION",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.grey[300],
                  ),
                  VEmptyView(10),
                  Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Name: " + accountInfo.companyName,
                          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                  VEmptyView(10),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(120),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Text(
                      "MY SUBSCRIPTION",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.grey[300],
                  ),
                  VEmptyView(20),
                  Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(10),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Current Subscription: " +
                              accountInfo.currentPlan.toString().substring(
                                  accountInfo.currentPlan
                                          .toString()
                                          .indexOf('.') +
                                      1),
                          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Subscription Ended Date: " +
                              DateTimeHelper.parseDateTimeToDate(
                                  accountInfo.nextBillingDate),
                          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                  VEmptyView(10),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(120),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Text(
                      "PAYMENT METHOD",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.grey[300],
                  ),
                  // VEmptyView(20),

                  Container(
                    constraints:
                        BoxConstraints(minWidth: ScreenUtil().setWidth(400)),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: accountInfo?.last4Digits == null &&
                            paymentIntentResult?.last4Digits == null
                        ? RaisedButton(
                            onPressed: () async {
                              var savedPaymentMethod = await StripePayment
                                  .paymentRequestWithCardForm(
                                      CardFormPaymentRequest());

                              var paymentRequest = InitialPaymentDto(
                                  0.01,
                                  "initialcharge",
                                  savedPaymentMethod.id,
                                  accountInfo.email ?? "",
                                  subscriptionId: subId);
                              var result = await HttpRequest.postWithoutToken(
                                  (HttpRequest.baseUrl + "/payment/card"),
                                  paymentRequest);
                              if (result.statusCode == 200) {
                                setState(() {
                                  _paymentMethod = savedPaymentMethod;
                                  paymentIntentResult =
                                      new CustomPaymentIntentResult.fromJson(
                                          result.data);
                                });
                              }

                              else{
                                Fluttertoast.showToast(msg: "Update Card Failed, please check your card");
                              }
                              print(result);
                            },
                            child: Text("Add Card"),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              accountInfo?.last4Digits == null &&
                                      paymentIntentResult?.last4Digits == null
                                  ? Container()
                                  : Row(
                                      children: <Widget>[
                                        Text(
                                          "Card: XXXX-XXXX-XXXX-" +
                                              (accountInfo.last4Digits ??
                                                  paymentIntentResult
                                                      ?.last4Digits ??
                                                  ""),
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(40)),
                                        ),
                                        WEmptyView(20),
                                        RaisedButton(
                                          onPressed: () async {
                                            var savedPaymentMethod =
                                                await StripePayment
                                                    .paymentRequestWithCardForm(
                                                        CardFormPaymentRequest());

                                            var paymentRequest =
                                                InitialPaymentDto(
                                                    0.01,
                                                    "initialcharge",
                                                    savedPaymentMethod.id,
                                                    accountInfo.email ?? "",
                                                    subscriptionId: subId);
                                            var result = await HttpRequest
                                                .postWithoutToken(
                                                    (HttpRequest.baseUrl +
                                                        "/payment/card"),
                                                    paymentRequest);
                                            if (result.statusCode == 200) {
                                              setState(() {
                                                _paymentMethod =
                                                    savedPaymentMethod;
                                                paymentIntentResult =
                                                    new CustomPaymentIntentResult
                                                        .fromJson(result.data);
                                              });
                                            }
                                            else
                                            {
                                              Fluttertoast.showToast(msg: "Update Card Failed, please check your card");
                                            }
                                            print(result);
                                            // var result = await HttpRequest
                                            //     .deleteWithOutToken(HttpRequest
                                            //             .baseUrl +
                                            //         "/payment/detach/$subId");
                                            // if (result.statusCode == 200) {
                                            //   setState(() {
                                            //     accountInfo.last4Digits = null;
                                            //     _paymentMethod = null;
                                            //     paymentIntentResult = null;
                                            //   });
                                            // } else {
                                            //   Fluttertoast.showToast(
                                            //       msg:
                                            //           "Remove payment method failed");
                                            // }
                                          },
                                          child: Text("Change"),
                                        )
                                      ],
                                    )
                            ],
                          ),
                  ),

                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(120),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Text(
                      "CHOOSED PLAN",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.grey[300],
                  ),
                  // VEmptyView(20),
                  Container(
                      constraints:
                          BoxConstraints(minWidth: ScreenUtil().setWidth(400)),
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30),
                          top: ScreenUtil().setHeight(30),
                          bottom: ScreenUtil().setHeight(20)),
                      child: planSelected == null
                          ? RaisedButton(
                              onPressed: () async {
                                await showModalBottomSheet(
                                    builder: (ctx) {
                                      return Container(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.all(
                                                  ScreenUtil().setWidth(20)),
                                              child: Text(
                                                "Select A Plan",
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(50)),
                                              ),
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(900),
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        planSelected =
                                                            "Premium";
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        "Premium - \$27.99/Account/Month"),
                                                  ),
                                                ),
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(900),
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        planSelected =
                                                            "Advanced";
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        "Advanced - \$18.99/Account/Month"),
                                                  ),
                                                ),
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(900),
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        planSelected =
                                                            "Essential";
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        "Essential - \$9.99/Account/Month"),
                                                  ),
                                                ),
                                                VEmptyView(100),
                                                Text(
                                                    "(All Prices includes GST)"),
                                                RaisedButton(
                                                  color: Colors.blue,
                                                  onPressed: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (ctx) {
                                                      return WebViewPage(
                                                          'https://www.dealo.app/pricing');
                                                    }));
                                                  },
                                                  child: Text("Compare Plans"),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    context: context);
                              },
                              child: Text("Set Plan"),
                            )
                          : Row(
                              children: <Widget>[
                                Text(planSelected ?? ""),
                                WEmptyView(20),
                                RaisedButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                        builder: (ctx) {
                                          return Container(
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.all(
                                                      ScreenUtil()
                                                          .setWidth(20)),
                                                  child: Text(
                                                    "Select A Plan",
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(50)),
                                                  ),
                                                ),
                                                Column(
                                                  children: <Widget>[
                                                    Container(
                                                      width: ScreenUtil()
                                                          .setWidth(900),
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            planSelected =
                                                                "Premium";
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                            "Premium - \$27.99/Account/Month"),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: ScreenUtil()
                                                          .setWidth(900),
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            planSelected =
                                                                "Advanced";
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                            "Advanced - \$18.99/Account/Month"),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: ScreenUtil()
                                                          .setWidth(900),
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            planSelected =
                                                                "Essential";
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                            "Essential - \$9.99/Account/Month"),
                                                      ),
                                                    ),
                                                    VEmptyView(100),
                                                    Text(
                                                        "(All Prices includes GST)"),
                                                    RaisedButton(
                                                      color: Colors.blue,
                                                      onPressed: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder: (ctx) {
                                                          return WebViewPage(
                                                              'https://www.dealo.app/pricing');
                                                        }));
                                                      },
                                                      child:
                                                          Text("Compare Plans"),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        context: context);
                                  },
                                  child: Text("Change"),
                                )
                              ],
                            )),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil().setHeight(120),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        top: ScreenUtil().setHeight(30),
                        bottom: ScreenUtil().setHeight(20)),
                    child: Text(
                      "QUANTITY",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.grey[300],
                  ),
                  // VEmptyView(20),
                  Container(
                      width: ScreenUtil().setWidth(500),
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(30),
                          top: ScreenUtil().setHeight(30),
                          bottom: ScreenUtil().setHeight(20)),
                      child: quantity == null
                          ? RaisedButton(
                              onPressed: () async {
                                await showModalBottomSheet(
                                    builder: (ctx) {
                                      return Container(
                                        width: ScreenUtil().setWidth(500),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: ScreenUtil().setWidth(500),
                                              margin: EdgeInsets.all(
                                                  ScreenUtil().setWidth(10)),
                                              child: Text(
                                                "Set Quantity",
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(50)),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Column(
                                              children: <Widget>[
                                                Container(
                                                    width: ScreenUtil()
                                                        .setWidth(400),
                                                    child: TextField(
                                                      inputFormatters: <
                                                          TextInputFormatter>[
                                                        WhitelistingTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      textAlign:
                                                          TextAlign.center,
                                                      controller:
                                                          quantityController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                    )),
                                                VEmptyView(100),
                                                RaisedButton(
                                                  color: Colors.blue,
                                                  onPressed: () {
                                                    if (int.parse(
                                                            quantityController
                                                                .text) >
                                                        99) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Please contact us for subscription on more than 100 accounts");
                                                      return;
                                                    }
                                                    setState(() {
                                                      quantity = int.parse(
                                                          quantityController
                                                              .text);
                                                    });

                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Confirm"),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    context: context);
                              },
                              child: Text("Set Quantity"),
                            )
                          : Row(
                              children: <Widget>[
                                Text(quantity?.toString() ?? ""),
                                WEmptyView(20),
                                RaisedButton(
                                  child: Text("Change"),
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                        builder: (ctx) {
                                          return Container(
                                            width: ScreenUtil().setWidth(500),
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(500),
                                                  margin: EdgeInsets.all(
                                                      ScreenUtil()
                                                          .setWidth(10)),
                                                  child: Text(
                                                    "Set Quantity",
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(50)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Column(
                                                  children: <Widget>[
                                                    Container(
                                                        width: ScreenUtil()
                                                            .setWidth(400),
                                                        child: TextField(
                                                          inputFormatters: <
                                                              TextInputFormatter>[
                                                            WhitelistingTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          textAlign:
                                                              TextAlign.center,
                                                          controller:
                                                              quantityController,
                                                          maxLength: 2,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                        )),
                                                    VEmptyView(100),
                                                    RaisedButton(
                                                      color: Colors.blue,
                                                      onPressed: () {
                                                        setState(() {
                                                          quantity = int.parse(
                                                              quantityController
                                                                  .text);
                                                        });

                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Confirm"),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        context: context);
                                  },
                                )
                              ],
                            )),

                  planSelected == null ||
                          quantity == null ||
                          (paymentIntentResult?.last4Digits == null &&
                              accountInfo.last4Digits == null)
                      ? Container()
                      : Container(
                          width: double.infinity,
                          height: ScreenUtil().setHeight(120),
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(30),
                              top: ScreenUtil().setHeight(30),
                              bottom: ScreenUtil().setHeight(20)),
                          child: Text(
                            "DUE AMOUNT",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(40),
                                fontWeight: FontWeight.bold),
                          ),
                          color: Colors.grey[300],
                        ),
                  // VEmptyView(20),
                  planSelected == null ||
                          quantity == null ||
                          (paymentIntentResult?.last4Digits == null &&
                              accountInfo.last4Digits == null)
                      ? Container()
                      : Container(
                          width: ScreenUtil().setWidth(400),
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(30),
                              top: ScreenUtil().setHeight(30),
                              bottom: ScreenUtil().setHeight(20)),
                          child:
                              Text("\$" + (calculateTotalAmount()).toString())),

                  //VEmptyView(200),
                  planSelected == null ||
                          quantity == null ||
                          (paymentIntentResult?.last4Digits == null &&
                              accountInfo.last4Digits == null)
                      ? Container()
                      : Container(
                          child: Center(
                            child: RaisedButton(
                              child: Text("Confirm Subcription"),
                              onPressed: () async {
                                // var result = await StripePayment
                                //     .confirmPaymentIntent(
                                //   PaymentIntent(
                                //     clientSecret:
                                //         paymentIntentResult.clientSecret,
                                //     paymentMethodId: _paymentMethod.id,
                                //   ),
                                // );

                                // if (result.status == "succeeded") {
                                var subcriptionDto = SubcriptionDto(
                                    _paymentMethod?.id,
                                    planSelected,
                                    quantity,
                                    subId);
                                var subResult = await HttpRequest.post(
                                    (HttpRequest.baseUrl +
                                        "/payment/subscribe"),
                                    subcriptionDto.toJson());

                                if (subResult.statusCode == 200) {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: "Subscription Updated");
                                  // HttpRequest.appUser =
                                  //     await HttpRequest.fetchAppUserLiveData();
                                }
                                print(subResult);
                                // }
                              },
                            ),
                          ),
                        ),
                  VEmptyView(50)
                ],
              ),
            );
          },
        ));
  }
}
