import 'package:flutter/foundation.dart';

class LoadingOverlayController {
  LoadingOverlayController._();
  static final LoadingOverlayController instance = LoadingOverlayController._();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  void show() => isLoading.value = true;
  void hide() => isLoading.value = false;
}
