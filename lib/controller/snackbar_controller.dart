import 'package:flutter/material.dart';

class Snackbar {
  void showCustomSnackBar({
    required BuildContext context,
    required String message,
    required bool isSuccess,
    VoidCallback? onButtonPressed,
    String buttonText = 'OK',
    Duration duration = const Duration(seconds: 5),
  }) {
    final Color primaryColor = isSuccess
        ? const Color.fromRGBO(49, 73, 111, 1) // Blue for success
        : Colors.red; // Red for error

    final IconData iconData = isSuccess ? Icons.check : Icons.error_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        margin: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onButtonPressed ??
                  () {
                    // Ensure the widget is still mounted before using context
                    if (!context.mounted)
                      return; // Avoid accessing context if widget is disposed

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: primaryColor,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
