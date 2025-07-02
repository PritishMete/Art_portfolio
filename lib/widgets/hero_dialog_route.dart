// lib/widgets/hero_dialog_route.dart

import 'package:flutter/material.dart';

/// A custom page route that creates a hero animation between screens,
/// typically used for creating a pop-up dialog style animation.
class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : _builder = builder,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String get barrierLabel => 'Popup dialog open';

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return _builder(context);
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    // The hero animation is handled by the Hero widgets on the source and destination screens.
    // The FadeTransition is used for the background barrier.
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}