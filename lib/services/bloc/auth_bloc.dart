import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider authProvider) : super(const AuthStateUninitialized(isLoading: true)){

    on<AuthEventVerifyEmail>((event, emit) async {
      await authProvider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      try{
        await authProvider.createUser(email: event.email, password: event.password);
        await authProvider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch(e) {
        emit(AuthStateRegistering(exception: e,isLoading:  false));
      }
    },
    );
    on<AuthEventInitialize>((event, emit) async{
      await authProvider.initialize();
      final user = authProvider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(exception: null,isLoading:  false));
      } else {
        if(user.isEmailVerified){
          emit(AuthStateLoggedIn(user: user,isLoading: false));
        } else {
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
      }
    });
    on <AuthEventLogin>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(exception: null, isLoading:  true, loadingText: 'Logging in...'));
        final user = await authProvider.logIn(email: event.email,password: event.password);
        if(user.isEmailVerified == false){
          emit(const AuthStateLoggedOut(exception: null,isLoading:  false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
        else{
          emit(const AuthStateLoggedOut(exception: null,isLoading:  false));
          emit(AuthStateLoggedIn(user: user,isLoading: false));
        }
        emit(AuthStateLoggedIn(user: user,isLoading: false));
      } on Exception catch(e) {
        emit(AuthStateLoggedOut(exception: e,isLoading:  false));
      }
    });
    on<AuthEventLogout>((event, emit) async {
      try {
        await authProvider.logOut();
        emit(const AuthStateLoggedOut(exception: null,isLoading:  false));
      } on Exception catch(e) {
        emit(AuthStateLoggedOut(exception: e,isLoading:  false));
      }
    });
  }
}