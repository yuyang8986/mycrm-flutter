import 'package:mycrm/Infrastructure/DateTimeHelper.dart';

class InitialPaymentDto {
  String sourceId;
  double amount;
  String productName;
  String contactEmail;
  String subscriptionId;

  InitialPaymentDto(
      this.amount, this.productName, this.sourceId, this.contactEmail,
      {this.subscriptionId});

  Map<String, dynamic> toJson() => {
        "sourceId": sourceId,
        "amount": amount,
        "productName": productName,
        "contactEmail": contactEmail,
        "SubscriptionId": subscriptionId
      };
}

class SubcriptionDto {
  String paymentMethodId;
  String plan;
  int subscriptionQuantity;
  String subscriptionId;

  SubcriptionDto(this.paymentMethodId, this.plan, this.subscriptionQuantity,
      this.subscriptionId);

  Map<String, dynamic> toJson() => {
        "paymentMethodId": paymentMethodId,
        "plan": plan,
        "subscriptionQuantity": subscriptionQuantity,
        "SubscriptionId": subscriptionId
      };
}

class AccountInfoDto {
  DateTime nextBillingDate;
  double dueAmount;
  int totalSubQuantity;
  int totalActiveAccounts;
  String last4Digits;
  String companyName;
  String currentPlan;
  String email;
  DateTime cancelAt;
  DateTime trialEnd;
  bool cancelAtPeriodEnd;

  AccountInfoDto(
      {this.nextBillingDate,
      this.dueAmount,
      this.totalSubQuantity,
      this.last4Digits,
      this.totalActiveAccounts,
      this.companyName,
      this.currentPlan,
      this.email,
      this.cancelAt,
      this.cancelAtPeriodEnd,
      this.trialEnd});

  factory AccountInfoDto.fromJson(Map<String, dynamic> json) =>
      new AccountInfoDto(
          dueAmount: json["dueAmount"],
          totalSubQuantity: json["totalSubQuantity"],
          nextBillingDate:
              DateTimeHelper.parseDotNetDateTimeToDart(json["nextBillingDate"]),
          trialEnd: json["trialEnd"] == null
              ? null
              : DateTimeHelper.parseDotNetDateTimeToDart(json["trialEnd"]),
          cancelAt: json["cancelAt"] == null
              ? null
              : DateTimeHelper.parseDotNetDateTimeToDart(json["cancelAt"]),
          totalActiveAccounts: json["totalActiveAccounts"],
          last4Digits: json["last4Digits"],
          companyName: json["companyName"],
          currentPlan: json["currentPlan"],
          email: json["email"],
          cancelAtPeriodEnd: json["cancelAtPeriodEnd"]);

  // Map<String, dynamic> toJson() =>
  //     {"paymentMethodId": paymentMethodId, "plan": plan, "quantity": quantity};
}
