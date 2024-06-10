import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider authProvider) : super(const AuthStateUninitialized()){

    on<AuthEventVerifyEmail>((event, emit) async {
      await authProvider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      try{
        await authProvider.createUser(email: event.email, password: event.password);
        await authProvider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } on Exception catch(e) {
        emit(AuthStateRegistering(e));
      }
    },
    );
    on<AuthEventInitialize>((event, emit) async{
      await authProvider.initialize();
      final user = authProvider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(null, false));
      } else {
        if(user.isEmailVerified){
          emit(AuthStateLoggedIn(user));
        } else {
          emit(const AuthStateNeedsVerification());
        }
      }
    });
    on <AuthEventLogin>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(null, true));
        final user = await authProvider.logIn(email: event.email,password: event.password);
        if(user.isEmailVerified == false){
          emit(const AuthStateLoggedOut(null, false));
          emit(const AuthStateNeedsVerification());
        }
        else{
          emit(const AuthStateLoggedOut(null, false));
          emit(AuthStateLoggedIn(user));
        }
        emit(AuthStateLoggedIn(user));
      } on Exception catch(e) {
        emit(AuthStateLoggedOut(e, false));
      }
    });
    on<AuthEventLogout>((event, emit) async {
      try {
        await authProvider.logOut();
        emit(const AuthStateLoggedOut(null, false));
      } on Exception catch(e) {
        emit(AuthStateLoggedOut(e, false));
      }
    });
  }
}