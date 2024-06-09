
import 'package:flutter/material.dart';

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if(modalRoute != null && modalRoute.settings.arguments != null && modalRoute.settings.arguments is T) {
      return modalRoute.settings.arguments as T;
    }
    return null;
  }
}