import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycrm/Pages/PaymentPage/SubscriptionPurchasePage.dart';
import 'package:mycrm/Pages/Pipeline/PipelineListPage.dart';
import 'package:mycrm/Pages/contact/CompanyAddPage.dart';
import 'package:mycrm/Pages/contact/CompanyEditPage.dart';
import 'package:mycrm/Pages/contact/ContactMainPage.dart';
import 'package:mycrm/Pages/contact/PeopleAddPage.dart';
import 'package:mycrm/Pages/MainPage.dart';
import 'package:mycrm/Pages/Stage/StageDetail.dart';
import 'package:mycrm/Pages/contact/PeopleEditPage.dart';
import 'package:mycrm/Services/NotificationService/NotificationService.dart';
import 'package:mycrm/env.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';
import './Pages/Register/RegisterPage.dart';
import './Pages/Dashboard/DashboardPage.dart';
import './Pages/Stage/StageListPage.dart';
import './Services/service_locator.dart';
import 'Http/HttpRequest.dart';
import 'Models/Constants/Constants.dart';
import 'Pages/Activity/AddActivityPage.dart';
import 'Pages/PaymentPage/AccountInfoPage.dart';
import 'Pages/Pipeline/PipelineAddPage.dart';
import 'Pages/contact/CompanyDetailPage.dart';
import 'Pages/contact/Employee/EmployeeDetailPage.dart';
import 'Pages/contact/PeopleDetailPage.dart';
import 'Styles/AppColors.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:local_auth/local_auth.dart';

SharedPreferences sp;
PackageInfo packageInfo;
bool canCheckBiometrics;
List<BiometricType> availableBiometrics;
LocalAuthentication localAuthentication;

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  setupLocator();
  sp = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();
  localAuthentication = LocalAuthentication();
  canCheckBiometrics = await localAuthentication.canCheckBiometrics;
  // if (Platform.isIOS) {
  //   if (availableBiometrics.contains(BiometricType.face)) {
  //     // Face ID.
  //   } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
  //     // Touch ID.
  //   }
  // }
  StripePayment.setOptions(
      StripeOptions(publishableKey: "pk_live_ZIMREnYhkkFPYEwRazMFVjGH00AEXtXFS6"
          //merchantId: "Test",
          //androidPayMode: 'test'
          ));

  var token = sp.getString("token");
  print(token);
  if (token != null) {
    HttpRequest.token = token;
    try {
      HttpRequest.appUser = await HttpRequest.fetchAppUserLiveData();
    } catch (e) {
      HttpRequest.appUser = null;
    }
  } else {
    // WidgetsBinding.instance.addPostFrameCallback((_)async{

    //);
  }
  // StripePayment.setOptions(StripeOptions(
  //   publishableKey: "pk_test_194pxhRSJ8jifbP8Mx6yJVa100wUpNMt8H",
  // ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static bool isOfflineMode = false;

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isInit;
  @override
  void initState() {
    isInit = true;
    super.initState();
  }

  bool darkMode;

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      NotificationService.init(context);
      darkMode = sp.getBool("darkMode");
      // FirebaseApp.initializeApp(this);
      isInit = false;
    }

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (b) => ThemeData(
        brightness: b,
        cardTheme: CardTheme(elevation: 5),

        primaryColor: darkMode ?? false
            ? AppColors.primaryColorDark
            : AppColors.primaryColorNormal,
        primaryColorLight: darkMode ?? false
            ? AppColors.primaryColorDarkLight
            : AppColors.primaryColorNormalLight,
        primaryColorDark: AppColors.primaryColorDarkDark,
        // fontFamily: 'OpenSans',
        tabBarTheme: TabBarTheme(
            labelStyle: TextStyle(
                letterSpacing: .6,
                fontWeight: FontWeight.bold,
                fontFamily: "QuickSand")),
        // backgroundColor: Colors.white38,
        primaryTextTheme: TextTheme(
            title: TextStyle(fontFamily: 'QuickSand'),
            button: TextStyle(color: AppColors.normalTextColor)),
        //accentColor: Colors.pink,
        textTheme: TextTheme(
                body1: TextStyle(fontFamily: "QuickSand"),
                body2: TextStyle(fontFamily: "QuickSand"),
                caption: TextStyle(fontFamily: "QuickSand"),
                display1: TextStyle(fontFamily: "QuickSand"),
                headline: TextStyle(fontFamily: "QuickSand"),
                display2: TextStyle(fontFamily: "QuickSand"),
                display3: TextStyle(fontFamily: "QuickSand"),
                display4: TextStyle(fontFamily: "QuickSand"),
                overline: TextStyle(fontFamily: "QuickSand"),
                subhead: TextStyle(fontFamily: "QuickSand"),
                subtitle: TextStyle(fontFamily: "QuickSand"),
                title: TextStyle(fontFamily: 'QuickSand'),
                button: TextStyle(color: AppColors.normalTextColor))
            .apply(fontFamily: "QuickSand"),
        //fontFamily: 'OpenSans',
        // textTheme: Theme.of(context).textTheme.apply(
        //         fontFamily: 'Open Sans',
        //         bodyColor: Colors.white,
        //         displayColor: Colors.white
        //         ),
        // primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
            actionsIconTheme: IconThemeData(color: Colors.white),
            textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold))),
        //buttonColor: Color.fromRGBO(103, 44, 59, 1),
        buttonTheme: ButtonThemeData(
            buttonColor: AppColors.primaryColorNormal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textTheme: ButtonTextTheme.primary),

        bottomSheetTheme: BottomSheetThemeData(
            elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      ),
      themedWidgetBuilder: (ctx, theme) {
        return MaterialApp(
          home: Scaffold(
            body: MainPage(),
          ),
          theme: theme,
          //initialRoute: '/',
          routes: {
            //Routes.loginPage: (context) => LoginPage(),
            Routes.registerPage: (context) => RegisterPage(),
            Routes.mainPage: (context) => MainPage(),
            Routes.dashboardPage: (context) => DashboardPage(),
            Routes.pipelineListPage: (context) => PipelineListPage(),
            Routes.pipelineaddPage: (context) => PipelineAddPage(),
            Routes.stageListPage: (context) => StageListPage(),
            //Routes.editStagePage: (context) => EditStagePage(),
            Routes.contactPage: (context) => ContactPage(),
            Routes.addPeoplePage: (context) => AddPeoplePage(),
            Routes.peopleEditPage: (context) => EditPeoplePage(),
            Routes.addCompanyPage: (context) => AddCompanyPage(),
            Routes.companyDetailPage: (context) => CompanyDetailPage(),
            Routes.companyEditPage: (context) => CompanyEditPage(),
            Routes.peopleDetailPage: (context) => PeopleDetailPage(),
            Routes.stageDetailPage: (context) => StageDetailPage(),
            //Routes.addStagePage: (context) => AddStagePage(),
            //Routes.errorPage: (context) => ErrorPage(),
            Routes.addActivityPage: (context) => AddActivityPage(),
            Routes.employeeDetailPage: (context) => EmployeeDetailPage(),
            //Routes.paymentPage:(context)=> PaymentPage(),
            Routes.accountPage: (context) => AccountInfoPage(),
            Routes.subscriptionPage: (context) => SubscriptionPurchasePage()
          },
        );
      },
    );
  }
}
