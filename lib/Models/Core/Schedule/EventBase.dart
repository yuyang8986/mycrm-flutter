abstract class EventBase {
  String id;
  String summary;
  String note;
  String location;
  DateTime createTime;
  bool isCompleted;
  DateTime completeTime;
  bool isReminderOn;
  DateTime eventStartDateTime;
  int durationMinutes;


  EventBase(
      {this.completeTime,
      this.createTime,
      this.eventStartDateTime,
      this.durationMinutes,
      this.id,
      this.isCompleted,
      this.isReminderOn,
      this.location,
      this.summary,
      this.note});
}
