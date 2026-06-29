import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';
import '../../../models/trade.dart';

class HistoryOverlay extends StatefulWidget {
  const HistoryOverlay({super.key});
  @override State<HistoryOverlay> createState() => _HistoryOverlayState();
}

class _HistoryOverlayState extends State<HistoryOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;

    final openTrades = store.trades.where((t) => !t.resolved).toList()..sort((a, b) => b.openedAt.compareTo(a.openedAt));
    final closedTrades = store.trades.where((t) => t.resolved).toList()..sort((a, b) => b.openedAt.compareTo(a.openedAt));

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          _header(context, store, t1, t3, bg2, border),
          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (openTrades.isNotEmpty) ...[
                Text('ACTIVE TRADES', style: TextStyle(color: t3, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...openTrades.map((t) => _activeTile(t, isDark, t1, t3, border, bg2, store)),
                const SizedBox(height: 20),
              ],
              Text('HISTORY', style: TextStyle(color: t3, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 8),
              if (closedTrades.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('No trade history', style: TextStyle(color: t3, fontSize: 14)),
                ))
              else
                ...closedTrades.take(50).map((t) => _historyTile(t, isDark, t1, t3, border, bg2)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context, AppStore store, Color t1, Color t3, Color bg2, Color border) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
      child: Row(children: [
        Text('Trade History', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
        const Spacer(),
        GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none),
          child: Icon(Icons.close, color: t3, size: 22)),
      ]),
    );
  }

  Widget _activeTile(Trade t, bool isDark, Color t1, Color t3, Color border, Color bg2, AppStore store) {
    final rem = t.expiryAt - DateTime.now().millisecondsSinceEpoch;
    final remSec = (rem / 1000).ceil();
    final remStr = remSec > 60 ? '${(remSec / 60).floor()}m ${remSec % 60}s' : '${remSec}s';
    final isBuy = t.side == 'buy';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(children: [
        Row(children: [
          _sideTag(isBuy),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.mktName, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
            Text(t.walType.toUpperCase(), style: TextStyle(color: t3, fontSize: 11)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${t.amount.toStringAsFixed(2)}', style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Entry: ${t.entry.toStringAsFixed(t.dec)}', style: TextStyle(color: t3, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(remSec > 0 ? remStr : 'Resolving...', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              store.showConfirm?.call ?? (() {
                store.earlyCloseTrade(t.id, store.currentMarket?.price ?? t.entry);
                store.showToast('Trade closed early');
              })();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.red.withOpacity(0.3))),
              child: const Text('Close Early', style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _historyTile(Trade t, bool isDark, Color t1, Color t3, Color border, Color bg2) {
    final isBuy = t.side == 'buy';
    final won = t.won ?? false;
    final profit = t.profit ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: won ? AppColors.green.withOpacity(0.2) : AppColors.red.withOpacity(0.2)),
      ),
      child: Row(children: [
        _sideTag(isBuy),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.mktName, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
          Text('\$${t.amount.toStringAsFixed(2)} • ${t.walType.toUpperCase()}', style: TextStyle(color: t3, fontSize: 11)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${profit >= 0 ? '+' : ''}\$${profit.abs().toStringAsFixed(2)}',
            style: TextStyle(color: won ? AppColors.green : AppColors.red, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(won ? 'WIN' : (t.earlyClosed ? 'CLOSED' : 'LOSS'),
            style: TextStyle(color: won ? AppColors.green : AppColors.red, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _sideTag(bool isBuy) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: isBuy ? AppColors.green.withOpacity(0.1) : AppColors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(isBuy ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: isBuy ? AppColors.green : AppColors.red, size: 12),
      const SizedBox(width: 4),
      Text(isBuy ? 'BUY' : 'SELL', style: TextStyle(color: isBuy ? AppColors.green : AppColors.red, fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );
}
