import 'package:flutter/material.dart';

class ModalUtils {
  static Future<T?> showFullScreenModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color backgroundColor = Colors.transparent,
    double borderRadius = 20,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: child,
          ),
        ),
      ),
    );
  }
}
