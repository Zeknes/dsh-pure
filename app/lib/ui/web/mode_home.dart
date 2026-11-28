import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../runtime/runtime_state.dart';
import '../../state/ui_mode_state.dart';
import '../shell/home_shell.dart';
import '../shell/page_frame.dart';
import '../theme/app_icons.dart';
import 'web_view_page.dart';

/// Native and the official local DSH Web home, without the removed web plugin shell.
class ModeHome extends ConsumerWidget {
  const ModeHome({super.key, this.native});

  final Widget? native;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(uiModeProvider);
    final runtime = ref.watch(localRuntimeProvider.select((s) => s.status));
    if (mode.loaded && mode.mode == UiMode.web && runtime.isRunning) {
      return WebViewPage(
        key: ValueKey(runtime.token),
        url: Uri.parse(runtime.baseUrl!).replace(path: '/', queryParameters: {'token': runtime.token!}),
        title: context.l10n.webTitle,
        subtitle: context.l10n.commonThisPhone,
        externalDisabledReason: context.l10n.webLocalAppOnly,
        onSwitchToNative: () => unawaited(ref.read(uiModeProvider.notifier).set(UiMode.native)),
      );
    }
    return native ?? const HomeShell();
  }
}

class WebModeKey extends ConsumerWidget {
  const WebModeKey({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => GlassIconButton(
    icon: AppIcons.swap,
    tooltip: context.l10n.webSwitchToWeb,
    size: 36,
    onPressed: () => unawaited(ref.read(uiModeProvider.notifier).set(UiMode.web)),
  );
}
