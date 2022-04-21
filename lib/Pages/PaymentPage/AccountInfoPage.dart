import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycrm/Bloc/Account/AccountBloc.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Infrastructure/DateTimeHelper.dart';
import 'package:mycrm/Models/Dto/Payment/Payment.dart';
import 'package:mycrm/Pages/ChangePasswordPage/ChangePasswordPage.dart';
import 'package:mycrm/Pages/EditProfilePage/EditProfilePage.dart';
import 'package:mycrm/Pages/WebViewPage/WebViewPage.dart';
import 'package:mycrm/Services/DialogService/DialogService.dart';
import 'package:mycrm/Services/LoadingService/LoadingService.dart';
import 'package:mycrm/generalWidgets/Infrastructure/CustomStreamBuilder.dart';
import 'package:mycrm/generalWidgets/Infrastructure/VEmptyView.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../Register/ConfirmEmail.dart';
import 'SubscriptionPurchasePage.dart';

class AccountInfoPage extends StatefulWidget {
  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final AccountBloc accountBloc = AccountBloc();
  final GlobalKey<FormState> _loginFormKey = new GlobalKey<FormState>();
  String last4Digits;
  bool isloading;
  CustomPaymentIntentResult paymentIntentResult;
  TextEditingController accountsNoController = TextEditingController();
  String planSelected;

