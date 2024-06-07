import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

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
                    try{
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _email.text,
                      password: _password.text,
                    );
                    Navigator.of(context).pushNamedAndRemoveUntil('/notes', (route) => false);
                  } on FirebaseAuthException catch (e) {
                  if(e.code == 'invalid-credential'){
                    print('Invalid credentials. Please try again.');
                  }
                }
              },
              child: const Text('Login', style: TextStyle(fontSize: 20, color: Colors.blue), 
            ),
          ),
          TextButton(
            onPressed:() {
              Navigator.of(context).pushNamedAndRemoveUntil('/register', (route) => false);
            },
            child: const Text('Not Registered? Register Here!', style: TextStyle(fontSize: 20, color: Colors.blue)),
          )
        ],
      ),
    );
  }
}