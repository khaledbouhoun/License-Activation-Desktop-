import 'package:flutter/material.dart';
import 'package:softel_control/core/constant/app_theme.dart';
import 'package:window_manager/window_manager.dart';

class ModernTopBar extends StatelessWidget {
  const ModernTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 40, // Standard modern height
        color: AppTheme.surfaceDark.withValues(alpha: 0.3),
        child: Row(
          children: [
            const SizedBox(width: 15),
            const Text(
              "Softel Control",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Native-looking Minimize Button
            WindowCaptionButton.minimize(
              brightness: Brightness.dark,
              onPressed: () => windowManager.minimize(),
            ),
            // Native-looking Close Button
            WindowCaptionButton.close(
              brightness: Brightness.dark,
              onPressed: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }
}
