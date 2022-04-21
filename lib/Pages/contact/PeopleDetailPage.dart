import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mycrm/Styles/AppColors.dart';
import 'package:mycrm/generalWidgets/GeneralItemAppBar.dart';
import '../../Models/Core/Pipeline/Pipeline.dart';
import '../../Models/Core/contact/People.dart';
import 'package:mycrm/Infrastructure/TextHelper.dart' as Infras;

class PeopleDetailPage extends StatefulWidget {
  @override
  _PeopleDetailPageState createState() => _PeopleDetailPageState();
}

class _PeopleDetailPageState extends State<PeopleDetailPage> {
  People people;
  @override
  Widget build(BuildContext context) {
    people = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: GeneralAppBar(null, 'Person Info', null, null, null).create(),
      body: _peopleDetailContainer,
    );
  }

  Widget get _peopleDetailContainer {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.green,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: Text(
                  Infras.TextHelper.checkTextIfNullReturnEmpty(
                      '${people.firstName.isEmpty?"": people.firstName.toUpperCase().substring(0, 1)}'),
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                people.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Company: ' +
                      Infras.TextHelper.checkTextIfNullReturnEmpty(
                          people.company?.name),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              //subtitle: Text('contact(Test)'),
            ),
          ),
          people.pipelines == null
              ? Center(
                  child: Text('No Deals Data'),
                )
              : Expanded(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Email Address:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(Infras.TextHelper.checkTextIfNullReturnTBD(
                            people.email)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Email Address (Secondary):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(Infras.TextHelper.checkTextIfNullReturnTBD(
                            people.workEmail)),
                        Divider(),
                        Text(
                          'Contact Number:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(Infras.TextHelper.checkTextIfNullReturnTBD(
                            people.phone)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Contact Number (Secondary):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(Infras.TextHelper.checkTextIfNullReturnTBD(
                            people.workPhone)),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Deals:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: people.pipelines?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return _pipelineCard(people.pipelines[index]);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _pipelineCard(Pipeline pipeline) {
    return Card(
      child: Container(
        //constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(160),),
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.only(left: 10),
        //color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setWidth(800)),
                  child: Text(
                    'Deal Name: ${pipeline.dealName}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(40)),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints:
                      BoxConstraints(maxWidth: ScreenUtil().setWidth(800)),
                  child: Text(
                    'Deal Amount: \$${pipeline.dealAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil().setSp(40)),
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Stage: ${pipeline.stage.name}',
                  style: TextStyle(fontSize: 14),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
