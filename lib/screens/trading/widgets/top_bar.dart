import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});
  @override State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool _dropOpen = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final bal = store.walType == 'demo' ? store.demoBalance : store.realBalance;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 0),
      decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: border))),
      child: Stack(
        children: [
          Row(children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2979FF)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('OX', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 8),
              const Text('OXIER', style: TextStyle(color: AppColors.t1, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ]),
            const Spacer(),

            GestureDetector(
              onTap: () => setState(() => _dropOpen = !_dropOpen),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: isDark ? AppColors.bg3 : AppColors.lightBg3, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: store.walType == 'demo' ? AppColors.demoColor.withOpacity(0.15) : AppColors.realColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      store.walType == 'demo' ? 'DEMO' : 'REAL',
                      style: TextStyle(
                        color: store.walType == 'demo' ? AppColors.demoColor : AppColors.realColor,
                        fontSize: 10, fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('\$${bal.toStringAsFixed(2)}', style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: t3, size: 16),
                ]),
              ),
            ),

            const SizedBox(width: 8),
            _iconBtn(
              icon: store.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: t3,
              onTap: () => store.setSoundEnabled(!store.soundEnabled),
            ),
            const SizedBox(width: 4),
            _iconBtn(
              icon: store.isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: t3,
              onTap: () => store.toggleTheme(),
            ),
          ]),

          if (_dropOpen)
            Positioned(
              right: 48, top: 44,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bg2 : AppColors.lightBg2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(children: [
                    _walletOption('Demo Account', store.demoBalance, 'demo', store.walType == 'demo', store, isDark, t1, t3, border),
                    Divider(color: border, height: 1),
                    _walletOption('Real Account', store.realBalance, 'real', store.walType == 'real', store, isDark, t1, t3, border),
                    Divider(color: border, height: 1),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline, color: AppColors.green, size: 18),
                      title: const Text('Deposit Funds', style: TextStyle(color: AppColors.green, fontSize: 14, fontWeight: FontWeight.w600)),
                      onTap: () { setState(() => _dropOpen = false); store.setOverlay(ActiveOverlay.deposit); },
                    ),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _walletOption(String label, double bal, String type, bool active, AppStore store, bool isDark, Color t1, Color t3, Color border) {
    return ListTile(
      dense: true,
      leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: type == 'demo' ? AppColors.demoColor : AppColors.realColor, shape: BoxShape.circle)),
      title: Text(label, style: TextStyle(color: t1, fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      trailing: Text('\$${bal.toStringAsFixed(2)}', style: TextStyle(color: t3, fontSize: 13)),
      onTap: () { store.setWalType(type); setState(() => _dropOpen = false); },
    );
  }

  Widget _iconBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
