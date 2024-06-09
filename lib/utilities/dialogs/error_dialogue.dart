import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionsBuilder: () {
      return {
        "OK": null,
      };
    },
  );
}