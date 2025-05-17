import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estado_model.dart';
import '../models/bloco_model.dart';
import '../models/regiao_model.dart';
import '../models/igreja_model.dart';
import '../../core/config/supabase_config.dart';

class CadastroService {
  final _supabase = SupabaseConfig.client;

  // Upload de foto
  Future<String> uploadFoto(Uint8List foto) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    final fileName = 'fotos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage.from('perfis').uploadBinary(fileName, foto);
    
    final url = _supabase.storage.from('perfis').getPublicUrl(fileName);
    return url;
  }

  // Buscar estados
  Future<List<EstadoModel>> getEstados() async {
    try {
      print('Iniciando busca de estados...');
      
      // Verificar se o cliente Supabase está inicializado
      if (_supabase == null) {
        print('Erro: Cliente Supabase não inicializado');
        throw Exception('Cliente Supabase não inicializado');
      }

      // Verificar se há conexão com o Supabase
      try {
        await _supabase.from('estados').select('count').limit(1);
      } catch (e) {
        print('Erro ao conectar com o Supabase: $e');
        throw Exception('Erro ao conectar com o banco de dados');
      }
      
      // Primeiro, vamos verificar a estrutura da tabela
      final tableInfo = await _supabase
          .from('estados')
          .select('*')
          .limit(1);
      
      print('Estrutura da tabela estados: ${jsonEncode(tableInfo)}');
      
      // Agora vamos buscar todos os estados
      final response = await _supabase
          .from('estados')
          .select('*')
          .order('nome');
      
      print('Resposta completa do Supabase: ${jsonEncode(response)}');
      print('Número de estados encontrados: ${response.length}');
      
      if (response.isEmpty) {
        print('Nenhum estado encontrado no banco de dados');
        throw Exception('Nenhum estado encontrado no banco de dados. Por favor, verifique se os dados foram inseridos corretamente.');
      }

      final estados = response.map((json) {
        print('Processando estado: ${jsonEncode(json)}');
        try {
          // Verificar se os campos necessários existem
          if (!json.containsKey('id')) {
            print('Erro: campo id não encontrado no JSON');
            throw Exception('Campo id é obrigatório');
          }
          if (!json.containsKey('nome')) {
            print('Erro: campo nome não encontrado no JSON');
            throw Exception('Campo nome é obrigatório');
          }
          if (!json.containsKey('sigla')) {
            print('Erro: campo sigla não encontrado no JSON');
            throw Exception('Campo sigla é obrigatório');
          }

          final estado = EstadoModel.fromJson(json);
          print('Estado convertido com sucesso: ${estado.toString()}');
          return estado;
        } catch (e) {
          print('Erro ao converter estado: $e');
          print('JSON que causou o erro: ${jsonEncode(json)}');
          rethrow;
        }
      }).toList();
      
      print('Total de estados convertidos: ${estados.length}');
      if (estados.isNotEmpty) {
        print('Primeiro estado: ${estados.first.toString()}');
      }
      return estados;
    } catch (e, stackTrace) {
      print('Erro ao buscar estados: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Buscar blocos por estado
  Future<List<BlocoModel>> getBlocosPorEstado(String estadoId) async {
    try {
      print('Buscando blocos para o estado $estadoId...');
      final response = await _supabase
          .from('blocos')
          .select()
          .eq('estado_id', estadoId)
          .order('nome');
      
      print('Resposta do Supabase (blocos): ${jsonEncode(response)}');
      print('Blocos encontrados: ${response.length}');
      
      if (response.isEmpty) {
        print('Nenhum bloco encontrado para o estado $estadoId');
        return [];
      }

      final blocos = response.map((json) {
        print('Convertendo bloco: ${jsonEncode(json)}');
        return BlocoModel.fromJson(json);
      }).toList();
      
      print('Blocos convertidos: ${blocos.length}');
      print('Primeiro bloco: ${blocos.first.nome}');
      return blocos;
    } catch (e, stackTrace) {
      print('Erro ao buscar blocos: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Buscar regiões por bloco
  Future<List<RegiaoModel>> getRegioesPorBloco(String blocoId) async {
    try {
      print('Buscando regiões para o bloco $blocoId...');
      final response = await _supabase
          .from('regioes')
          .select()
          .eq('bloco_id', blocoId)
          .order('nome');
      
      print('Resposta do Supabase (regiões): ${jsonEncode(response)}');
      print('Regiões encontradas: ${response.length}');
      
      if (response.isEmpty) {
        print('Nenhuma região encontrada para o bloco $blocoId');
        return [];
      }

      final regioes = response.map((json) {
        print('Convertendo região: ${jsonEncode(json)}');
        return RegiaoModel.fromJson(json);
      }).toList();
      
      print('Regiões convertidas: ${regioes.length}');
      print('Primeira região: ${regioes.first.nome}');
      return regioes;
    } catch (e, stackTrace) {
      print('Erro ao buscar regiões: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Buscar igrejas por região
  Future<List<IgrejaModel>> getIgrejasPorRegiao(String regiaoId) async {
    try {
      print('Buscando igrejas para a região $regiaoId...');
      final response = await _supabase
          .from('igrejas')
          .select()
          .eq('regiao_id', regiaoId)
          .order('nome');
      
      print('Resposta do Supabase (igrejas): ${jsonEncode(response)}');
      print('Igrejas encontradas: ${response.length}');
      
      if (response.isEmpty) {
        print('Nenhuma igreja encontrada para a região $regiaoId');
        return [];
      }

      final igrejas = response.map((json) {
        print('Convertendo igreja: ${jsonEncode(json)}');
        return IgrejaModel.fromJson(json);
      }).toList();
      
      print('Igrejas convertidas: ${igrejas.length}');
      print('Primeira igreja: ${igrejas.first.nome}');
      return igrejas;
    } catch (e, stackTrace) {
      print('Erro ao buscar igrejas: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Criar perfil do usuário
  Future<void> criarPerfil({
    required String nome,
    required String email,
    required String whatsapp,
    required String fotoUrl,
    required String igrejaId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    await _supabase.from('perfis').insert({
      'id': userId,
      'nome': nome,
      'email': email,
      'whatsapp': whatsapp,
      'foto_url': fotoUrl,
      'igreja_id': igrejaId,
    });
  }
} 