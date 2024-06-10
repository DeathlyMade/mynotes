import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider authProvider) : super(const AuthStateLoading()){
    on<AuthEventInitialize>((event, emit) async{
      await authProvider.initialize();
      final user = authProvider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(null));
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
        final user = await authProvider.logIn(email: event.email,password: event.password);
        emit(AuthStateLoggedIn(user));
      } on Exception catch(e) {
        emit(AuthStateLoggedOut(e));
      }
    });
    on<AuthEventLogout>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await authProvider.logOut();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch(e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}