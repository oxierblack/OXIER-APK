import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  static const _items = [
    {'id': 'chart', 'label': 'Chart', 'icon': Icons.show_chart_rounded},
    {'id': 'history', 'label': 'History', 'icon': Icons.history_rounded},
    {'id': 'signals', 'label': 'Signals', 'icon': Icons.bar_chart_rounded},
    {'id': 'events', 'label': 'Events', 'icon': Icons.event_note_rounded},
    {'id': 'panel', 'label': 'Profile', 'icon': Icons.person_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final openCount = store.openTrades.length;

    return Container(
      decoration: BoxDecoration(color: bg, border: Border(top: BorderSide(color: border))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom - 8 : 0),
      child: Row(
        children: _items.map((item) {
          final id = item['id'] as String;
          final isActive = id == 'chart' ? store.overlay == ActiveOverlay.none : store.overlay == _overlayFromId(id);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (id == 'chart') store.setOverlay(ActiveOverlay.none);
                else store.setOverlay(_overlayFromId(id));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(item['icon'] as IconData, color: isActive ? AppColors.accent : t3, size: 22),
                      const SizedBox(height: 3),
                      Text(item['label'] as String, style: TextStyle(color: isActive ? AppColors.accent : t3, fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
                    ]),
                    if (id == 'history' && openCount > 0)
                      Positioned(
                        top: 0, right: 16,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text('$openCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  ActiveOverlay _overlayFromId(String id) {
    switch (id) {
      case 'history': return ActiveOverlay.history;
      case 'signals': return ActiveOverlay.signals;
      case 'events': return ActiveOverlay.events;
      case 'panel': return ActiveOverlay.panel;
      default: return ActiveOverlay.none;
    }
  }
}
