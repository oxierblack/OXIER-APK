import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class SignalsOverlay extends StatelessWidget {
  const SignalsOverlay({super.key});

  static final _rng = Random();

  static List<Map<String, dynamic>> _generateSignals(List markets) {
    final signals = <Map<String, dynamic>>[];
    for (final m in markets.take(8)) {
      final rng = Random(m.symbol.hashCode + DateTime.now().minute);
      signals.add({
        'mktName': m.name, 'side': rng.nextBool() ? 'buy' : 'sell',
        'strength': (65 + rng.nextInt(30)),
        'expiry': ['1m', '2m', '5m'][rng.nextInt(3)],
        'indicators': ['RSI', 'MACD', 'BB', 'EMA'].sublist(0, 2 + rng.nextInt(3)),
      });
    }
    return signals;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final signals = _generateSignals(store.markets);

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Row(children: [
              Text('Trading Signals', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.green.withOpacity(0.3))),
                child: const Text('LIVE', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
            ]),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: signals.length,
            itemBuilder: (ctx, i) {
              final s = signals[i];
              final isBuy = s['side'] == 'buy';
              final strength = s['strength'] as int;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s['mktName'], style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isBuy ? AppColors.green.withOpacity(0.12) : AppColors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(isBuy ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: isBuy ? AppColors.green : AppColors.red, size: 12),
                        const SizedBox(width: 4),
                        Text(isBuy ? 'BUY UP' : 'SELL DOWN', style: TextStyle(color: isBuy ? AppColors.green : AppColors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('Strength:', style: TextStyle(color: t3, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: LinearProgressIndicator(
                      value: strength / 100, minHeight: 6,
                      backgroundColor: isDark ? AppColors.bg3 : AppColors.lightBg3,
                      valueColor: AlwaysStoppedAnimation(strength >= 80 ? AppColors.green : strength >= 65 ? AppColors.gold : AppColors.red),
                    )),
                    const SizedBox(width: 8),
                    Text('$strength%', style: TextStyle(color: t1, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.timer_outlined, size: 12, color: t3),
                    const SizedBox(width: 4),
                    Text('Expiry: ${s['expiry']}', style: TextStyle(color: t3, fontSize: 12)),
                    const SizedBox(width: 12),
                    ...((s['indicators'] as List).map((ind) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(ind, style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                    ))),
                  ]),
                ]),
              );
            },
          )),
        ]),
      ),
    );
  }
}
