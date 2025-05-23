import 'package:flutter/material.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/ingresso_service.dart';
import '../../../shared/services/evento_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/ingresso_model.dart';
import '../../../shared/models/evento_model.dart';
import '../../../shared/models/igreja_model.dart';
import '../../../shared/widgets/background_image.dart';
import '../../eventos/ingresso_digital_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/ingresso_ticket.dart';
import 'dart:ui' as ui;
import 'dart:async';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UserModel? _user;
  String? _nomeIgreja;
  List<IngressoModel> _ingressos = [];
  bool _loading = true;
  final Map<String, GlobalKey> _ingressoKeys = {};
  final Map<String, EventoModel> _eventosMap = {};

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final user = await AuthService().getCurrentUser();
    String? nomeIgreja;
    if (user?.igrejaId != null) {
      nomeIgreja = await EventoService().buscarNomeIgreja(user!.igrejaId!);
    }
    // Buscar ingressos do usuário
    final ingressos = user != null
        ? await IngressoService().buscarIngressosDoUsuario(user.id)
        : <IngressoModel>[];
    // Buscar todos os eventos e montar o mapa
    final eventos = await EventoService().listarEventos();
    final eventosMap = {for (var e in eventos) e.id!: e};
    // Inicializa uma key para cada ingresso
    for (final ingresso in ingressos) {
      _ingressoKeys[ingresso.id] = GlobalKey();
    }
    setState(() {
      _user = user;
      _nomeIgreja = nomeIgreja;
      _ingressos = ingressos;
      _eventosMap.clear();
      _eventosMap.addAll(eventosMap);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Container(
            child: Image.asset('assets/images/logo_tickts.png', height: 38, fit: BoxFit.contain),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: _user?.photoUrl != null && _user!.photoUrl!.isNotEmpty
                              ? NetworkImage(_user!.photoUrl!)
                              : null,
                          child: _user?.photoUrl == null || _user!.photoUrl!.isEmpty
                              ? const Icon(Icons.person, size: 48, color: Color(0xFF833ab4))
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Icon(Icons.person, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                _user?.name ?? '',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.email, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _user?.email ?? '',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_user?.whatsapp != null && _user!.whatsapp!.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _user!.whatsapp!,
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          if (_nomeIgreja != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.church, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _nomeIgreja!,
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.12),
                      ),
                      child: const Text(
                        'Meus Ingressos',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_ingressos.isEmpty)
                      const Text('Nenhum ingresso gerado ainda.', style: TextStyle(color: Colors.white)),
                    ..._ingressos.map((ingresso) => Stack(
                          children: [
                            Card(
                              color: Colors.white.withOpacity(0.92),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              child: ListTile(
                                leading: const Icon(Icons.confirmation_num, color: Color(0xFF833ab4)),
                                title: Text('Ingresso Nº ${ingresso.numeroIngresso}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Status: ${ingresso.status}\nData: ${ingresso.dataCompra.day.toString().padLeft(2, '0')}/${ingresso.dataCompra.month.toString().padLeft(2, '0')}/${ingresso.dataCompra.year}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Color(0xFF833ab4)),
                                      tooltip: 'Visualizar',
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => IngressoDigitalScreen(ingressoId: ingresso.id),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.download, color: Color(0xFF833ab4)),
                                      tooltip: 'Baixar',
                                      onPressed: () async {
                                        await _baixarIngressoCompleto(context, ingresso);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share, color: Color(0xFF833ab4)),
                                      tooltip: 'Compartilhar',
                                      onPressed: () async {
                                        await _compartilharIngresso(context, ingresso);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_eventosMap[ingresso.eventoId] != null)
                              Positioned(
                                top: -1000,
                                child: Container(
                                  width: 350,
                                  height: 600,
                                  child: Opacity(
                                    opacity: 0.01,
                                    child: IgnorePointer(
                                      child: RepaintBoundary(
                                        key: _ingressoKeys[ingresso.id],
                                        child: Builder(
                                          builder: (context) {
                                            final evento = _eventosMap[ingresso.eventoId]!;
                                            final participante = ingresso.nomeUsuario ?? 'Não informado';
                                            final dataFormatada = DateFormat('dd "de" MMMM "de" yyyy', 'pt_BR').format(evento.dataInicio);
                                            final horaFormatada = DateFormat('HH:mm').format(evento.dataInicio) + 'h';
                                            return IngressoTicket(
                                              titulo: 'Confirmação de ingresso',
                                              numeroIngresso: ingresso.numeroIngresso,
                                              nomeEvento: evento.titulo,
                                              participante: participante,
                                              data: dataFormatada,
                                              hora: horaFormatada,
                                              qrData: ingresso.codigoQr ?? '',
                                              logoUrl: evento.logoEvento ?? '',
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _baixarIngressoCompleto(BuildContext context, IngressoModel ingresso) async {
    try {
      // Permissão
      PermissionStatus status;
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão para salvar imagens negada.')),
        );
        return;
      }
      // Garante que o widget foi renderizado
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 200));
      final key = _ingressoKeys[ingresso.id];
      if (key == null || key.currentContext == null) throw Exception('Erro ao acessar o ingresso para download.');
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(pngBytes, quality: 100, name: 'ingresso_${ingresso.numeroIngresso}_${DateTime.now().millisecondsSinceEpoch}');
      if (result['isSuccess'] == true || result['isSuccess'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresso salvo na galeria!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar ingresso.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar ingresso: $e')),
      );
    }
  }

  Future<void> _compartilharIngresso(BuildContext context, IngressoModel ingresso) async {
    try {
      if (ingresso.codigoQr == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code não disponível para este ingresso'),
          ),
        );
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ingresso_${ingresso.numeroIngresso}.png');
      
      await QrPainter(
        data: ingresso.codigoQr!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ).toImageData(200).then((imageData) async {
        if (imageData != null) {
          final buffer = imageData.buffer;
          await file.writeAsBytes(
            buffer.asUint8List(imageData.offsetInBytes, imageData.lengthInBytes),
          );
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Meu ingresso',
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao compartilhar ingresso: $e'),
        ),
      );
    }
  }
} 