  @override
  void initState() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (HttpRequest.appUser.emailConfirmed == false) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      "For your account security, please confirm your email address."),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    new FlatButton(
                      child: new Text("OK"),
                      onPressed: () {
                        return startGetConfirmCodeRequest();
                      },
                    ),
                  ],
                );
              });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Account"),
        ),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: <Widget>[
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
                // VEmptyView(20),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(30),
                      top: ScreenUtil().setHeight(30),
                      bottom: ScreenUtil().setHeight(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Name: " + HttpRequest.appUser.companyName,
                        style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            !HttpRequest.appUser.isAdmin
                ? Container()
                : CustomStreamBuilder(
                    retryCallback: accountBloc.getAccountInfo,
                    stream: accountBloc.accountInfoStream,
                    builder: (ctx, asyncdata) {
                      var accountInfo = asyncdata.data as AccountInfoDto;
                      last4Digits = last4Digits ?? accountInfo.last4Digits;
                      accountsNoController.text =
                          accountsNoController.text.isEmpty
                              ? accountInfo.totalSubQuantity.toString()
                              : accountsNoController.text;
                      return Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // VEmptyView(20),
                            // VEmptyView(20),
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
                            Container(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(20),
                                  left: ScreenUtil().setWidth(30),
                                  bottom: ScreenUtil().setHeight(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Current Subscription: " +
                                            accountInfo.currentPlan,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(40)),
                                      ),
                                      WEmptyView(20),
                                      Container(
                                        height: ScreenUtil().setHeight(80),
                                        width: ScreenUtil().setWidth(350),
                                        child: RaisedButton(
                                          onPressed: () async {
                                            await showModalBottomSheet(
                                                builder: (ctx) {
                                                  return Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20)),
                                                          child: Text(
                                                            "Select A Plan",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            50)),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: <Widget>[
                                                            Container(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          900),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    planSelected =
                                                                        "Premium";
                                                                  });

                                                                  await handlePlanChange();
                                                                  //Navigator.pop(context);
                                                                },
                                                                child: Text(
                                                                    "Premium - \$8.99/Account/Month"),
                                                              ),
                                                            ),
                                                            Container(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          900),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    planSelected =
                                                                        "Advanced";
                                                                  });
                                                                  await handlePlanChange();
                                                                  //Navigator.pop(context);
                                                                },
                                                                child: Text(
                                                                    "Advanced - \$6.99/Account/Month"),
                                                              ),
                                                            ),
                                                            Container(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          900),
                                                              child:
                                                                  RaisedButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    planSelected =
                                                                        "Essential";
                                                                  });
                                                                  await handlePlanChange();
                                                                  //Navigator.pop(context);
                                                                },
                                                                child: Text(
                                                                    "Essential - \$4.99/Account/Month"),
                                                              ),
                                                            ),
                                                            VEmptyView(100),
                                                            RaisedButton(
                                                              color:
                                                                  Colors.blue,
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (ctx) {
                                                                  return WebViewPage(
                                                                      'https://www.dealo.app/pricing');
                                                                }));
                                                              },
                                                              child: Text(
                                                                  "Compare Plans"),
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
                                        ),
                                      ),
                                    ],
                                  ),

                                  (accountInfo.trialEnd?.isAfter(DateTimeHelper
                                                  .parseDateTimeFrom24To12(
                                                      DateTime.now())) ??
                                              false) &&
                                          accountInfo.cancelAt == null
                                      ? Column(
                                          children: <Widget>[
                                            VEmptyView(20),
                                            Text(
                                                "Free Trial End: ${DateTimeHelper.parseDateTimeToDate(accountInfo.nextBillingDate)}",
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(40)))
                                          ],
                                        )
                                      : Container(),

                                  accountInfo.trialEnd?.isAfter(DateTimeHelper
                                              .parseDateTimeFrom24To12(
                                                  DateTime.now())) ??
                                          false
                                      ? VEmptyView(30)
                                      : Container(),
                                  accountInfo.cancelAt != null
                                      ? Text(
                                          accountInfo.cancelAt != null
                                              ? "Current Subscription End: ${accountInfo.cancelAtPeriodEnd ?? false ? (DateTimeHelper.parseDateTimeToDate(accountInfo.nextBillingDate)) : (DateTimeHelper.parseDateTimeToDate(accountInfo.cancelAt))}"
                                              : "",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(40)))
                                      : Text(
                                          "Next Billing Date: " +
                                              DateTimeHelper
                                                  .parseDateTimeToDate(
                                                      accountInfo
                                                          .nextBillingDate),
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(40)),
                                        ),

                                  VEmptyView(30),
                                  // accountInfo.trialEnd !=null || accountInfo.cancelAt!=null
                                  //     ? Text("Due Amount: N/A")
                                  //     :
                                  Text(
                                    "Next Due Amount: \$" +
                                        accountInfo.dueAmount
                                            .toStringAsFixed(2)
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                  VEmptyView(20),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Accounts Activated/Total: " +
                                            (accountInfo.totalActiveAccounts
                                                    ?.toString() ??
                                                0) +
                                            "/" +
                                            accountInfo.totalSubQuantity
                                                .toString(),
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(40)),
                                      ),
                                      WEmptyView(20),
                                      Container(
                                        height: ScreenUtil().setHeight(80),
                                        width: ScreenUtil().setWidth(350),
                                        child: RaisedButton(
                                          onPressed: () async {
                                            // if (last4Digits == null) {
                                            //   Fluttertoast.showToast(
                                            //       msg: "Please set payment method first");
                                            //   return;
                                            // }
                                            await showModalBottomSheet(
                                                builder: (ctx) {
                                                  return Container(
                                                    width: ScreenUtil()
                                                        .setWidth(400),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          width: ScreenUtil()
                                                              .setWidth(400),
                                                          margin:
                                                              EdgeInsets.all(
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          20)),
                                                          child: Text(
                                                            "Set Quantity",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            50)),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Column(
                                                          children: <Widget>[
                                                            Container(
                                                                width: ScreenUtil()
                                                                    .setWidth(
                                                                        400),
                                                                child:
                                                                    TextField(
                                                                  inputFormatters: <
                                                                      TextInputFormatter>[
                                                                    WhitelistingTextInputFormatter
                                                                        .digitsOnly
                                                                  ],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  controller:
                                                                      accountsNoController,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                )),
                                                            VEmptyView(100),
                                                            RaisedButton(
                                                              color:
                                                                  Colors.blue,
                                                              onPressed:
                                                                  () async {
                                                                if (int.parse(
                                                                        accountsNoController
                                                                            .text) <
                                                                    accountInfo
                                                                        .totalActiveAccounts) {
                                                                  Fluttertoast.showToast(
                                                                      msg:
                                                                          "You are not allowed to change the quantity lower than the number of current active users",
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_LONG);
                                                                  return;
                                                                }

                                                                if ((accountInfo
                                                                        .trialEnd
                                                                        ?.isAfter(
                                                                            DateTimeHelper.parseDateTimeFrom24To12(DateTime.now())) ??
                                                                    false)) {
                                                                  if (int.parse(
                                                                          accountsNoController
                                                                              .text) >
                                                                      2) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Only 2 accounts are allowed in Free Trial");
                                                                    return;
                                                                  }
                                                                }

                                                                if (int.parse(
                                                                        accountsNoController
                                                                            .text) >
                                                                    99) {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Please contact us for subscription on more than 100 accounts");
                                                                  return;
                                                                }
                                                                var no = int.parse(
                                                                    accountsNoController
                                                                        .text);

                                                                DialogService()
                                                                    .showConfirm(
                                                                        context,
                                                                        "Are you sure to change the quantity of accounts to $no? (This will update your next bill, any new added quatity will be charged on next billing date.)",
                                                                        () async {
                                                                  Navigator.pop(
                                                                      context);
                                                                  LoadingService
                                                                      .showLoading(
                                                                          context);
                                                                  await accountBloc
                                                                      .changeAccountsNo(
                                                                          no);
                                                                  LoadingService
                                                                      .hideLoading(
                                                                          context);

                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Subscription Updated");

                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              },
                                                              child: Text(
                                                                  "Confirm"),
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
                                        ),
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
                                "PAYMENT METHOD",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                    fontWeight: FontWeight.bold),
                              ),
                              color: Colors.grey[300],
                            ),
                            // VEmptyView(20),
                            Container(
                              // width: 200,
                              constraints: BoxConstraints(
                                  minWidth: ScreenUtil().setWidth(400)),
                              padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(30),
                                top: ScreenUtil().setHeight(20),
                              ),
                              child: last4Digits == null
                                  ? RaisedButton(
                                      onPressed: () async {
                                        var savedPaymentMethod =
                                            await StripePayment
                                                .paymentRequestWithCardForm(
                                                    CardFormPaymentRequest());

                                        var paymentRequest = InitialPaymentDto(
                                          0.01,
                                          "initialcharge",
                                          savedPaymentMethod.id,
                                          accountInfo.email ?? "",
                                        );
                                        try {
                                          var result = await HttpRequest.post(
                                              (HttpRequest.baseUrl +
                                                  "/payment/card"),
                                              paymentRequest);
                                          if (result.statusCode == 200) {
                                            setState(() {
                                              paymentIntentResult =
                                                  new CustomPaymentIntentResult
                                                      .fromJson(result.data);
                                              last4Digits = paymentIntentResult
                                                  .last4Digits;
                                            });
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Update Card Failed, please check your card");
                                          }
                                          print(result);
                                        } catch (e) {
                                          DialogService()
                                              .show(context, "Invalid Card");
                                        }
                                      },
                                      child: Text("Add Card"),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        last4Digits == null
                                            ? Container()
                                            : Row(
                                                children: <Widget>[
                                                  Text(
                                                    "Card: XXXX-XXXX-XXXX-" +
                                                            last4Digits ??
                                                        "",
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)),
                                                  ),
                                                  WEmptyView(20),
                                                  Container(
                                                    height: ScreenUtil()
                                                        .setHeight(80),
                                                    width: ScreenUtil()
                                                        .setWidth(300),
                                                    child: RaisedButton(
                                                      onPressed: () async {
                                                        var savedPaymentMethod =
                                                            await StripePayment
                                                                .paymentRequestWithCardForm(
                                                                    CardFormPaymentRequest());

                                                        var paymentRequest =
                                                            InitialPaymentDto(
                                                                0.01,
                                                                "initialcharge",
                                                                savedPaymentMethod
                                                                    .id,
                                                                accountInfo
                                                                        .email ??
                                                                    "");
                                                        var result =
                                                            await HttpRequest.post(
                                                                (HttpRequest
                                                                        .baseUrl +
                                                                    "/payment/card"),
                                                                paymentRequest);
                                                        if (result.statusCode ==
                                                            200) {
                                                          setState(() {
                                                            // _paymentMethod =
                                                            //     savedPaymentMethod;
                                                            // paymentIntentResult =
                                                            //     new CustomPaymentIntentResult
                                                            //             .fromJson(
                                                            //         result
                                                            //             .data);
                                                            paymentIntentResult =
                                                                new CustomPaymentIntentResult
                                                                        .fromJson(
                                                                    result
                                                                        .data);
                                                            last4Digits =
                                                                paymentIntentResult
                                                                    .last4Digits;
                                                          });
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Update Card Failed, please check your card");
                                                        }
                                                        print(result);
                                                        // var result = await HttpRequest
                                                        //     .delete(HttpRequest
                                                        //             .baseUrl +
                                                        //         "/payment/detach");
                                                        // if (result.statusCode ==
                                                        //     200) {
                                                        //   setState(() {
                                                        //     accountInfo
                                                        //             .last4Digits =
                                                        //         null;
                                                        //     paymentIntentResult =
                                                        //         null;
                                                        //     last4Digits = null;
                                                        //   });
                                                        // } else {
                                                        //   Fluttertoast.showToast(
                                                        //       msg:
                                                        //           "Remove payment method failed");
                                                        // }
                                                      },
                                                      child: Text("Change"),
                                                    ),
                                                  )
                                                ],
                                              )
                                      ],
                                    ),
                            ),

                            accountInfo.cancelAt == null
                                ? Container(
                                    width: 200,
                                    constraints: BoxConstraints(
                                        minWidth: ScreenUtil().setWidth(400)),
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(30),
                                        top: ScreenUtil().setHeight(20),
                                        bottom: ScreenUtil().setHeight(20)),
                                    child: RaisedButton(
                                      child: Text("Cancel Subscription"),
                                      onPressed: () async {
                                        DialogService().showConfirm(context,
                                            "Warning: Are you sure to cancel the subscription? You can still access Dealo before next billing date",
                                            () async {
                                          await accountBloc.cancelSub();
                                          Fluttertoast.showToast(
                                              msg: "Subscription Cancelled");
                                          Navigator.pop(context);
                                          //HttpRequest.appUser = null;

                                          //MainPage.mainPageState.logOurAndMoveToLoginPage();
                                        });
                                      },
                                    ),
                                  )
                                : Container(
                                    constraints: BoxConstraints(
                                        minWidth: ScreenUtil().setWidth(400)),
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(30),
                                        top: ScreenUtil().setHeight(30),
                                        bottom: ScreenUtil().setHeight(20)),
                                    child: RaisedButton(
                                      child: Text("Re-Subscribe"),
                                      onPressed: () async {
                                        if (last4Digits == null) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Please add a paymethod first");
                                          return;
                                        }
                                        var subResult = await HttpRequest.put(
                                            (HttpRequest.baseUrl +
                                                "/subscription/resubscribe"),
                                            null);

                                        if (subResult.statusCode == 200) {
                                          //Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Subscription Activated, Thank you");
                                          await accountBloc.getAccountInfo();
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
            //VEmptyView(100),
            Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: ScreenUtil().setHeight(120),
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(30),
                      top: ScreenUtil().setHeight(30),
                      bottom: ScreenUtil().setHeight(20)),
                  child: Text(
                    "MY PROFILE",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(40),
                        fontWeight: FontWeight.bold),
                  ),
                  color: Colors.grey[300],
                ),
                Container(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      //confirmEmailBtn(context),
                      editProfilefBtn(context),
                      changePasswordBtn(context),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget changePasswordBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            constraints: BoxConstraints(minWidth: ScreenUtil().setWidth(400)),
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              top: ScreenUtil().setHeight(20),
            ),
            width: ScreenUtil().setWidth(450),
            child: RaisedButton(
              child: Text(
                "Change Password",
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangePasswordPage()));
              },
            )),
      ],
    );
  }

  Widget editProfilefBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            constraints: BoxConstraints(minWidth: ScreenUtil().setWidth(400)),
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              top: ScreenUtil().setHeight(20),
            ),
            width: 200,
            child: RaisedButton(
              child: Text(
                "Edit Profile",
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => EditProfilePage()));
              },
            )),
      ],
    );
  }

  Widget confirmEmailBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
            constraints: BoxConstraints(minWidth: ScreenUtil().setWidth(400)),
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(30),
              top: ScreenUtil().setHeight(20),
            ),
            width: 200,
            child: RaisedButton(
                child: Text(
                  "Confirm Email",
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  await startGetConfirmCodeRequest();
                })),
      ],
    );
  }

  Future startGetConfirmCodeRequest() async {
    String url = HttpRequest.baseUrl + "authentication/ConfirmEmail";
    try {
      print('start confirm email');
      await HttpRequest.get(url);
      Fluttertoast.showToast(msg: "Code sent, Please check your email");

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ConfirmEmailPage()));
    } catch (e) {
      if (e is DioError) {
        Fluttertoast.showToast(
            msg: "${e.response.data.toString()}",
            toastLength: Toast.LENGTH_LONG);
      } else {
        Fluttertoast.showToast(
            msg: "${e.toString()}", toastLength: Toast.LENGTH_LONG);
      }
    }
  }

  Future handlePlanChange() async {
    DialogService().showConfirm(context,
        "Are you sure to change your organization plan to $planSelected",
        () async {
      Navigator.pop(context);
      await accountBloc.changePlan(planSelected);
      HttpRequest.appUser = await HttpRequest.fetchAppUserLiveData();
      Navigator.pop(context);
    });
  }
}
