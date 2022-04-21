import 'package:mycrm/Models/Core/contact/People.dart';
import 'package:mycrm/Models/Dto/People/AddPeopleDto.dart';

class ImportPeopleDto {
  List<AddPeopleDto> peopleList;

  ImportPeopleDto(this.peopleList);

  Map<String, dynamic> toJson() => {
        "peopleList": peopleList == null
            ? null
            : new List<dynamic>.from(peopleList.map((x) => x.toJson())),
      };
}
