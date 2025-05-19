import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evento_model.dart';
import '../../core/config/supabase_config.dart';

class EventoService {
  final _supabase = SupabaseConfig.client;

  Future<String> uploadBanner(Uint8List banner, String userId) async {
    final fileName = 'banners/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageResponse = await _supabase.storage.from('eventos').uploadBinary(fileName, banner);
    final url = _supabase.storage.from('eventos').getPublicUrl(fileName);
    return url;
  }

  Future<String> uploadLogoEvento(Uint8List logo, String userId) async {
    final fileName = 'logos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageResponse = await _supabase.storage.from('eventos').uploadBinary(fileName, logo);
    final url = _supabase.storage.from('eventos').getPublicUrl(fileName);
    return url;
  }

  Future<EventoModel> criarEvento({
    required EventoModel evento,
    required Uint8List banner,
    required String userId,
    Uint8List? logoEvento,
  }) async {
    // Upload do banner
    final bannerUrl = await uploadBanner(banner, userId);
    String? logoUrl;
    if (logoEvento != null) {
      logoUrl = await uploadLogoEvento(logoEvento, userId);
    }
    // Monta o evento com o banner e logo
    final eventoComBanner = EventoModel(
      titulo: evento.titulo,
      descricao: evento.descricao,
      dataInicio: evento.dataInicio,
      dataFim: evento.dataFim,
      local: evento.local,
      bannerUrl: bannerUrl,
      igrejaId: evento.igrejaId,
      criadorId: userId,
      status: evento.status ?? 'rascunho',
      logoEvento: logoUrl,
    );
    // Salva no Supabase
    final response = await _supabase.from('eventos').insert(eventoComBanner.toJson()).select().single();
    return EventoModel.fromJson(response);
  }

  Future<List<EventoModel>> listarEventos() async {
    final response = await _supabase
        .from('eventos')
        .select()
        .order('data_inicio', ascending: true);
    return (response as List)
        .map((json) => EventoModel.fromJson(json))
        .toList();
  }

  Future<String?> buscarNomeIgreja(String igrejaId) async {
    final resp = await _supabase
        .from('igrejas')
        .select('nome')
        .eq('id', igrejaId)
        .maybeSingle();
    return resp != null ? resp['nome'] as String? : null;
  }
} 