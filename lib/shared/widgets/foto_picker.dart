import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FotoPicker extends StatelessWidget {
  final Uint8List? foto;
  final Function(Uint8List) onFotoSelecionada;

  const FotoPicker({
    super.key,
    this.foto,
    required this.onFotoSelecionada,
  });

  Future<void> _mostrarOpcoesFoto(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarFoto(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarFoto(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selecionarFoto(BuildContext context, ImageSource source) async {
    try {
      // Verifica e solicita permissões
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.storage,
        Permission.camera,
      ].request();

      bool hasPermission = source == ImageSource.camera
          ? statuses[Permission.camera]?.isGranted ?? false
          : statuses[Permission.photos]?.isGranted ?? false;

      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Permissão para acessar a câmera é necessária'
                    : 'Permissão para acessar a galeria é necessária',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Abre o seletor de imagens
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        onFotoSelecionada(bytes);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarOpcoesFoto(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(60),
          image: foto != null
              ? DecorationImage(
                  image: MemoryImage(foto!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: foto == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adicionar foto',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
} 