import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';
import '../../../models/transaction.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});
  @override State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _amtCtrl = TextEditingController(text: '100');
  final _addrCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); _amtCtrl.dispose(); _addrCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 0),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.panel), child: Icon(Icons.arrow_back, color: t1, size: 22)),
                const SizedBox(width: 12),
                Text('Transfers', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
              ]),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabs,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: t3,
                tabs: const [Tab(text: 'Withdraw'), Tab(text: 'History')],
              ),
            ]),
          ),
          Expanded(child: TabBarView(
            controller: _tabs,
            children: [
              _withdrawTab(store, isDark, bg2, border, t1, t3),
              _historyTab(store, isDark, bg2, border, t1, t3),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _withdrawTab(AppStore store, bool isDark, Color bg2, Color border, Color t1, Color t3) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2979FF)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('\$${store.realBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),

        const SizedBox(height: 20),
        Text('Withdrawal Amount', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
          child: TextField(
            controller: _amtCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: t1, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: '\$', prefixStyle: TextStyle(color: t3),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Withdrawal Address (USDT TRC20)', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
          child: TextField(
            controller: _addrCtrl,
            style: TextStyle(color: t1, fontSize: 14),
            decoration: InputDecoration(hintText: 'Enter wallet address', hintStyle: TextStyle(color: t3), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: _loading ? null : () async {
            final amt = double.tryParse(_amtCtrl.text) ?? 0;
            if (amt < 20) { store.showToast('Minimum withdrawal is \$20'); return; }
            if (_addrCtrl.text.isEmpty) { store.showToast('Enter withdrawal address'); return; }
            if (amt > store.realBalance) { store.showToast('Insufficient balance'); return; }
            setState(() => _loading = true);
            await Future.delayed(const Duration(seconds: 1));
            store.addTransaction(Transaction(
              id: 'wd_${DateTime.now().millisecondsSinceEpoch}', type: 'withdrawal',
              desc: 'Withdrawal to ${_addrCtrl.text.substring(0, 8)}...', amount: amt,
              status: 'pending', date: DateTime.now().millisecondsSinceEpoch,
            ));
            store.showToast('Withdrawal request submitted');
            if (mounted) setState(() => _loading = false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit Withdrawal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }

  Widget _historyTab(AppStore store, bool isDark, Color bg2, Color border, Color t1, Color t3) {
    final txs = store.transactions;
    if (txs.isEmpty) return Center(child: Text('No transactions yet', style: TextStyle(color: t3)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: txs.length,
      itemBuilder: (ctx, i) {
        final tx = txs[i];
        final isDeposit = tx.type == 'deposit';
        final statusColor = tx.status == 'completed' ? AppColors.green : tx.status == 'rejected' ? AppColors.red : AppColors.gold;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: isDeposit ? AppColors.green.withOpacity(0.1) : AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Icon(isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isDeposit ? AppColors.green : AppColors.red, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tx.desc, style: TextStyle(color: t1, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(DateTime.fromMillisecondsSinceEpoch(tx.date).toString().substring(0, 16), style: TextStyle(color: t3, fontSize: 11)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${isDeposit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}', style: TextStyle(color: isDeposit ? AppColors.green : AppColors.red, fontSize: 14, fontWeight: FontWeight.w700)),
              Text(tx.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ]),
          ]),
        );
      },
    );
  }
}
