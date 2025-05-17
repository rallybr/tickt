import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/services/cadastro_service.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/auth_service.dart';

// Events
abstract class CadastroEvent extends Equatable {
  const CadastroEvent();

  @override
  List<Object?> get props => [];
}

class CadastroIniciado extends CadastroEvent {}

class CadastroEtapa1Completa extends CadastroEvent {
  final String nome;
  final String email;
  final String whatsapp;
  final String senha;
  final Uint8List foto;

  const CadastroEtapa1Completa({
    required this.nome,
    required this.email,
    required this.whatsapp,
    required this.senha,
    required this.foto,
  });

  @override
  List<Object?> get props => [nome, email, whatsapp, senha, foto];
}

class CadastroEstadoSelecionado extends CadastroEvent {
  final EstadoModel estado;

  const CadastroEstadoSelecionado(this.estado);

  @override
  List<Object?> get props => [estado];
}

class CadastroBlocoSelecionado extends CadastroEvent {
  final BlocoModel bloco;

  const CadastroBlocoSelecionado(this.bloco);

  @override
  List<Object?> get props => [bloco];
}

class CadastroRegiaoSelecionada extends CadastroEvent {
  final RegiaoModel regiao;

  const CadastroRegiaoSelecionada(this.regiao);

  @override
  List<Object?> get props => [regiao];
}

class CadastroIgrejaSelecionada extends CadastroEvent {
  final IgrejaModel igreja;

  const CadastroIgrejaSelecionada(this.igreja);

  @override
  List<Object?> get props => [igreja];
}

class CadastroFinalizado extends CadastroEvent {}

class CadastroConfirmarEmail extends CadastroEvent {
  final String email;
  final String senha;

  const CadastroConfirmarEmail(this.email, this.senha);

  @override
  List<Object?> get props => [email, senha];
}

// States
abstract class CadastroState extends Equatable {
  const CadastroState();

  @override
  List<Object?> get props => [];
}

class CadastroInitial extends CadastroState {}

class CadastroLoading extends CadastroState {}

class CadastroEtapa1 extends CadastroState {}

class CadastroEtapa2 extends CadastroState {
  final String nome;
  final String email;
  final String whatsapp;
  final String senha;
  final Uint8List foto;
  final List<EstadoModel> estados;
  final EstadoModel? estadoSelecionado;
  final List<BlocoModel> blocos;
  final BlocoModel? blocoSelecionado;
  final List<RegiaoModel> regioes;
  final RegiaoModel? regiaoSelecionada;
  final List<IgrejaModel> igrejas;
  final IgrejaModel? igrejaSelecionada;

  const CadastroEtapa2({
    required this.nome,
    required this.email,
    required this.whatsapp,
    required this.senha,
    required this.foto,
    required this.estados,
    this.estadoSelecionado,
    required this.blocos,
    this.blocoSelecionado,
    required this.regioes,
    this.regiaoSelecionada,
    required this.igrejas,
    this.igrejaSelecionada,
  });

  @override
  List<Object?> get props => [
        nome,
        email,
        whatsapp,
        senha,
        foto,
        estados,
        estadoSelecionado,
        blocos,
        blocoSelecionado,
        regioes,
        regiaoSelecionada,
        igrejas,
        igrejaSelecionada,
      ];
}

class CadastroEtapa3 extends CadastroState {
  final String nome;
  final String email;
  final String whatsapp;
  final String senha;
  final Uint8List foto;
  final EstadoModel estado;
  final BlocoModel bloco;
  final RegiaoModel regiao;
  final IgrejaModel igreja;

  const CadastroEtapa3({
    required this.nome,
    required this.email,
    required this.whatsapp,
    required this.senha,
    required this.foto,
    required this.estado,
    required this.bloco,
    required this.regiao,
    required this.igreja,
  });

  @override
  List<Object?> get props => [
        nome,
        email,
        whatsapp,
        senha,
        foto,
        estado,
        bloco,
        regiao,
        igreja,
      ];
}

class CadastroSuccess extends CadastroState {}

class CadastroError extends CadastroState {
  final String message;

  const CadastroError(this.message);

  @override
  List<Object?> get props => [message];
}

class CadastroAguardandoConfirmacaoEmail extends CadastroState {
  final String email;
  final String senha;
  final String nome;
  final String whatsapp;
  final Uint8List foto;

