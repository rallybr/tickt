import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/ingresso_model.dart';
import '../models/evento_model.dart';
import '../../core/config/supabase_config.dart';
import 'dart:convert';

class IngressoService {
  final _supabase = SupabaseConfig.client;

  Future<Map<String, dynamic>> buscarIngressoEEvento(String ingressoId) async {
    print('[DEBUG] Buscando ingresso com ID: $ingressoId');
    try {
      final ingressoResponse = await _supabase
          .from('ingressos')
          .select()
          .eq('id', ingressoId)
          .single();

      final eventoResponse = await _supabase
          .from('eventos')
          .select()
          .eq('id', ingressoResponse['evento_id'])
          .single();

      // Buscar o nome do usuário (primeiro nome)
      final perfil = await _supabase
          .from('perfis')
          .select('nome')
          .eq('id', ingressoResponse['comprador_id'])
          .maybeSingle();
      String nomeUsuario = '';
      if (perfil != null && perfil['nome'] != null && (perfil['nome'] as String).trim().isNotEmpty) {
        final nomeCompleto = perfil['nome'] as String;
        nomeUsuario = nomeCompleto.split(' ').first;
      }

      return {
        'ingresso': IngressoModel.fromJson({
          ...ingressoResponse,
          'nome_usuario': nomeUsuario,
        }),
        'evento': EventoModel.fromJson(eventoResponse),
      };
    } catch (e) {
      print('Erro ao buscar ingresso e evento: $e');
      rethrow;
    }
  }

  Future<String?> gerarIngressoParaEvento({
    required String eventoId,
    required String compradorId,
    required String nomeUsuario,
    required String nomeEvento,
  }) async {
    try {
      // Verifica se o usuário já tem 3 ingressos para este evento
      final ingressosExistentes = await _supabase
          .from('ingressos')
          .select()
          .eq('evento_id', eventoId)
          .eq('comprador_id', compradorId);

      if (ingressosExistentes.length >= 3) {
        throw Exception('Você já atingiu o limite de 3 ingressos para este evento.');
      }

      // Gera um novo ingresso
      final numeroIngresso = DateTime.now().millisecondsSinceEpoch.toString();
      final codigoQr = _gerarCodigoAleatorio();
      final dadosQr = jsonEncode({
        'codigo_qr': codigoQr,
        'nome_usuario': nomeUsuario,
        'nome_evento': nomeEvento,
      });
      
      final response = await _supabase.from('ingressos').insert({
        'evento_id': eventoId,
        'comprador_id': compradorId,
        'status': 'reservado',
        'data_compra': DateTime.now().toIso8601String(),
        'numero_ingresso': numeroIngresso,
        'codigo_qr': dadosQr,
      }).select().single();

      return response['id'];
    } catch (e) {
      print('Erro ao gerar ingresso: $e');
      throw Exception(e.toString());
    }
  }

  String _gerarCodigoAleatorio() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(10, (index) => chars[(rand + index) % chars.length]).join();
  }

  Future<List<IngressoModel>> buscarIngressosDoUsuario(String userId) async {
    final ingressosResp = await _supabase
        .from('ingressos')
        .select()
        .eq('comprador_id', userId)
        .order('data_compra', ascending: false);
    return (ingressosResp as List)
        .map((json) => IngressoModel.fromJson(json))
        .toList();
  }

  Future<List<IngressoModel>> buscarIngressosDoEvento(String eventoId) async {
    try {
      final response = await _supabase
          .from('ingressos')
          .select()
          .eq('evento_id', eventoId);

      return response.map((json) => IngressoModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar ingressos: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> validarIngresso(String codigoQr) async {
    try {
      final ingressoResponse = await _supabase
          .from('ingressos')
          .select()
          .eq('codigo_qr', codigoQr)
          .single();

      if (ingressoResponse == null) {
        return {
          'success': false,
          'message': 'Ingresso não encontrado',
        };
      }

      // Buscar nome do usuário
      final perfil = await _supabase
          .from('perfis')
          .select('nome')
          .eq('id', ingressoResponse['comprador_id'])
          .maybeSingle();
      String nomeUsuario = '';
      if (perfil != null && perfil['nome'] != null && (perfil['nome'] as String).trim().isNotEmpty) {
        final nomeCompleto = perfil['nome'] as String;
        nomeUsuario = nomeCompleto.split(' ').first;
      }

      // Buscar nome do evento
      final evento = await _supabase
          .from('eventos')
          .select('titulo')
          .eq('id', ingressoResponse['evento_id'])
          .maybeSingle();
      final nomeEvento = evento != null ? evento['titulo'] ?? '' : '';

      return {
        'success': true,
        'dados': {
          'codigo_qr': ingressoResponse['codigo_qr'],
          'nome_usuario': nomeUsuario,
          'nome_evento': nomeEvento,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao validar ingresso: $e',
      };
    }
  }

  Future<Map<String, dynamic>> realizarSorteio(String eventoId) async {
    try {
      // Busca todos os ingressos do evento
      final ingressos = await buscarIngressosDoEvento(eventoId);
      
      // Filtra apenas os ingressos com status 'presente'
      final presentes = ingressos.where((i) => i.status == 'presente').toList();
      
      if (presentes.isEmpty) {
        throw Exception('Não há participantes presentes para o sorteio.');
      }

      // Busca os perfis dos participantes
      List<Map<String, dynamic>> participantes = [];
      for (final ingresso in presentes) {
        final perfil = await _supabase
            .from('perfis')
            .select('nome')
            .eq('id', ingresso.compradorId)
            .single();
        
        if (perfil != null) {
          participantes.add(perfil);
        }
      }

      if (participantes.isEmpty) {
        throw Exception('Não foi possível encontrar os perfis dos participantes.');
      }

      // Realiza o sorteio
      final random = DateTime.now().millisecondsSinceEpoch % participantes.length;
      final ganhador = participantes[random];

      return {
        'success': true,
        'ganhador': ganhador['nome'],
      };
    } catch (e) {
      throw Exception('Erro ao realizar sorteio: $e');
    }
  }
} 