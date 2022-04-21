import 'package:mycrm/Models/Core/Schedule/ScheduleEvent.dart';
import 'package:path/path.dart';

class DashboardModel {
  List<OverallSummary> monthOverallSummary;
  List<OverallSummary> quarterOverallSummary;
  List<OverallSummary> yearOverallSummary;

  ///LeadAmountAnalysis leadAmountAnalysis;
  TargetAchieved targetAchieved;
  Performance performance;
  List<ScheduleEvent> todaySchedule;
  CountSummary countSummary;

  DashboardModel(
      {this.monthOverallSummary,
      this.quarterOverallSummary,
      this.yearOverallSummary,
      //this.leadAmountAnalysis,
      this.targetAchieved,
      this.countSummary,
      this.performance,
      this.todaySchedule});

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      new DashboardModel(
        countSummary: json["countSummary"] == null
            ? null
            : CountSummary.fromJson(json["countSummary"]),
        yearOverallSummary: json["yearOverallSummary"] == null
            ? null
            : new List<OverallSummary>.from(json["yearOverallSummary"]
            .map((x)=>OverallSummary.fromJson(x))),
        monthOverallSummary: json['monthOverallSummary'] == null
            ? null
            : new List<OverallSummary>.from(json["monthOverallSummary"]
                .map((x) => OverallSummary.fromJson(x))),
        quarterOverallSummary: json['quarterOverallSummary'] == null
            ? null
            : new List<OverallSummary>.from(json["quarterOverallSummary"]
                .map((x) => OverallSummary.fromJson(x))),
        //leadAmountAnalysis: json["leadAmountAnalysis"] == null
        //? null
        // : LeadAmountAnalysis.fromJson(json["leadAmountAnalysis"]),
        targetAchieved: json["targetAchieved"] == null
            ? null
            : TargetAchieved.fromJson(json["targetAchieved"]),
        performance: json["performance"] == null
            ? null
            : Performance.fromJson(json["performance"]),
        todaySchedule: json['todaySchedule'] == null
            ? null
            : new List<ScheduleEvent>.from(
                json["todaySchedule"].map((x) => ScheduleEvent.fromJson(x))),
      );
}

class Performance {
  double q1;
  double q2;
  double q3;
  double q4;

  Performance({this.q1, this.q2, this.q3, this.q4});

  factory Performance.fromJson(Map<String, dynamic> json) => new Performance(
        q1: json["q1"],
        q2: json["q2"],
        q3: json["q3"],
        q4: json["q4"],
      );
}

class OverallSummary {
  String name;
  int year;
  int openLead;
  double openLeadAmount;
  int won;
  double wonAmount;
  int lost;
  double lostAmount;

  OverallSummary(
      {this.name,
      this.year,
      this.openLead,
      this.openLeadAmount,
      this.won,
      this.wonAmount,
      this.lost,
      this.lostAmount});
  factory OverallSummary.fromJson(Map<String, dynamic> json) =>
      new OverallSummary(
          name: json["name"],
          year: json["year"],
          openLead: json["openLead"],
          openLeadAmount: json["openLeadAmount"],
          won: json["won"],
          wonAmount: json["wonAmount"],
          lost: json["lost"],
          lostAmount: json["lostAmount"]);
}

class CountSummary {
  int dealCount;
  int appointmentCount;
  int eventCount;
  int taskCount;

  CountSummary({
    this.dealCount,
    this.appointmentCount,
    this.eventCount,
    this.taskCount,
  });
  factory CountSummary.fromJson(Map<String, dynamic> json) => new CountSummary(
        dealCount: json["dealCount"],
        appointmentCount: json["appointmentCount"],
        eventCount: json["eventCount"],
        taskCount: json["taskCount"],
      );
}

class LeadAmountAnalysis {
  double highest;
  double average;
  double lowest;

  LeadAmountAnalysis({
    this.highest,
    this.average,
    this.lowest,
  });
  factory LeadAmountAnalysis.fromJson(Map<String, dynamic> json) =>
      new LeadAmountAnalysis(
        highest: json["highest"],
        average: json["average"],
        lowest: json["lowest"],
      );
}

class TargetAchieved {
  TargetAndAchievedModel q1;
  TargetAndAchievedModel q2;
  TargetAndAchievedModel q3;
  TargetAndAchievedModel q4;

  TargetAchieved({this.q1, this.q2, this.q3, this.q4});
  factory TargetAchieved.fromJson(Map<String, dynamic> json) =>
      new TargetAchieved(
        q1: json["q1"] == null
            ? null
            : TargetAndAchievedModel.fromJson(json["q1"]),
        q2: json["q2"] == null
            ? null
            : TargetAndAchievedModel.fromJson(json["q2"]),
        q3: json["q3"] == null
            ? null
            : TargetAndAchievedModel.fromJson(json["q3"]),
        q4: json["q4"] == null
            ? null
            : TargetAndAchievedModel.fromJson(json["q4"]),
      );
}

class TargetAndAchievedModel {
  double target;
  double achieved;

  TargetAndAchievedModel({
    this.target,
    this.achieved,
  });
  factory TargetAndAchievedModel.fromJson(Map<String, dynamic> json) =>
      new TargetAndAchievedModel(
        target: json["target"],
        achieved: json["achieved"],
      );
}
