import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';

class FirebaseAuthProvider implements AuthProvider {

@override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    return user == null ? null : AuthUser.fromFirebase(user);
  }

@override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user=currentUser;
      if(user != null){
        return user;
      }
      else{
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if(e.code == 'invalid-credential'){
        throw InvalidCredentialsException();           
      }
      else{
        throw GenericAuthException(e.message);            
      }
    }catch(e){
      throw GenericAuthException('An error occurred');
    }
  }

@override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user=currentUser;
      if(user != null){
        return user;
      }
      else{
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if(e.code == 'weak-password') {
        throw WeakPasswordException();    
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();  
      } else if(e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else{
        throw GenericAuthException(e.message);
      }
    } catch(_){
        throw GenericAuthException('An error occurred');
      }
    }

@override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInException();
    }
  }

@override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInException();
    }
  }
}