import 'dart:async';

import 'package:flutter/material.dart';

class VoiceNotice {
  OverlayEntry? _entry;
  Timer? _timer;

  void show(BuildContext context, String text) {
    dispose();
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: const Color(0xB3202432), borderRadius: BorderRadius.circular(8)),
                  child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(const Duration(milliseconds: 1500), dispose);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}
