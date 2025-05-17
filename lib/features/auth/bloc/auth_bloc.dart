import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../shared/services/auth_service.dart';
import '../../../shared/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final supabase.SupabaseClient _supabaseClient;

  AuthBloc({
    required AuthService authService,
    required supabase.SupabaseClient supabaseClient,
  })  : _authService = authService,
        _supabaseClient = supabaseClient,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    // Monitora mudanças de autenticação em tempo real
    _supabaseClient.auth.onAuthStateChange.listen((supabase.AuthState data) {
      final session = data.session;
      if (session != null) {
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } on supabase.AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Erro desconhecido ao verificar autenticação'));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('Tentando login para: [32m${event.email}[0m');
    emit(AuthLoading());
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        print('Login bem-sucedido!');
        emit(AuthAuthenticated(user));
      } else {
        print('Usuário não encontrado após login.');
        emit(AuthError('Usuário não encontrado ou perfil não cadastrado.'));
      }
    } on supabase.AuthException catch (e) {
      print('Erro de autenticação: [31m${e.message}[0m');
      emit(AuthError(_mapAuthError(e.message)));
    } catch (e) {
      print('Erro desconhecido ao fazer login: $e');
      emit(AuthError('Erro desconhecido ao fazer login'));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signUp(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on supabase.AuthException catch (e) {
      emit(AuthError(_mapAuthError(e.message)));
    } catch (e) {
      emit(AuthError('Erro desconhecido ao criar conta'));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Erro ao sair da conta'));
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'E-mail ou senha inválidos';
    } else if (message.contains('Email rate limit exceeded')) {
      return 'Muitas tentativas. Tente novamente mais tarde';
    } else if (message.contains('Email not confirmed')) {
      return 'Confirme seu e-mail antes de fazer login';
    }
    return message;
  }
}