import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget que muestra texto con efecto máquina de escribir y vibración haptic.
class TypewriterText extends StatefulWidget {
  /// El texto a mostrar.
  final String text;

  /// Duración entre cada carácter.
  final Duration charDuration;

  /// Si se debe activar vibración haptic por cada carácter.
  final bool enableHaptic;

  /// Callback cuando el texto termina de escribirse.
  final VoidCallback? onComplete;

  /// Estilo del texto.
  final TextStyle? style;

  /// Alineación del texto.
  final TextAlign textAlign;

  /// Si debe empezar automáticamente.
  final bool autoStart;

  const TypewriterText({
    super.key,
    required this.text,
    this.charDuration = const Duration(milliseconds: 50),
    this.enableHaptic = true,
    this.onComplete,
    this.style,
    this.textAlign = TextAlign.center,
    this.autoStart = true,
  });

  @override
  State<TypewriterText> createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _timer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _startTypewriter();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Inicia el efecto de máquina de escribir.
  void start() {
    _reset();
    _startTypewriter();
  }

  /// Resetea el estado.
  void _reset() {
    _timer?.cancel();
    setState(() {
      _displayedText = '';
      _charIndex = 0;
      _isComplete = false;
    });
  }

  void _startTypewriter() {
    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _charIndex + 1);
          _charIndex++;
        });

        // Vibración haptic por cada carácter
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
      } else {
        timer.cancel();
        _isComplete = true;
        widget.onComplete?.call();
      }
    });
  }

  /// Completa el texto inmediatamente sin animación.
  void complete() {
    _timer?.cancel();
    setState(() {
      _displayedText = widget.text;
      _charIndex = widget.text.length;
      _isComplete = true;
    });
    widget.onComplete?.call();
  }

  bool get isComplete => _isComplete;

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
