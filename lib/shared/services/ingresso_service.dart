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

  Future<String?> gerarIngressoParaEvento({
    required String eventoId,
    required String compradorId,
    required String nomeUsuario,
    required String nomeEvento,
  }) async {
    // Buscar o primeiro tipo de ingresso disponível para o evento
    var tipos = await _supabase
        .from('tipos_ingresso')
        .select()
        .eq('evento_id', eventoId)
        .order('preco', ascending: true)
        .limit(1);
    String tipoIngressoId;
    if (tipos == null || tipos.isEmpty) {
      // Criar tipo de ingresso padrão
      final tipoCriado = await _supabase.from('tipos_ingresso').insert({
        'nome': 'Ingresso Padrão',
        'descricao': 'Ingresso padrão do evento',
        'preco': 0,
        'quantidade_total': 100,
        'quantidade_disponivel': 100,
        'evento_id': eventoId,
        'criador_id': compradorId,
      }).select().single();
      print('[DEBUG] Retorno do insert do tipo de ingresso: $tipoCriado');
      if (tipoCriado == null || tipoCriado['id'] == null || tipoCriado['id'].toString().isEmpty) {
        throw Exception('Falha ao criar tipo de ingresso padrão. Retorno: $tipoCriado');
      }
      tipoIngressoId = tipoCriado['id'];
    } else {
      tipoIngressoId = tipos.first['id'];
    }

    print('[DEBUG] eventoId: ' + (eventoId ?? 'null'));
    print('[DEBUG] compradorId: ' + (compradorId ?? 'null'));
    print('[DEBUG] tipoIngressoId: ' + (tipoIngressoId ?? 'null'));

    if (eventoId == null || eventoId.isEmpty) {
      throw Exception('EventoId inválido');
    }
    if (tipoIngressoId == null || tipoIngressoId.toString().isEmpty) {
      throw Exception('Tipo de ingresso inválido.');
    }
    if (compradorId == null || compradorId.isEmpty) {
      throw Exception('ID do comprador inválido.');
    }

    // Gerar código aleatório para o ingresso (UUID v4)
    final codigoQrUuid = const Uuid().v4();
    final qrData = jsonEncode({
      'codigo_qr': codigoQrUuid,
      'nome_usuario': nomeUsuario,
      'nome_evento': nomeEvento,
    });
    final numeroIngresso = DateTime.now().millisecondsSinceEpoch.toString();
    final dataCompra = DateTime.now().toIso8601String();
    final hashUnico = const Uuid().v4();

    // Inserir ingresso no Supabase
    final response = await _supabase.from('ingressos').insert({
      'codigo_qr': qrData,
      'hash_unico': hashUnico,
      'numero_ingresso': numeroIngresso,
      'status': 'reservado',
      'data_compra': dataCompra,
      'tipo_ingresso_id': tipoIngressoId,
      'comprador_id': compradorId,
      'evento_id': eventoId,
    }).select().single();

    print('[DEBUG] Retorno do insert do ingresso: $response');
    if (response == null || response['id'] == null || response['id'].toString().isEmpty) {
      throw Exception('Falha ao criar ingresso. Retorno: $response');
    }

    return response['id'];
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
} 