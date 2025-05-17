import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/config/supabase_config.dart';

class AuthService {
  final _supabase = SupabaseConfig.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('perfis')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return null;
      print('Usuário autenticado: [32m${user.id}[0m');
      final perfil = await _supabase
          .from('perfis')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      print('Perfil retornado: $perfil');
      if (perfil == null) {
        throw Exception('Perfil não encontrado para este usuário.');
      }
      return UserModel.fromJson(perfil);
    } catch (e) {
      print('Erro no signIn: $e');
      rethrow;
    }
  }
} 