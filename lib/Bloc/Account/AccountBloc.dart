import 'dart:async';
import 'package:mycrm/Bloc/BlocBase.dart';
import 'package:mycrm/Http/HttpRequest.dart';
import 'package:mycrm/Http/Repos/Account/AccountRepo.dart';
import 'package:mycrm/Models/Dto/Payment/Payment.dart';
import 'package:rxdart/rxdart.dart';

class AccountBloc extends BlocBase {
  final AccountRepo accountRepo = AccountRepo();
  final String subId;
  AccountBloc({this.subId}) {
    if (subId != null) {
      getRenewInfo(subId);
    } else {
      if (HttpRequest.appUser.isAdmin) getAccountInfo();
    }
  }

  final BehaviorSubject<AccountInfoDto> accountInfoController =
      BehaviorSubject<AccountInfoDto>();

  Observable<AccountInfoDto> get accountInfoStream =>
      accountInfoController.stream;

  Future getRenewInfo(String subId) async {
    var result = await accountRepo.getRenewInfo(subId);
    await handleEndResult(result, accountInfoController);
  }

  Future getAccountInfo() async {
    var result = await accountRepo.getAccountInfo();
    await handleEndResult(result, accountInfoController);
  }

  Future changeAccountsNo(int quantity) async {
    await accountRepo.changeAccountsNo(quantity);
    await getAccountInfo();
  }

  Future changePlan(String plan) async {
    await accountRepo.changePlan(plan);
    await getAccountInfo();
  }

  Future cancelSub() async {
    await accountRepo.cancelSub();
    await getAccountInfo();
  }

  @override
  void dispose() {}
}
