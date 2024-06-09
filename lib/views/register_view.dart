import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/contants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
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
    return Scaffold(
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
                    onPressed: () async{
                      try{
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _email.text,
                          password: _password.text,
                        );
                        final user = FirebaseAuth.instance.currentUser;
                        await user?.sendEmailVerification();
                        Navigator.of(context).pushNamed(verifyEmailRoute);
                      }on WeakPasswordException{
                        await showErrorDialog(context, 'The password provided is too weak.');
                      }on EmailAlreadyInUseException{
                        await showErrorDialog(context, 'An account already exists for that email.');
                      }on InvalidEmailException{
                        await showErrorDialog(context, 'The email address is not valid.');
                      }on GenericAuthException{
                        await showErrorDialog(context, 'Failed to Register User. Please try again.');
                      }
              },
              child: const Text('Register', style: TextStyle(fontSize: 20, color: Colors.blue), 
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(loginroute, (route) => false);
            }, child: const Text('Already Registered? Login Here!', style: TextStyle(fontSize: 20, color: Colors.blue)),
          )
        ],
      ),
    );
  }
}