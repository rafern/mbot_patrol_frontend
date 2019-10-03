import '../common.dart';

// An alert route to work around showDialog's buggy limitations
class AlertRoute<T> extends ModalRoute<T> {
  final WidgetBuilder builder;
  final String debugLabel;

  AlertRoute({
    @required this.builder,
    this.debugLabel
  }) : assert(builder != null),
        super(settings: null);

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => Color(0x80000000);

  @override
  String get barrierLabel => debugLabel;

  @override
  bool get barrierDismissible => true;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> a, Animation<double> sa) {
    return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(a),
        child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: builder(context)
        )
    );
  }
}

// A navigation manager is a static class that abstracts the navigation system
class NavigationManager {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>(debugLabel: 'NavigationManager');

  // Same as Navigator.pushNamed(...)
  static Future<T> push<T extends Object>(String routeName, {Object arguments}) {
    return key.currentState.pushNamed(routeName, arguments: arguments);
  }

  // Same as Navigator.pop(...)
  static bool pop<T extends Object>([T result]) {
    return key.currentState.pop(result);
  }

  // Same as Navigator.pushReplacementNamed(...)
  static Future<T> replace<T extends Object, TO extends Object>(String routeName, {TO result, Object arguments}) {
    return key.currentState.pushReplacementNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  // Shows a dialog. Not akin to any Navigator method
  static Future<T> alert<T>(Widget dialog, [String debugLabel]) {
    return key.currentState.push<T>(
        AlertRoute<T>(
            builder: (BuildContext context) {
              return dialog;
            },
            debugLabel: debugLabel
        )
    );
  }
}