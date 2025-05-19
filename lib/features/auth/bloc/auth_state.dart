part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final dynamic user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class AuthIncompleteProfile extends AuthState {
  final UserModel user;
  AuthIncompleteProfile(this.user);

  @override
  List<Object?> get props => [user];
} 