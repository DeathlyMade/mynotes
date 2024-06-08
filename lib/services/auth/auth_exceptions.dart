//login excpetions

class InvalidCredentialsException implements Exception {
  final String message = 'Invalid credentials';
}

//register exceptions

class EmailAlreadyInUseException implements Exception {
  final String message = 'Email already in use';
}

class WeakPasswordException implements Exception {
  final String message = 'Weak password';
}

class InvalidEmailException implements Exception {
  final String message = 'Invalid email';
}

//generic exceptions

class GenericAuthException implements Exception {
  final String? message;
  GenericAuthException(this.message);
}

class UserNotLoggedInException implements Exception {
  final String message = 'User not logged in';
}