  const CadastroAguardandoConfirmacaoEmail({
    required this.email,
    required this.senha,
    required this.nome,
    required this.whatsapp,
    required this.foto,
  });

  @override
  List<Object?> get props => [email, senha, nome, whatsapp, foto];
}

// Bloc
class CadastroBloc extends Bloc<CadastroEvent, CadastroState> {
  final CadastroService _cadastroService;

  CadastroBloc({required CadastroService cadastroService})
      : _cadastroService = cadastroService,
        super(CadastroInitial()) {
    on<CadastroIniciado>(_onCadastroIniciado);
    on<CadastroEtapa1Completa>(_onCadastroEtapa1Completa);
    on<CadastroEstadoSelecionado>(_onCadastroEstadoSelecionado);
    on<CadastroBlocoSelecionado>(_onCadastroBlocoSelecionado);
    on<CadastroRegiaoSelecionada>(_onCadastroRegiaoSelecionada);
    on<CadastroIgrejaSelecionada>(_onCadastroIgrejaSelecionada);
    on<CadastroFinalizado>(_onCadastroFinalizado);
    on<CadastroConfirmarEmail>(_onCadastroConfirmarEmail);
  }

  Future<void> _onCadastroIniciado(
    CadastroIniciado event,
    Emitter<CadastroState> emit,
  ) async {
    emit(CadastroEtapa1());
  }

  Future<void> _onCadastroEtapa1Completa(
    CadastroEtapa1Completa event,
    Emitter<CadastroState> emit,
  ) async {
    try {
      final authService = AuthService();
      final authResponse = await authService.signUp(
        email: event.email,
        password: event.senha,
      );
      final userId = authResponse.user?.id;
      if (userId == null) throw Exception('Erro ao criar usuário. Tente novamente.');

      // Emitir estado aguardando confirmação de e-mail
      emit(CadastroAguardandoConfirmacaoEmail(
        email: event.email,
        senha: event.senha,
        nome: event.nome,
        whatsapp: event.whatsapp,
        foto: event.foto,
      ));
    } catch (e, stackTrace) {
      emit(CadastroError(e.toString()));
    }
  }

  Future<void> _onCadastroEstadoSelecionado(
    CadastroEstadoSelecionado event,
    Emitter<CadastroState> emit,
  ) async {
    if (state is CadastroEtapa2) {
      final currentState = state as CadastroEtapa2;
      try {
        print('Buscando blocos para o estado: ${event.estado.nome}');
        final blocos = await _cadastroService.getBlocosPorEstado(event.estado.id);
        print('Blocos encontrados: ${blocos.length}');

        if (blocos.isEmpty) {
          print('Nenhum bloco encontrado para o estado ${event.estado.nome}');
          emit(CadastroError('Nenhum bloco encontrado para o estado ${event.estado.nome}'));
          return;
        }

        print('Emitindo estado CadastroEtapa2 com blocos');
        emit(CadastroEtapa2(
          nome: currentState.nome,
          email: currentState.email,
          whatsapp: currentState.whatsapp,
          senha: currentState.senha,
          foto: currentState.foto,
          estados: currentState.estados,
          estadoSelecionado: event.estado,
          blocos: blocos,
          regioes: const [],
          igrejas: const [],
        ));
      } catch (e, stackTrace) {
        print('Erro ao carregar blocos: $e');
        print('Stack trace: $stackTrace');
        emit(CadastroError(e.toString()));
      }
    }
  }

  Future<void> _onCadastroBlocoSelecionado(
    CadastroBlocoSelecionado event,
    Emitter<CadastroState> emit,
  ) async {
    if (state is CadastroEtapa2) {
      final currentState = state as CadastroEtapa2;
      try {
        print('Buscando regiões para o bloco: ${event.bloco.nome}');
        final regioes = await _cadastroService.getRegioesPorBloco(event.bloco.id);
        print('Regiões encontradas: ${regioes.length}');

        if (regioes.isEmpty) {
          print('Nenhuma região encontrada para o bloco ${event.bloco.nome}');
          emit(CadastroError('Nenhuma região encontrada para o bloco ${event.bloco.nome}'));
          return;
        }

        print('Emitindo estado CadastroEtapa2 com regiões');
        emit(CadastroEtapa2(
          nome: currentState.nome,
          email: currentState.email,
          whatsapp: currentState.whatsapp,
          senha: currentState.senha,
          foto: currentState.foto,
          estados: currentState.estados,
          estadoSelecionado: currentState.estadoSelecionado,
          blocos: currentState.blocos,
          blocoSelecionado: event.bloco,
          regioes: regioes,
          igrejas: const [],
        ));
      } catch (e, stackTrace) {
        print('Erro ao carregar regiões: $e');
        print('Stack trace: $stackTrace');
        emit(CadastroError(e.toString()));
      }
    }
  }

