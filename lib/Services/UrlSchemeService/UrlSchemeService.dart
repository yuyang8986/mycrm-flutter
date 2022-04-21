import 'package:mycrm/Models/Constants/Constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlSchemeService {
  makePhoneCall(String phoneNumber) async {
    if (await canLaunch(UrlSchemes.phoneCall + phoneNumber)) {
      await launch(UrlSchemes.phoneCall + phoneNumber);
    } else {
      throw 'Could not launch ${UrlSchemes.phoneCall + phoneNumber}';
    }
  }

  sendSMS(String phoneNumber) async {
    if (await canLaunch(UrlSchemes.sms + phoneNumber)) {
      await launch(UrlSchemes.sms + phoneNumber);
    } else {
      throw 'Could not launch ${UrlSchemes.sms + phoneNumber}';
    }
  }

  sendEmail(String email) async {
    if (await canLaunch(UrlSchemes.mail + email)) {
      await launch(UrlSchemes.mail + email);
    } else {
      throw 'Could not launch ${UrlSchemes.sms + email}';
    }
  }
}
