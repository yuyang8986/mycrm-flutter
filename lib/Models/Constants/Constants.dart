class Constants {
  static const String googleAPI = 'AIzaSyCckzWL2-PwMNGc1UnEnWCFu6JCHVgwit0';
  static const String fullContactAPI = '3i1xanLRUBydjsjE5FZCWGHrJOLPRNxN';

  static const identifier = "mycrm.console.password";
  static const secret = "secret";

  static const httpOk = "Request Succussful";
  static const httpNotAuthorized = "UnAuthorized";
  static const httpNotFound = "Not Found";
  static const httpUnexpected = "Unexpected Error";
  static const httpTokenExpired = "Token Expired";
  static const companyLocationTextMaxWidth = 150.0;
}

class Routes {
  static const String loginPage = '/';
  static const String registerPage = '/register';
  static const String mainPage = '/main';
  static const String dashboardPage = '/dashboard';
  static const String stageListPage = '/stage';
  static const String pipelineListPage = '/pipeline';
  static const String pipelineaddPage = '/pipeline/add';
  static const String contactPage = '/contact';
  static const String addPeoplePage = '/contact/people/add';
  static const String addCompanyPage = '/contact/company/add';
  static const String companyDetailPage = '/contact/company/detail';
  static const String peopleDetailPage = '/contact/people/detail';
  static const String employeeDetailPage = '/contact/employee/detail';
  static const String peopleEditPage = '/contact/people/edit';
  static const String companyEditPage = '/contact/company/edit';
  static const String addStagePage = '/stage/add';
  static const String editStagePage = '/stage/edit';
  static const String stageDetailPage = '/stage/detail';
  static const String errorPage = '/error';
  static const String addActivityPage = '/error';
  static const String paymentPage = '/paymentPage';
  static const String accountPage = '/accountPage';
  static const String subscriptionPage = '/subscriptionPage';



}

class NumbersInWords {
  static final Map<double, String> ones = {
    1: "one",
    2: "two",
    3: "three",
    4: "four",
    5: "five",
    6: "six",
    7: "seven",
    8: "eight",
    9: "nine",
  };

  static final Map<double, String> tens = {
    10: "ten",
    20: "twenty",
    30: "thirty",
    40: "forty",
    50: "fifty",
    60: "sixty",
    70: "seventy",
    80: "eighty",
    90: "ninety",
  };
  static final Map<double, String> teens = {
    11: "eleven",
    12: "twelve",
    13: "thirteen",
    14: "fourteen",
    15: "fifteen",
    16: "sixteen",
    17: "seventeen",
    18: "eighteen",
    19: "nineteen",
  };

  static final Map<double, String> hundred = {100: "hundred"};
  static final Map<double, String> thousand = {1000: "thousand"};
  static final Map<double, String> million = {1000000: "million"};
  //static final billion = {1000000000, "billion"};
}

class UrlSchemes {
  static const String phoneCall = 'tel:';
  static const String sms = 'sms:';
  static const String mail = 'mailto:';
}

enum PipelineCardDotsMenu {
  details,
  setToWon,
  setToLost,
  setToClose,
  editLead,
  deleteLead,
  changeAssignment
}

enum ShareOptionDotsMenu{
  email,
  sms,
  other
}

enum PipelineCardContactMenu { sms, call, email }

// enum PermissionGroup {
//   /// The unknown permission only used for return type, never requested
//   unknown,

//   /// Android: Calendar
//   /// iOS: Calendar (Events)
//   calendar,

//   /// Android: Camera
//   /// iOS: Photos (Camera Roll and Camera)
//   camera,

//   /// Android: Contacts
//   /// iOS: AddressBook
//   contacts,

//   /// Android: Fine and Coarse Location
//   /// iOS: CoreLocation (Always and WhenInUse)
//   location,

//   /// Android: Microphone
//   /// iOS: Microphone
//   microphone,

//   /// Android: Phone
//   /// iOS: Nothing
//   phone,

//   /// Android: Nothing
//   /// iOS: Photos
//   photos,

//   /// Android: Nothing
//   /// iOS: Reminders
//   reminders,

//   /// Android: Body Sensors
//   /// iOS: CoreMotion
//   sensors,

//   /// Android: Sms
//   /// iOS: Nothing
//   sms,

//   /// Android: External Storage
//   /// iOS: Nothing
//   storage,

//   /// Android: Microphone
//   /// iOS: Speech
//   speech,

//   /// Android: Fine and Coarse Location
//   /// iOS: CoreLocation - Always
//   locationAlways,

//   /// Android: Fine and Coarse Location
//   /// iOS: CoreLocation - WhenInUse
//   locationWhenInUse,

//   /// Android: None
//   /// iOS: MPMediaLibrary
//   mediaLibrary
// }
