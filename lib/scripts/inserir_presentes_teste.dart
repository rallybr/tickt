import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // Inicializa o Supabase
  await Supabase.initialize(
    url: 'https://milncqoqnjqcvrxubpsd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pbG5jcW9xbmpxY3ZyeHVicHNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMzI5NTYsImV4cCI6MjA2MjgwODk1Nn0.kOAl00F4xnyRynf549sFeGE7-G-9wkrtv2MzLluQmRI',
  );

  final supabase = Supabase.instance.client;
  final uuid = Uuid();

  try {
    // Lista de participantes de teste
    final participantes = [
      {'nome': 'João Silva', 'whatsapp': '11999999999'},
      {'nome': 'Maria Santos', 'whatsapp': '11988888888'},
      {'nome': 'Pedro Oliveira', 'whatsapp': '11977777777'},
      {'nome': 'Ana Costa', 'whatsapp': '11966666666'},
      {'nome': 'Lucas Ferreira', 'whatsapp': '11955555555'},
    ];

    // Busca um evento existente
    final eventos = await supabase.from('eventos').select().limit(1);
    if (eventos.isEmpty) {
      print('Nenhum evento encontrado. Por favor, crie um evento primeiro.');
      return;
    }
    final eventoId = eventos[0]['id'];

    print('Criando perfis e ingressos de teste...');

    // Para cada participante
    for (final participante in participantes) {
      final nome = participante['nome'] as String;
      final whatsapp = participante['whatsapp'] as String;
      
      // Gera um email único
      final email = '${nome.toLowerCase().replaceAll(' ', '')}_${DateTime.now().millisecondsSinceEpoch}@teste.com';

      // Cria o perfil do usuário
      final perfil = await supabase.from('perfis').insert({
        'nome': nome,
        'email': email,
        'whatsapp': whatsapp,
      }).select().single();

      print('Perfil criado: ${perfil['nome']}');

      // Cria o ingresso
      final ingresso = await supabase.from('ingressos').insert({
        'id': uuid.v4(),
        'codigo_qr': uuid.v4(),
        'numero_ingresso': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'presente',
        'data_compra': DateTime.now().toIso8601String(),
        'evento_id': eventoId,
        'comprador_id': perfil['id'],
      }).select().single();

      print('Ingresso criado para: ${perfil['nome']}');
    }

    print('\nTeste concluído com sucesso!');
    print('Agora você pode testar o sorteio no app.');

  } catch (e) {
    final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
    final isLimite = msg.contains('limite de 3 ingressos');
    print('Erro ao executar o script: $msg');
  }
} 