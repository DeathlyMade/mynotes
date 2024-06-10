import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialogue.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state is AuthStateRegistering){
          if(state.exception is WeakPasswordException){
            await showErrorDialog(context, 'The password provided is too weak.');
          } else if(state.exception is EmailAlreadyInUseException){
            await showErrorDialog(context, 'An account already exists for that email.');
          } else if(state.exception is InvalidEmailException){
            await showErrorDialog(context, 'The email address is not valid.');
          } else if(state.exception is GenericAuthException){
            await showErrorDialog(context, 'Failed to Register User. Please try again.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          // backgroundColor: Colors.blue,
          // titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email address',
              ),
            ),
            TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: _password,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
              ),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventRegister(email, password));
              },
              child: const Text(
                'Register',
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogout());
              },
              child: const Text('Already Registered? Login Here!',
                  style: TextStyle(fontSize: 20, color: Colors.blue)),
            )
          ],
        ),
      ),
    );
  }
}
