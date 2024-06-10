import 'dart:math';

import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', (){
    final provider = MockAuthProvider();

    test('Should not be initialized to begin with', (){
      expect(provider.isInitialized, false);
    });

    test('Cannot logout if not initialized', () async {
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('The user should be null after initialization', (){
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should be able to delegate to Login', () async {
      final bademailuser = provider.createUser(email: 'div@gmail.com', password: '123');
      expect(bademailuser, throwsA(const TypeMatcher<InvalidCredentialsException>()));

      final baspassworduser = provider.createUser(email: 'blah', password: '123456');
      expect(baspassworduser, throwsA(const TypeMatcher<InvalidCredentialsException>()));

      final gooduser = await provider.createUser(email: 'blah', password: '123');
      expect(provider.currentUser, gooduser);
      expect(gooduser.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified',() async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login again', () async {
      await provider.logOut();
      expect(provider.currentUser, null);
      final user = await provider.logIn(email: 'blah', password: '123');
      expect(provider.currentUser, user);
  });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {

  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if(!isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) {
      throw NotInitializedException();
    }
    if(email == 'div@gmail.com') throw InvalidCredentialsException();
    if(password == '123456') throw InvalidCredentialsException();
    const user = AuthUser(id: 'myid', isEmailVerified: false, email: 'blah@gmail.com');
    _user=user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if(!isInitialized) {
      throw NotInitializedException();
    }
    if(_user == null){
      throw UserNotLoggedInException();
    }
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if(!isInitialized) {
      throw NotInitializedException();
    }
    final user=_user;
    if(user == null){
      throw UserNotLoggedInException();
    }
    const newuser = AuthUser(id: 'myid', isEmailVerified: true, email: 'blah@gmail.com');
    _user = newuser;
  }
  
}