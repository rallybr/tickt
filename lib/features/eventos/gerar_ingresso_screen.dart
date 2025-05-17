import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class GerarIngressoScreen extends StatefulWidget {
  final String eventoId;
  final String eventoNome;

  const GerarIngressoScreen({
    super.key,
    required this.eventoId,
    required this.eventoNome,
  });

  @override
  State<GerarIngressoScreen> createState() => _GerarIngressoScreenState();
}

class _GerarIngressoScreenState extends State<GerarIngressoScreen> {
  String? _qrCodeData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gerarIngresso();
  }

  Future<void> _gerarIngresso() async {
    setState(() => _isLoading = true);

    try {
      // Gerar um código único para o ingresso
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ingressoId = '${widget.eventoId}_$timestamp';
      
      // Criar dados do QR Code
      _qrCodeData = 'INGRESSO:$ingressoId:${widget.eventoId}';
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar ingresso: $e')),
        );
      }
    }
  }

  Future<void> _compartilharIngresso() async {
    if (_qrCodeData == null) return;

    try {
      // Verificar permissão de armazenamento
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de armazenamento necessária')),
          );
        }
        return;
      }

      // Obter diretório temporário
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ingresso_qr.png');

      // Gerar imagem do QR Code usando QrPainter.withQr
      final qrValidationResult = QrValidator.validate(
        data: _qrCodeData!,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: true,
        );
        final imageData = await painter.toImageData(200);
        if (imageData == null) return;
        final buffer = imageData.buffer;
        await file.writeAsBytes(
          buffer.asUint8List(imageData.offsetInBytes, imageData.lengthInBytes),
        );
        // Compartilhar arquivo
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Meu ingresso para ${widget.eventoNome}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Ingresso'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF833ab4),
              Color(0xFFfd1d1d),
              Color(0xFFfcb045),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Seu Ingresso',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.eventoNome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              if (_qrCodeData != null)
                                QrImageView(
                                  data: _qrCodeData!,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                ),
                              const SizedBox(height: 24),
                              const Text(
                                'Apresente este QR Code na entrada do evento',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _compartilharIngresso,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF833ab4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text(
                            'Compartilhar Ingresso',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
} 