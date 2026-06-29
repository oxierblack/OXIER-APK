import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';
import '../../../models/transaction.dart';
import '../../../services/api_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});
  @override State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String _selectedMethod = 'usdt_trc20';
  String _amount = '100';
  bool _loading = false;
  bool _submitted = false;

  final _methods = [
    {'id': 'usdt_trc20', 'name': 'USDT TRC20', 'icon': Icons.currency_bitcoin, 'color': 0xFF26A17B, 'address': 'TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'min': 20},
    {'id': 'usdt_erc20', 'name': 'USDT ERC20', 'icon': Icons.currency_bitcoin, 'color': 0xFF627EEA, 'address': '0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'min': 50},
    {'id': 'btc', 'name': 'Bitcoin', 'icon': Icons.currency_bitcoin, 'color': 0xFFF7931A, 'address': 'bc1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'min': 30},
    {'id': 'bank', 'name': 'Bank Transfer', 'icon': Icons.account_balance, 'color': 0xFF2979FF, 'address': 'Contact support for bank details', 'min': 100},
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final method = _methods.firstWhere((m) => m['id'] == _selectedMethod);

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Row(children: [
              Text('Deposit Funds', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
            ]),
          ),
          Expanded(child: _submitted ? _successView(t1, t3, bg2, border) : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Select Payment Method', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ...(_methods.map((m) => GestureDetector(
                onTap: () => setState(() => _selectedMethod = m['id'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _selectedMethod == m['id'] ? Color(m['color'] as int).withOpacity(0.08) : bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedMethod == m['id'] ? Color(m['color'] as int).withOpacity(0.5) : border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Color(m['color'] as int).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Icon(m['icon'] as IconData, color: Color(m['color'] as int), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m['name'] as String, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Min: \$${m['min']}', style: TextStyle(color: t3, fontSize: 11)),
                    ]),
                    const Spacer(),
                    if (_selectedMethod == m['id']) const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
                  ]),
                ),
              ))),

              const SizedBox(height: 16),
              Text('Wallet Address', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                child: Row(children: [
                  Expanded(child: Text(method['address'] as String, style: TextStyle(color: t1, fontSize: 13, fontFamily: 'monospace'))),
                  GestureDetector(
                    onTap: () { Clipboard.setData(ClipboardData(text: method['address'] as String)); store.showToast('Address copied!'); },
                    child: const Icon(Icons.copy_rounded, color: AppColors.accent, size: 18),
                  ),
                ]),
              ),

              const SizedBox(height: 16),
              Text('Amount (USD)', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: t1, fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixText: '\$', prefixStyle: TextStyle(color: t3, fontSize: 16),
                    hintText: '0.00', hintStyle: TextStyle(color: t3),
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => setState(() => _amount = v),
                  controller: TextEditingController(text: _amount),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Deposit Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              )),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _successView(Color t1, Color t3, Color bg2, Color border) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 48),
        ),
        const SizedBox(height: 24),
        Text('Request Submitted!', style: TextStyle(color: t1, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Your deposit of \$$_amount is pending review. Your balance will be updated shortly.', style: TextStyle(color: t3, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
          onPressed: () => context.read<AppStore>().setOverlay(ActiveOverlay.none),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        )),
      ]),
    ),
  );

  Future<void> _submit() async {
    final amt = double.tryParse(_amount) ?? 0;
    if (amt < 10) { context.read<AppStore>().showToast('Minimum deposit is \$10'); return; }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final store = context.read<AppStore>();
    store.addTransaction(Transaction(
      id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
      type: 'deposit', desc: 'Deposit via $_selectedMethod', amount: amt,
      status: 'pending', date: DateTime.now().millisecondsSinceEpoch, method: _selectedMethod,
    ));
    if (mounted) setState(() { _loading = false; _submitted = true; });
  }
}
