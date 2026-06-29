import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';
import '../../../models/trade.dart';

class BottomControls extends StatefulWidget {
  const BottomControls({super.key});
  @override State<BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<BottomControls> {
  bool _trading = false;
  Map<String, dynamic>? _lastResult;

  Future<void> _openTrade(String side) async {
    final store = context.read<AppStore>();
    final mkt = store.currentMarket;
    if (mkt == null) { store.showToast('Select a market first'); return; }
    if (store.amount <= 0) { store.showToast('Enter a valid amount'); return; }
    if (store.amount > store.balance) {
      store.showToast(store.walType == 'demo' ? 'Insufficient demo balance' : 'Insufficient balance — deposit to continue');
      if (store.walType == 'real') Future.delayed(const Duration(milliseconds: 500), () => store.setOverlay(ActiveOverlay.deposit));
      return;
    }
    if (_trading) return;
    setState(() { _trading = true; _lastResult = null; });

    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 't_${now}_${DateTime.now().microsecondsSinceEpoch}';
    final payout = mkt.payout;
    final trade = Trade(
      id: id, mktId: mkt.id, mktName: mkt.name, side: side,
      amount: store.amount, entry: mkt.price, dec: mkt.dec, payout: payout,
      walType: store.walType, openedAt: now, expiryAt: now + store.expMin * 60 * 1000,
    );

    store.addTrade(trade);
    store.adjustBalance(-store.amount);
    store.showToast('${side == 'buy' ? 'BUY' : 'SELL'} order opened — ${store.expDisp}');

    Timer(Duration(minutes: store.expMin), () async {
      double exitPrice = mkt.price;
      try {
        final r = await http.get(Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=${mkt.symbol}')).timeout(const Duration(seconds: 5));
        if (r.statusCode == 200) { final d = jsonDecode(r.body); exitPrice = double.parse(d['price'].toString()); }
      } catch (_) { exitPrice = mkt.price * (1 + (DateTime.now().microsecond / 1000000 - 0.48) * 0.02); }

      final priceWent = exitPrice > trade.entry ? 'up' : 'down';
      final won = side == 'buy' ? priceWent == 'up' : priceWent == 'down';
      final profit = won ? trade.amount * (payout / 100) : -trade.amount;

      if (!mounted) return;
      store.resolveTrade(id, exitPrice, won);
      if (won) store.adjustBalance(trade.amount + trade.amount * (payout / 100));
      setState(() { _lastResult = {'won': won, 'profit': profit, 'mktName': mkt.name}; _trading = false; });
      store.showToast(won ? 'WIN +\$${(trade.amount * payout / 100).toStringAsFixed(2)}' : 'LOSS -\$${trade.amount.toStringAsFixed(2)}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final payout = store.currentMarket?.payout ?? 82;
    final profit = (store.amount * payout / 100);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(color: bg, border: Border(top: BorderSide(color: border))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        if (_lastResult != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: (_lastResult!['won'] as bool) ? AppColors.green.withOpacity(0.1) : AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (_lastResult!['won'] as bool) ? AppColors.green.withOpacity(0.3) : AppColors.red.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon((_lastResult!['won'] as bool) ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: (_lastResult!['won'] as bool) ? AppColors.green : AppColors.red, size: 18),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((_lastResult!['won'] as bool) ? 'TRADE WON' : 'TRADE LOST', style: TextStyle(color: (_lastResult!['won'] as bool) ? AppColors.green : AppColors.red, fontSize: 12, fontWeight: FontWeight.w800)),
                Text(_lastResult!['mktName'], style: TextStyle(color: t3, fontSize: 11)),
              ]),
              const Spacer(),
              Text('${(_lastResult!['profit'] as double) >= 0 ? '+' : ''}\$${(_lastResult!['profit'] as double).abs().toStringAsFixed(2)}',
                style: TextStyle(color: (_lastResult!['won'] as bool) ? AppColors.green : AppColors.red, fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
          ),
        ],

        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => store.setOverlay(ActiveOverlay.expiry),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(color: isDark ? AppColors.bg3 : AppColors.lightBg3, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Amount', style: TextStyle(color: t3, fontSize: 10)),
                Text('\$${store.amount.toStringAsFixed(2)}', style: TextStyle(color: t1, fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(
            onTap: () => store.setOverlay(ActiveOverlay.expiry),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(color: isDark ? AppColors.bg3 : AppColors.lightBg3, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Expiry', style: TextStyle(color: t3, fontSize: 10)),
                Text(store.expDisp, style: TextStyle(color: t1, fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
            ),
          )),
        ]),

        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _tradeBtn(
            label: 'BUY UP', sub: '+\$${profit.toStringAsFixed(2)}',
            color: AppColors.green, darkColor: const Color(0xFF004D1A),
            icon: Icons.arrow_upward_rounded,
            onTap: () => _openTrade('buy'),
          )),
          const SizedBox(width: 8),
          Expanded(child: _tradeBtn(
            label: 'SELL DOWN', sub: '+\$${profit.toStringAsFixed(2)}',
            color: AppColors.red, darkColor: const Color(0xFF4D0011),
            icon: Icons.arrow_downward_rounded,
            onTap: () => _openTrade('sell'),
            iconRight: true,
          )),
        ]),

        if (store.openTrades.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            Text('${store.openTrades.length} active trade${store.openTrades.length > 1 ? 's' : ''}', style: TextStyle(color: t3, fontSize: 11)),
            const Spacer(),
            GestureDetector(
              onTap: () => store.setOverlay(ActiveOverlay.history),
              child: const Text('View all →', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _tradeBtn({required String label, required String sub, required Color color, required Color darkColor, required IconData icon, required VoidCallback onTap, bool iconRight = false}) {
    return GestureDetector(
      onTap: _trading ? null : onTap,
      child: AnimatedOpacity(
        opacity: _trading ? 0.6 : 1.0, duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [darkColor, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!iconRight) Icon(icon, color: Colors.white, size: 20),
              Column(crossAxisAlignment: iconRight ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
              ]),
              if (iconRight) Icon(icon, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
