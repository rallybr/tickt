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

  Future<EventoModel> criarEvento({
    required EventoModel evento,
    required Uint8List banner,
    required String userId,
  }) async {
    // Upload do banner
    final bannerUrl = await uploadBanner(banner, userId);
    // Monta o evento com o banner
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
} 