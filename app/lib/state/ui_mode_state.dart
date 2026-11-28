import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UiMode { native, web }

class UiModeState {
  const UiModeState({this.mode = UiMode.native, this.loaded = false});
  final UiMode mode;
  final bool loaded;
}

class UiModeController extends Notifier<UiModeState> {
  static const key = 'ui.mode';

  @override
  UiModeState build() {
    unawaited(_load());
    return const UiModeState();
  }

  Future<void> _load() async {
    var mode = UiMode.native;
    try {
      final prefs = await SharedPreferences.getInstance();
      mode = UiMode.values.asNameMap()[prefs.getString(key)] ?? UiMode.native;
    } catch (_) {}
    if (!state.loaded) state = UiModeState(mode: mode, loaded: true);
  }

  Future<void> set(UiMode mode) async {
    state = UiModeState(mode: mode, loaded: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, mode.name);
    } catch (_) {}
  }
}

final uiModeProvider = NotifierProvider<UiModeController, UiModeState>(UiModeController.new);
