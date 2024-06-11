import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPaswordResetEmailSentDialog(BuildContext context){
  return showGenericDialog(
    context: context,
    title: 'Reset Password',
    content: 'An email has been sent to your email address. Please follow the instructions in the email to reset your password.',
    optionsBuilder: () => {
      'OK': null,
    }
  );
}