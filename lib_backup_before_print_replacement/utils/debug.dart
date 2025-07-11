import 'package:flutter/foundation.dart';

void debugPrintOnly(Object? message) {
  if (kDebugMode) {
    print(message);
  }
}
