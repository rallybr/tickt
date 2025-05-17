import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ingresso_model.dart';
import '../models/evento_model.dart';
import '../../core/config/supabase_config.dart';

class IngressoService {
  final _supabase = SupabaseConfig.client;

  Future<Map<String, dynamic>> buscarIngressoEEvento(String ingressoId) async {
    // Buscar ingresso
    final ingressoJson = await _supabase
        .from('ingressos')
        .select()
        .eq('id', ingressoId)
        .single();
    final ingresso = IngressoModel.fromJson(ingressoJson);
    // Buscar evento
    final eventoJson = await _supabase
        .from('eventos')
        .select()
        .eq('id', ingresso.eventoId)
        .single();
    final evento = EventoModel.fromJson(eventoJson);
    return {
      'ingresso': ingresso,
      'evento': evento,
    };
  }
} 