// import 'package:flutter/material.dart';
//
// class SnackbarUtils {
//   /// ✅ Show Success Snackbar
//   static void showSuccess(BuildContext context, String message) {
//     _showCustomSnackbar(
//       context,
//       message,
//       Colors.green,
//       Icons.check_circle,
//     );
//   }
//
//   /// ❌ Show Error Snackbar
//   static void showError(BuildContext context, String message) {
//     _showCustomSnackbar(
//       context,
//       message,
//       Colors.red,
//       Icons.error,
//     );
//   }
//
//   /// ℹ️ Show Info Snackbar
//   static void showInfo(BuildContext context, String message) {
//     _showCustomSnackbar(
//       context,
//       message,
//       Colors.blue,
//       Icons.info,
//     );
//   }
//
//   /// 🔥 Core Snackbar Builder
//   static void _showCustomSnackbar(
//       BuildContext context,
//       String message,
//       Color color,
//       IconData icon,
//       ) {
//     final snackBar = SnackBar(
//       behavior: SnackBarBehavior.floating,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       duration: const Duration(seconds: 2),
//       content: TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0.0, end: 1.0),
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOutBack,
//         builder: (context, value, child) {
//           return Transform.scale(
//             scale: value,
//             child: child,
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.4),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: Colors.white, size: 22),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }
// }

import 'package:flutter/material.dart';

class SnackbarUtils {
  /// ✅ Show Success Snackbar
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.green,
      Icons.check_circle,
    );
  }

  /// ❌ Show Error Snackbar
  static void showError(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.red,
      Icons.error,
    );
  }

  /// ℹ️ Show Info Snackbar
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message,
      Colors.blue,
      Icons.info,
    );
  }

  /// 🔹 Generic Snackbar for service calls
  /// [isError] determines color and icon automatically
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    _showCustomSnackbar(
      context,
      message,
      isError ? Colors.red : Colors.green,
      isError ? Icons.error : Icons.check_circle,
    );
  }

  /// 🔥 Core Snackbar Builder
  static void _showCustomSnackbar(
      BuildContext context,
      String message,
      Color color,
      IconData icon,
      ) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 2),
      content: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

