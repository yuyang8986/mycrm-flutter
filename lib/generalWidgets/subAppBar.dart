import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustmizedAppBarBottom extends StatelessWidget implements PreferredSize {
  final String title;
  final Function saveButtonAction;
  CustmizedAppBarBottom(this.title, this.saveButtonAction);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(160),
      child: Material(
        elevation: 5,
        color: Colors.white,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(70),
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(
                    FontAwesomeIcons.arrowAltCircleLeft,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(52)),
              ),
              Container(
                //padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                height: ScreenUtil().setHeight(110),
                width: ScreenUtil().setWidth(110),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: IconButton(
                  icon: Icon(Icons.check, size: ScreenUtil().setWidth(60),),
                  onPressed: () async {
                    await saveButtonAction();
                  },
                  color: Colors.white,
                ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget get child => null;

  @override
  Size get preferredSize => const Size.fromHeight(55);
}
