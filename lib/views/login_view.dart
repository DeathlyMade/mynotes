import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/contants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/utilities/dialogs/error_dialogue.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                    onPressed: () async{
                      final email = _email.text;
                      final password = _password.text;
                    try{
                      context.read<AuthBloc>().add(AuthEventLogin(
                        email,
                        password,
                      ));
                  }on InvalidCredentialsException{
                    await showErrorDialog(context, 'Invalid credentials');
                  } on GenericAuthException{
                    await showErrorDialog(context, 'Authentication Error');
                  }
                  },
              child: const Text('Login', style: TextStyle(fontSize: 20, color: Colors.blue), 
            ),
          ),
          TextButton(
            onPressed:() {
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not Registered? Register Here!', style: TextStyle(fontSize: 20, color: Colors.blue)),
          )
        ],
      ),
    );
  }
}