import 'package:flutter/material.dart';
import 'package:mynotes/contants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/new_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
       primarySwatch: Colors.blue
      ),
      home: const HomePage(),
      routes: {
        loginroute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        newNoteRoute: (context) => const NewNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          // If the Firebase app has been initialized, display the registration form
          // with email and password fields.
          // Otherwise, display an error message.
        if (snapshot.connectionState == ConnectionState.done){
          final user = AuthService.firebase().currentUser;
          if(user == null)
          {
            return const LoginView();
          }
           else
          {
             if(user.isEmailVerified)
            {
              return const NotesView();
            }
            else
            {
              return const VerifyEmailView();
            }
          }
        }
        return const Text('Error: Firebase app initialization failed.');
      },
    );
  }
}
