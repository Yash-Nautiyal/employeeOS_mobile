import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showCustomToast({
  required BuildContext context,
  required ToastificationType type,
  required String title,
  required String description,
}) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.fillColored,
    title: Text(title),
    description: Text(description),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 4),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    borderRadius: BorderRadius.circular(12.0),
    dragToClose: true,
    pauseOnHover: false,
    applyBlurEffect: true,
  );
}
