import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cadastro_bloc.dart';
import '../../../shared/widgets/foto_picker.dart';
import '../../../shared/services/cadastro_service.dart';
import '../../../shared/models/models.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CadastroBloc(
        cadastroService: CadastroService(),
      )..add(CadastroIniciado()),
      child: BlocBuilder<CadastroBloc, CadastroState>(
        builder: (context, state) {
          if (state is CadastroInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CadastroEtapa1) {
            return const _Etapa1Form();
          }

          if (state is CadastroEtapa2) {
            return _Etapa2Form(
              nome: state.nome,
              email: state.email,
              whatsapp: state.whatsapp,
              foto: state.foto,
              estados: state.estados,
              estadoSelecionado: state.estadoSelecionado,
              blocos: state.blocos,
              blocoSelecionado: state.blocoSelecionado,
              regioes: state.regioes,
              regiaoSelecionada: state.regiaoSelecionada,
              igrejas: state.igrejas,
              igrejaSelecionada: state.igrejaSelecionada,
            );
          }

          if (state is CadastroEtapa3) {
            return _Etapa3Form(
              nome: state.nome,
              email: state.email,
              whatsapp: state.whatsapp,
              foto: state.foto,
              estado: state.estado,
              bloco: state.bloco,
              regiao: state.regiao,
              igreja: state.igreja,
            );
          }

          if (state is CadastroLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CadastroError) {
            return Scaffold(
              body: Center(
                child: Text('Erro: ${state.message}'),
              ),
            );
          }

          if (state is CadastroSuccess) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Cadastro realizado com sucesso!',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Voltar para o login'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CadastroAguardandoConfirmacaoEmail) {
            return Scaffold(
              appBar: AppBar(title: const Text('Confirme seu e-mail')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.email_outlined, size: 64, color: Colors.blue),
                      const SizedBox(height: 24),
                      const Text(
                        'Enviamos um link de confirmação para o seu e-mail.\n\nPor favor, confirme seu e-mail antes de continuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CadastroBloc>().add(
                            CadastroConfirmarEmail(state.email, state.senha),
                          );
                        },
                        child: const Text('Já confirmei meu e-mail'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Etapa1Form extends StatefulWidget {
  const _Etapa1Form();

  @override
  State<_Etapa1Form> createState() => _Etapa1FormState();
}

class _Etapa1FormState extends State<_Etapa1Form> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _senhaController = TextEditingController();
  Uint8List? _foto;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _proximo() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_foto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione uma foto'),
          ),
        );
        return;
      }

      context.read<CadastroBloc>().add(
            CadastroEtapa1Completa(
              nome: _nomeController.text,
              email: _emailController.text,
              whatsapp: _whatsappController.text,
              senha: _senhaController.text,
              foto: _foto!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - Etapa 1'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: FotoPicker(
                  foto: _foto,
                  onFotoSelecionada: (foto) {
                    setState(() {
                      _foto = foto;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu WhatsApp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _proximo,
                child: const Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etapa2Form extends StatelessWidget {
  final String nome;
  final String email;
  final String whatsapp;
  final Uint8List foto;
  final List<EstadoModel> estados;
  final EstadoModel? estadoSelecionado;
  final List<BlocoModel> blocos;
  final BlocoModel? blocoSelecionado;
  final List<RegiaoModel> regioes;
  final RegiaoModel? regiaoSelecionada;
  final List<IgrejaModel> igrejas;
  final IgrejaModel? igrejaSelecionada;

  const _Etapa2Form({
    required this.nome,
    required this.email,
    required this.whatsapp,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - Etapa 2'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<EstadoModel>(
              value: estadoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
              items: estados.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(estado.nome),
                );
              }).toList(),
              onChanged: (estado) {
                if (estado != null) {
                  context.read<CadastroBloc>().add(
                        CadastroEstadoSelecionado(estado),
                      );
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecione um estado';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BlocoModel>(
              value: blocoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Bloco',
                prefixIcon: Icon(Icons.grid_view_outlined),
                border: OutlineInputBorder(),
              ),
              items: blocos.map((bloco) {
                return DropdownMenuItem(
                  value: bloco,
                  child: Text(bloco.nome),
                );
              }).toList(),
              onChanged: estadoSelecionado != null
                  ? (bloco) {
                      if (bloco != null) {
                        context.read<CadastroBloc>().add(
                              CadastroBlocoSelecionado(bloco),
                            );
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecione um bloco';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RegiaoModel>(
              value: regiaoSelecionada,
              decoration: const InputDecoration(
                labelText: 'Região',
                prefixIcon: Icon(Icons.map_outlined),
                border: OutlineInputBorder(),
              ),
              items: regioes.map((regiao) {
                return DropdownMenuItem(
                  value: regiao,
                  child: Text(regiao.nome),
                );
              }).toList(),
              onChanged: blocoSelecionado != null
                  ? (regiao) {
                      if (regiao != null) {
                        context.read<CadastroBloc>().add(
                              CadastroRegiaoSelecionada(regiao),
                            );
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecione uma região';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IgrejaModel>(
              value: igrejaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Igreja',
                prefixIcon: Icon(Icons.church_outlined),
                border: OutlineInputBorder(),
              ),
              items: igrejas.map((igreja) {
                return DropdownMenuItem(
                  value: igreja,
                  child: Text(igreja.nome),
                );
              }).toList(),
              onChanged: regiaoSelecionada != null
                  ? (igreja) {
                      if (igreja != null) {
                        context.read<CadastroBloc>().add(
                              CadastroIgrejaSelecionada(igreja),
                            );
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecione uma igreja';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: estadoSelecionado != null &&
                      blocoSelecionado != null &&
                      regiaoSelecionada != null &&
                      igrejaSelecionada != null
                  ? () {
                      context.read<CadastroBloc>().add(
                            CadastroIgrejaSelecionada(igrejaSelecionada!),
                          );
                    }
                  : null,
              child: const Text('Próximo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etapa3Form extends StatelessWidget {
  final String nome;
  final String email;
  final String whatsapp;
  final Uint8List foto;
  final EstadoModel estado;
  final BlocoModel bloco;
  final RegiaoModel regiao;
  final IgrejaModel igreja;

  const _Etapa3Form({
    required this.nome,
    required this.email,
    required this.whatsapp,
    required this.foto,
    required this.estado,
    required this.bloco,
    required this.regiao,
    required this.igreja,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - Etapa 3'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Confirme seus dados:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _InfoCard(
              title: 'Dados Pessoais',
              items: [
                _InfoItem(icon: Icons.person_outline, label: 'Nome', value: nome),
                _InfoItem(icon: Icons.email_outlined, label: 'E-mail', value: email),
                _InfoItem(icon: Icons.phone_outlined, label: 'WhatsApp', value: whatsapp),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Localização',
              items: [
                _InfoItem(icon: Icons.location_city_outlined, label: 'Estado', value: estado.nome),
                _InfoItem(icon: Icons.grid_view_outlined, label: 'Bloco', value: bloco.nome),
                _InfoItem(icon: Icons.map_outlined, label: 'Região', value: regiao.nome),
                _InfoItem(icon: Icons.church_outlined, label: 'Igreja', value: igreja.nome),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<CadastroBloc>().add(CadastroFinalizado());
              },
              child: const Text('Confirmar Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 