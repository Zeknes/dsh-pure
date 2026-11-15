import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dsh_app/ui/chat/voice/voice_notice.dart';

void main() {
  testWidgets('voice notice passes taps through and expires', (tester) async {
    final notice = VoiceNotice();
    var taps = 0;
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return SizedBox.expand(
                child: TextButton(onPressed: () => taps++, child: const Text('under')),
              );
            },
          ),
        ),
      ),
    );
    notice.show(context, '没有听清，再说一次');
    await tester.pump();
    await tester.tapAt(tester.getCenter(find.text('没有听清，再说一次')));
    expect(taps, 1);
    await tester.pump(const Duration(milliseconds: 1499));
    expect(find.text('没有听清，再说一次'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('没有听清，再说一次'), findsNothing);
  });

  testWidgets('new notice replaces the previous timer and does not queue', (tester) async {
    final notice = VoiceNotice();
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    notice.show(context, 'first');
    await tester.pump(const Duration(milliseconds: 1000));
    notice.show(context, 'second');
    await tester.pump();
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('second'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('second'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('first'), findsNothing);
  });
}
