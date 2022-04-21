import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences sp;
  bool scheduleNotifications;
  bool darkMode;
  bool bioAuth;

  @override
  void initState() {
    //initSp();
    super.initState();
  }

  void changeBrightness() {
    DynamicTheme.of(context)
        .setBrightness(darkMode ? Brightness.dark : Brightness.light);
  }

  void changeColor() {
    DynamicTheme.of(context).setThemeData(new ThemeData(
      primaryColor: darkMode ?? false
          ? AppColors.primaryColorDark
          : AppColors.primaryColorNormal,
      primaryColorLight: darkMode ?? false
          ? AppColors.primaryColorDarkLight
          : AppColors.primaryColorNormalLight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Settings"),
        ),
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (ctx, data) {
            if (!data.hasData) return Container();
            sp = data.data;
            scheduleNotifications = sp.getBool("scheduleNotifications");
            darkMode = sp.getBool("darkMode");
            bioAuth = sp.getBool("enableBioAuth");
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                      width: double.infinity,
                      height: ScreenUtil().setHeight(150),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "Main",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(50),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                  SwitchListTile.adaptive(
                    onChanged: (v) {
                      setState(() {
                        if (!mounted) return;
                        scheduleNotifications = v;
                        sp.setBool("scheduleNotifications", v);
                      });
                    },
                    value: scheduleNotifications ?? false,
                    title: Text("Schedule Notifications"),
                  ),
                  SwitchListTile.adaptive(
                    onChanged: (v) {
                      if (!mounted) return;
                      setState(() {
                        darkMode = v;
                        sp.setBool("darkMode", v);
                        changeColor();
                        //changeBrightness();
                      });
                    },
                    value: darkMode ?? false,
                    title: Text("Dark Mode"),
                  ),
                  SwitchListTile.adaptive(
                    onChanged: (v) {
                      if (!mounted) return;
                      setState(() {
                        bioAuth = v;
                        sp.setBool("enableBioAuth", v);                        
                      });
                    },
                    value: bioAuth ?? false,
                    title: Text(
                        "${Platform.isAndroid ? "Fingerprint" : "Touch ID"}"),
                  )
                ],
              ),
            );
          },
        ));
  }
}
