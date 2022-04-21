import 'package:flutter/material.dart';
import 'package:mycrm/Http/Repos/RepoBase.dart';
import 'package:rxdart/subjects.dart';

abstract class BlocBase {
  void dispose();

  Future handleEndResult(RepoResponse response, BehaviorSubject behaviorSubject) async {
    if (response.success) {
      behaviorSubject.sink.add(response.model);
    } else {
      behaviorSubject.sink.addError(null);
    }
  }
}

//通用BLoC提供商
class BlocProvider<T extends BlocBase> extends StatefulWidget {
  BlocProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    final type = _typeOf<BlocProvider<T>>();
    BlocProvider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider?.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override

  /// 便于资源的释放
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
