import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';

class ContactFromPhoneSelectModel implements Contact {
  bool isChecked;

  @override
  Uint8List avatar;

  @override
  String company;

  @override
  String displayName;

  @override
  Iterable<Item> emails;

  @override
  String familyName;

  @override
  String givenName;

  @override
  String identifier;

  @override
  String jobTitle;

  @override
  String middleName;

  @override
  Iterable<Item> phones;

  @override
  Iterable<PostalAddress> postalAddresses;

  @override
  String prefix;

  @override
  String suffix;


   ContactFromPhoneSelectModel(
      {this.givenName,
      this.middleName,
      this.prefix,
      this.suffix,
      this.familyName,
      this.company,
      this.jobTitle,
      this.emails,
      this.phones,
      this.postalAddresses,
      this.avatar,
      this.isChecked
      });

  @override
  operator +(Contact other) {
    // TODO: implement +
    return null;
  }

  @override
  String initials() {
    // TODO: implement initials
    return null;
  }

  @override
  Map toMap() {
    // TODO: implement toMap
    return null;
  }
}
