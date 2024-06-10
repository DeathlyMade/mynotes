import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}

class AuthEventLogin extends AuthEvent{
  final String email;
  final String password;
  const AuthEventLogin(this.email, this.password);
}

class AuthEventLogout extends AuthEvent{
  const AuthEventLogout();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventVerifyEmail extends AuthEvent{
  const AuthEventVerifyEmail();
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}