import 'package:dsh_app/ui/web/web_back.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('back walks history, then leaves, one press at a time', () async {
    var history = 2;
    var left = 0;
    final dispatcher = WebBackDispatcher(
      canGoBack: () async => history > 0,
      goBack: () async {
        history--;
      },
      leave: () async {
        left++;
      },
    );
    expect(await Future.wait([dispatcher.press(), dispatcher.press(), dispatcher.press()]), [
      WebBackOutcome.history,
      WebBackOutcome.history,
      WebBackOutcome.leave,
    ]);
    expect(history, 0);
    expect(left, 1);
  });
}
