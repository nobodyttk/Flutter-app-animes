import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int trimLines; // Número de linhas para mostrar quando recolhido

  const ExpandableTextWidget({
    Key? key,
    required this.text,
    this.trimLines = 4, // Padrão de 4 linhas
  }) : super(key: key);

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para evitar o "RenderFlex overflowed", vamos garantir que o botão
    // só apareça se o texto realmente precisar ser cortado.
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: Theme.of(context).textTheme.bodyLarge),
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32); // 16px de padding de cada lado

    final bool isTextOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O widget AnimatedSize fará a transição de altura ser suave
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            // Se não estiver expandido, limita as linhas e mostra "..."
            maxLines: _isExpanded ? null : widget.trimLines,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        
        // Só mostra o botão "Ler mais" se o texto for grande o suficiente
        if (isTextOverflowing)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Alinha o botão à direita
                children: [
                  Text(
                    _isExpanded ? 'Ler menos' : 'Ler mais',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary, // Usa a cor primária do tema
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}