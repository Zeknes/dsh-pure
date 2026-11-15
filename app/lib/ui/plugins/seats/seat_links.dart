import 'package:dsh_client/dsh_client.dart' show PluginBundle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../plugins/seams/seams.dart';
import '../../../state/plugins_state.dart';
import '../../common/empty_view.dart';
import '../../common/list_page_row.dart';
import '../../engine_settings/engine_settings_page.dart' show namespaceTitle;
import '../../engine_settings/schema_form.dart' show SchemaUnsupportedField;
import '../../theme/app_icons.dart';
import 'plugin_seat_page.dart';

/// The installed bundle named [package], if listed.
PluginBundle? seatBundleOf(List<PluginBundle>? bundles, String package) =>
    bundles?.where((b) => b.name == package).firstOrNull;

/// What to call [o]: its registered label, else its bundle's title, else the
/// package name.
String seatOccupantTitle(SlotOccupant o, {PluginBundle? bundle}) {
  final label = o.label?.trim();
  if (label != null && label.isNotEmpty) return label;
  return bundle?.title() ?? o.package;
}

/// What to call [o] where the app lists it: its label, else the label of
/// the entry that names it in DSH Web (a panel's sidebar entry, a tab's
/// title; the `main` or tab body itself is registered without one), else
/// its bundle's title, else the package name.
String seatEntryTitle(SlotOccupant o, {SeatInventory? inventory, PluginBundle? bundle}) {
  final label = o.label?.trim();
  if (label != null && label.isNotEmpty) return label;
  final named = switch (o.slot) {
    Slots.main => Slots.panelList,
    Slots.rightPaneTab => Slots.rightPaneTabTitle,
    _ => null,
  };
  if (named != null && inventory != null) {
    final entries = [
      for (final e in inventory.occupantsFor(named, package: o.package))
        if (e.label?.trim().isNotEmpty ?? false) e,
    ];
    final entry = entries.where((e) => e.cell == o.cell).firstOrNull ?? (entries.length == 1 ? entries.single : null);
    if (entry != null) return entry.label!.trim();
  }
  return seatOccupantTitle(o, bundle: bundle);
}

/// A config occupant's row title: 「设置」, or the row's own name for one of
/// several rows (`plugins.row.config`).
String seatConfigTitle(SlotOccupant o, {PluginBundle? bundle}) {
  if (o.slot != Slots.rowConfig) return appL10n.commonSettings;
  final row = o.cell.substring(o.cell.lastIndexOf('#') + 1);
  return bundle?.rows.where((r) => r.rowId == row).firstOrNull?.meta?.title?.resolve() ?? appL10n.commonSettings;
}

/// How a row leads into an occupant.
@immutable
class SeatRowEntry {
  const SeatRowEntry({required this.web, required this.open});

  /// No native or island page is available.
  final bool web;
  final void Function(BuildContext context) open;
}

/// Resolve a native or island page, or mark it unavailable.
SeatRowEntry seatRowEntry(WidgetRef ref, SeatContext seat, SeatItem item, {required String title}) {
  final o = item.occupant;
  final page = SeatRequest(
    slot: o.slot,
    placement: SeatPlacement.page,
    sessionId: seat.sessionId,
    package: o.package,
    cell: o.cell,
  );
  final paged = ref
      .watch(seatPlanProvider(page))
      .visible
      .any((i) => i.mode == SeatMode.island || i.mode == SeatMode.native);
  if (paged) {
    return SeatRowEntry(
      web: false,
      open: (context) => Navigator.of(context).push(PluginSeatPage.route(title: title, request: page)),
    );
  }

  return SeatRowEntry(web: true, open: (_) {});
}

/// Unsupported seat or its available native/island page.
class SeatWebLink extends ConsumerWidget {
  const SeatWebLink({super.key, required this.seat, required this.item});

  final SeatContext seat;
  final SeatItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final o = item.occupant;
    final bundle = seatBundleOf(ref.watch(installedPluginsProvider.select((s) => s.value)), o.package);
    if (item.configNamespace case final ns?) {
      final title =
          bundle?.rows.where((row) => row.rowId == ns).firstOrNull?.meta?.title?.resolve() ?? namespaceTitle(ns);
      return SchemaUnsupportedField(title: title, ns: ns);
    }
    final name = seatEntryTitle(o, inventory: ref.watch(seatInventoryProvider), bundle: bundle);
    if (seat.placement == SeatPlacement.page || seat.placement == SeatPlacement.overlay) {
      // Like the pages' empty states: centred, a little high.
      return Align(
        alignment: const Alignment(0, -0.5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: EmptyView(icon: AppIcons.webApp, title: name, message: l10n.pluginConfigUnsupported),
        ),
      );
    }
    final config = o.slot == Slots.bundleConfig || o.slot == Slots.rowConfig;
    final entry = seatRowEntry(ref, seat, item, title: config ? (bundle?.title() ?? name) : name);
    return ListPageRow(
      icon: config ? AppIcons.configure : AppIcons.plugin,
      title: config ? seatConfigTitle(o, bundle: bundle) : name,
      meta: entry.web ? l10n.pluginConfigUnsupported : null,
      chevron: !entry.web,
      onTap: entry.web ? null : () => entry.open(context),
    );
  }
}
