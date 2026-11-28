import 'package:dsh_app/state/ui_mode_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('UI mode restores the saved web choice and can return to native', () async {
    SharedPreferences.setMockInitialValues({UiModeController.key: UiMode.web.name});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(uiModeProvider).mode, UiMode.native);
    while (!container.read(uiModeProvider).loaded) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(container.read(uiModeProvider).mode, UiMode.web);
    await container.read(uiModeProvider.notifier).set(UiMode.native);
    await container.read(uiModeProvider.notifier).set(UiMode.web);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(uiModeProvider).mode, UiMode.web);
    await container.read(uiModeProvider.notifier).set(UiMode.native);
    expect(container.read(uiModeProvider).mode, UiMode.native);
    expect((await SharedPreferences.getInstance()).getString(UiModeController.key), UiMode.native.name);
  });
}
