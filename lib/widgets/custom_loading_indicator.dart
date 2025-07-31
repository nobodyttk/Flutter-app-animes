// lib/widgets/custom_loading_indicator.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? width;
  final double? height;

  const CustomLoadingIndicator({
    Key? key,
    this.width = 150, // Tamanho padrão
    this.height = 150, // Tamanho padrão
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/Loading.json',
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}