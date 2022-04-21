import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateTime parseDotNetDateTimeToDart(String dateTime) {
    if (dateTime == null) return null;

    try {
      var date =
          DateTime.parse(dateTime.replaceFirst('T', ' ').substring(0, 19));
      return date;
    } catch (e) {
      return null;
    }
  }

  static String parseDateTimeToDateHHMM(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy hh:mm a');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

   static DateTime parseDateTimeFrom24To12(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy hh:mm');
    var result = df.format((dateTime));
    return DateFormat('dd-MMM-yyyy hh:mm').parse(result);
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

    static String parseDateTimeToDate(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static String parseDateTimeToYYMM(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('MMM yyyy');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

    static String parseDateTimeToHHMMOnly(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('hh:mm a');
    var result = df.format((dateTime));
    return result;
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static DateTime parseDateTimeToDateIgnoreHHMMSS(DateTime dateTime) {
    if (dateTime == null) return null;
    final df = new DateFormat('dd-MMM-yyyy');
    var result = df.format((dateTime));
    return df.parse(result);
    //dateTime.toString().substring(0,dateTime.toString().length-7);
  }

  static bool compareDatesIsSameDate(DateTime dateA, DateTime dateB)
  {
    if(dateA.day == dateB.day && dateA.month == dateB.month && dateA.year == dateB.year)    return true;
    return false;
  }
}