  Future<void> _onCadastroRegiaoSelecionada(
    CadastroRegiaoSelecionada event,
    Emitter<CadastroState> emit,
  ) async {
    if (state is CadastroEtapa2) {
      final currentState = state as CadastroEtapa2;
      try {
        print('Buscando igrejas para a região: ${event.regiao.nome}');
        final igrejas = await _cadastroService.getIgrejasPorRegiao(event.regiao.id);
        print('Igrejas encontradas: ${igrejas.length}');

        if (igrejas.isEmpty) {
          print('Nenhuma igreja encontrada para a região ${event.regiao.nome}');
          emit(CadastroError('Nenhuma igreja encontrada para a região ${event.regiao.nome}'));
          return;
        }

        print('Emitindo estado CadastroEtapa2 com igrejas');
        emit(CadastroEtapa2(
          nome: currentState.nome,
          email: currentState.email,
          whatsapp: currentState.whatsapp,
          senha: currentState.senha,
          foto: currentState.foto,
          estados: currentState.estados,
          estadoSelecionado: currentState.estadoSelecionado,
          blocos: currentState.blocos,
          blocoSelecionado: currentState.blocoSelecionado,
          regioes: currentState.regioes,
          regiaoSelecionada: event.regiao,
          igrejas: igrejas,
        ));
      } catch (e, stackTrace) {
        print('Erro ao carregar igrejas: $e');
        print('Stack trace: $stackTrace');
        emit(CadastroError(e.toString()));
      }
    }
  }

  Future<void> _onCadastroIgrejaSelecionada(
    CadastroIgrejaSelecionada event,
    Emitter<CadastroState> emit,
  ) async {
    if (state is CadastroEtapa2) {
      final currentState = state as CadastroEtapa2;
      if (currentState.estadoSelecionado != null &&
          currentState.blocoSelecionado != null &&
          currentState.regiaoSelecionada != null) {
        emit(CadastroEtapa3(
          nome: currentState.nome,
          email: currentState.email,
          whatsapp: currentState.whatsapp,
          senha: currentState.senha,
          foto: currentState.foto,
          estado: currentState.estadoSelecionado!,
          bloco: currentState.blocoSelecionado!,
          regiao: currentState.regiaoSelecionada!,
          igreja: event.igreja,
        ));
      }
    }
  }

  Future<void> _onCadastroFinalizado(
    CadastroFinalizado event,
    Emitter<CadastroState> emit,
  ) async {
    if (state is CadastroEtapa3) {
      final currentState = state as CadastroEtapa3;
      try {
        emit(CadastroLoading());
        final fotoUrl = await _cadastroService.uploadFoto(currentState.foto);
        await _cadastroService.criarPerfil(
          nome: currentState.nome,
          email: currentState.email,
          whatsapp: currentState.whatsapp,
          fotoUrl: fotoUrl,
          igrejaId: currentState.igreja.id,
        );
        emit(CadastroSuccess());
      } catch (e) {
        emit(CadastroError(e.toString()));
      }
    }
  }

  Future<void> _onCadastroConfirmarEmail(
    CadastroConfirmarEmail event,
    Emitter<CadastroState> emit,
  ) async {
    try {
      final authService = AuthService();
      await authService.signIn(
        email: event.email,
        password: event.senha,
      );
      final estados = await _cadastroService.getEstados();
      emit(CadastroEtapa2(
        nome: '', // O nome, whatsapp e foto devem ser recuperados do estado anterior na tela
        email: event.email,
        whatsapp: '',
        senha: event.senha,
        foto: Uint8List(0),
        estados: estados,
        blocos: const [],
        regioes: const [],
        igrejas: const [],
      ));
    } catch (e) {
      emit(CadastroError('E-mail ainda não confirmado ou erro ao autenticar. Por favor, confirme seu e-mail e tente novamente.'));
    }
  }
} 