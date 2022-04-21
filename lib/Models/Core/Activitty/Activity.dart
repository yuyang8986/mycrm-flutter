

enum ActivityType { appointment, event, task }

class Activity {
  String id;
  String name;
  int organizationId;
  ActivityType activityType;

  Activity(
      {this.id,
      this.name,
      this.organizationId,      
      this.activityType});

  factory Activity.fromJson(Map<String, dynamic> json) => new Activity(
        id: json["id"],
        name: json["name"],
        organizationId: json["organizationId"],
        activityType: ActivityType.values[json["activityType"]],    
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "organizationId": organizationId,     
        "activityType": activityType.index
      };
  //add this equal operator so as to prevent exception when change dropdownlist for stages and rebuild the futurebuilder
  bool operator ==(o) => o is Activity && o.name == name;
  int get hashCode => name.hashCode;
}
