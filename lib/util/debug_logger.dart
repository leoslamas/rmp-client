import 'package:flutter/foundation.dart';

class DebugLogger {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}