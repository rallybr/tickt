import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../shared/utils/responsive_utils.dart';
import '../../shared/services/ingresso_service.dart';
import '../../shared/widgets/background_image.dart';

class LeitorQrScreen extends StatefulWidget {
  const LeitorQrScreen({super.key});

  @override
  State<LeitorQrScreen> createState() => _LeitorQrScreenState();
}

class _LeitorQrScreenState extends State<LeitorQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedData;

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Botão de voltar
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              // Logo do App
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Image.asset(
                  'assets/images/logo_tickts.png',
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),

              // Área da Câmera
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth * 0.8;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: Stack(
                          children: [
                            // Scanner
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: MobileScanner(
                                controller: controller,
                                onDetect: (capture) async {
                                  if (_isProcessing) return;
                                  
                                  final List<Barcode> barcodes = capture.barcodes;
                                  if (barcodes.isEmpty) return;

                                  setState(() {
                                    _isProcessing = true;
                                    _lastScannedData = barcodes.first.rawValue;
                                  });

                                  try {
                                    final String? codigoQr = barcodes.first.rawValue;
                                    if (codigoQr == null) {
                                      _showError('QR Code inválido');
                                      return;
                                    }

                                    final result = await IngressoService().validarIngresso(codigoQr);
                                    if (!mounted) return;

                                    if (result['success']) {
                                      _showSuccess(result['message']);
                                    } else {
                                      _showError(result['message']);
                                    }
                                  } catch (e) {
                                    if (!mounted) return;
                                    _showError('Erro ao processar QR Code: $e');
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isProcessing = false);
                                    }
                                  }
                                },
                              ),
                            ),

                            // Borda do Scanner
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 8,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            // Marcadores de Canto
                            ...List.generate(4, (index) {
                              final isTop = index < 2;
                              final isLeft = index % 2 == 0;
                              return Positioned(
                                top: isTop ? 0 : null,
                                bottom: isTop ? null : 0,
                                left: isLeft ? 0 : null,
                                right: isLeft ? null : 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: isTop ? const BorderSide(color: Colors.white, width: 10) : BorderSide.none,
                                      bottom: isTop ? BorderSide.none : const BorderSide(color: Colors.white, width: 10),
                                      left: isLeft ? const BorderSide(color: Colors.white, width: 10) : BorderSide.none,
                                      right: isLeft ? BorderSide.none : const BorderSide(color: Colors.white, width: 10),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.6),
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                        offset: const Offset(-2, -2),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.6),
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Área de Dados
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isProcessing)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else if (_lastScannedData != null)
                      Text(
                        _lastScannedData!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      const Text(
                        'Posicione o QR Code dentro da área',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              // Botão para limpar dados e ler próximo QR code
              if (_lastScannedData != null && !_isProcessing)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ler próximo QR Code'),
                    onPressed: () {
                      setState(() {
                        _lastScannedData = null;
                      });
                    },
                  ),
                ),

              // Controles da Câmera
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white, size: 28),
                      onPressed: () => controller.toggleTorch(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                      onPressed: () => controller.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
} 