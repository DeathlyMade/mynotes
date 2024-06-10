import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
          children: [
            const Text('A verification email has been sent to your email address.'),
            const Text('If you have not received the email, please click the button below to resend it.'),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventVerifyEmail());
              },
              child: const Text('Send verification email'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogout());
              },
              child: const Text("Restart"),
              )
          ],
        ),
    );
  }
}