import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class PanelOverlay extends StatelessWidget {
  const PanelOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;

    final user = store.userInfo;
    final closedTrades = store.trades.where((t) => t.resolved).toList();
    final winTrades = closedTrades.where((t) => t.won == true).length;
    final winRate = closedTrades.isEmpty ? 0.0 : winTrades / closedTrades.length * 100;
    final totalProfit = closedTrades.fold(0.0, (sum, t) => sum + (t.profit ?? 0));

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Row(children: [
              Text('Account', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2979FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user?.name ?? 'Trader', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  Row(children: [
                    _balCard('Demo', store.demoBalance, AppColors.demoColor),
                    const SizedBox(width: 12),
                    _balCard('Real', store.realBalance, AppColors.realColor),
                  ]),
                ]),
              ),

              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _statCard('Win Rate', '${winRate.toStringAsFixed(1)}%', AppColors.green, bg2, border, t1, t3)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Total P&L', '${totalProfit >= 0 ? '+' : ''}\$${totalProfit.abs().toStringAsFixed(2)}', totalProfit >= 0 ? AppColors.green : AppColors.red, bg2, border, t1, t3)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statCard('Trades', '${closedTrades.length}', AppColors.accent, bg2, border, t1, t3)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Wins', '$winTrades', AppColors.green, bg2, border, t1, t3)),
              ]),

              const SizedBox(height: 16),
              _menuItem(context, Icons.person_outline_rounded, 'Profile', t1, t3, bg2, border, () => store.setOverlay(ActiveOverlay.profile)),
              _menuItem(context, Icons.swap_horiz_rounded, 'Transfers', t1, t3, bg2, border, () => store.setOverlay(ActiveOverlay.transfers)),
              _menuItem(context, Icons.add_circle_outline_rounded, 'Deposit', t1, t3, bg2, border, () => store.setOverlay(ActiveOverlay.deposit)),
              _menuItem(context, Icons.candlestick_chart_rounded, 'Indicators', t1, t3, bg2, border, () => store.setOverlay(ActiveOverlay.indicators)),
              _menuItem(context, Icons.brightness_6_rounded, isDark ? 'Light Mode' : 'Dark Mode', t1, t3, bg2, border, () => store.toggleTheme()),
              _menuItem(context, Icons.logout_rounded, 'Sign Out', AppColors.red, t3, bg2, border, () {
                store.setUserInfo(null);
                store.setScreen(AppScreen.login);
              }, isDestructive: true),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _balCard(String label, double bal, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        Text('\$${bal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ]),
    ),
  );

  Widget _statCard(String label, String value, Color color, Color bg, Color border, Color t1, Color t3) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: t3, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
    ]),
  );

  Widget _menuItem(BuildContext context, IconData icon, String label, Color labelColor, Color t3, Color bg, Color border, VoidCallback onTap, {bool isDestructive = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDestructive ? AppColors.red.withOpacity(0.2) : border)),
      child: Row(children: [
        Icon(icon, color: labelColor, size: 20),
        const SizedBox(width: 14),
        Text(label, style: TextStyle(color: labelColor, fontSize: 15, fontWeight: FontWeight.w600)),
        const Spacer(),
        Icon(Icons.chevron_right_rounded, color: t3, size: 20),
      ]),
    ),
  );
}
