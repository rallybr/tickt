import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final Widget child;

  const BackgroundImage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgapp.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
} 