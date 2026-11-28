import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/connection_state.dart';
import '../state/hosts_state.dart';

const _channel = MethodChannel('io.github.ccch1mneyyy.dsh_app/remote_background');

final _remotePhaseProvider = Provider.autoDispose((ref) {
  final host = ref.watch(activeHostProvider);
  final phase = host.isLocal
      ? null
      : ref.watch(hostLinkStatusProvider(host).select((s) => s.isLoading || s.hasError ? null : s.value?.phase));
  return (host, phase);
});

/// Keeps only an established remote link alive, including recovery on that same host.
final remoteBackgroundProvider = Provider.autoDispose<void>((ref) {
  if (defaultTargetPlatform != TargetPlatform.android) return;

  Future<void> report(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setRemoteActive', enabled);
    } on PlatformException catch (error) {
      debugPrint('Remote background protection: ${error.code}');
    }
  }

  var active = false;
  ref.listen(_remotePhaseProvider, (previous, next) {
    final (host, phase) = next;
    final armed =
        phase == HostLinkPhase.connected || phase == HostLinkPhase.reconnecting && active && previous?.$1 == host;
    if (active == armed) return;
    active = armed;
    unawaited(report(active));
  }, fireImmediately: true);
  ref.onDispose(() {
    if (active) unawaited(report(false));
  });
});
