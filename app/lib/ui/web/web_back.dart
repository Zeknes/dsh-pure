import 'dart:async';

/// Where one press of back went.
enum WebBackOutcome {
  /// The WebView went back in its history.
  history,

  /// Off the page, or out of the app.
  leave,

  /// The page went away while the press waited its turn: nothing to do.
  dropped,
}

/// Serializes back presses so each moves at most one history step.
class WebBackDispatcher {
  WebBackDispatcher({required this.canGoBack, required this.goBack, required this.leave, this.isActive});

  final Future<bool> Function() canGoBack;
  final Future<void> Function() goBack;
  final Future<void> Function() leave;

  /// False once the page is gone: presses still queued are dropped.
  final bool Function()? isActive;

  Future<void> _last = Future<void>.value();

  /// One press of back; completes with where it went once it got there.
  Future<WebBackOutcome> press() {
    final done = _last.then((_) => _step());
    _last = done.then<void>((_) {}, onError: (_) {});
    return done;
  }

  Future<WebBackOutcome> _step() async {
    if (!(isActive?.call() ?? true)) return WebBackOutcome.dropped;
    var history = false;
    try {
      history = await canGoBack();
    } catch (_) {}
    if (!(isActive?.call() ?? true)) return WebBackOutcome.dropped;
    if (history) {
      await goBack();
      return WebBackOutcome.history;
    }
    await leave();
    return WebBackOutcome.leave;
  }
}
