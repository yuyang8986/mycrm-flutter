import 'package:mycrm/Infrastructure/DateTimeHelper.dart';

class NextActivity {
  String name;
  DateTime startTime;

  NextActivity({this.name, this.startTime});

  factory NextActivity.fromJson(Map<String, dynamic> json) => new NextActivity(
        name: json["name"],
        startTime: DateTimeHelper.parseDotNetDateTimeToDart(json["startTime"]),
      );
}
