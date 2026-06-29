import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class ExpiryOverlay extends StatefulWidget {
  const ExpiryOverlay({super.key});
  @override State<ExpiryOverlay> createState() => _ExpiryOverlayState();
}

class _ExpiryOverlayState extends State<ExpiryOverlay> {
  late double _amount;
  int _selectedMin = 1;
  String _selectedDisp = '1m';

  final _expiryOptions = [
    {'min': 1, 'disp': '1m'}, {'min': 2, 'disp': '2m'}, {'min': 3, 'disp': '3m'},
    {'min': 5, 'disp': '5m'}, {'min': 10, 'disp': '10m'}, {'min': 15, 'disp': '15m'},
    {'min': 30, 'disp': '30m'}, {'min': 60, 'disp': '1h'},
  ];

  final _quickAmounts = [10.0, 25.0, 50.0, 100.0, 250.0, 500.0];

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    _amount = store.amount;
    _selectedMin = store.expMin;
    _selectedDisp = store.expDisp;
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

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => store.setOverlay(ActiveOverlay.none),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Trade Settings', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
                ]),
                const SizedBox(height: 20),

                Text('Amount', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                  child: Row(children: [
                    GestureDetector(onTap: () => setState(() => _amount = (_amount - 5).clamp(1, 99999)),
                      child: const Icon(Icons.remove, color: AppColors.t3, size: 20)),
                    Expanded(child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(border: InputBorder.none, prefixText: '\$'),
                      controller: TextEditingController(text: _amount.toStringAsFixed(0))
                        ..selection = TextSelection.collapsed(offset: _amount.toStringAsFixed(0).length + 1),
                      onChanged: (v) { final n = double.tryParse(v); if (n != null) setState(() => _amount = n); },
                    )),
                    GestureDetector(onTap: () => setState(() => _amount += 5),
                      child: const Icon(Icons.add, color: AppColors.accent, size: 20)),
                  ]),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _quickAmounts.map((a) => GestureDetector(
                    onTap: () => setState(() => _amount = a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _amount == a ? AppColors.accent : bg2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _amount == a ? AppColors.accent : border),
                      ),
                      child: Text('\$${a.toStringAsFixed(0)}', style: TextStyle(color: _amount == a ? Colors.white : t3, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 20),
                Text('Expiry Time', style: TextStyle(color: t3, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _expiryOptions.map((e) {
                    final active = _selectedMin == e['min'];
                    return GestureDetector(
                      onTap: () => setState(() { _selectedMin = e['min'] as int; _selectedDisp = e['disp'] as String; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? AppColors.accent : bg2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? AppColors.accent : border),
                        ),
                        child: Text(e['disp'] as String, style: TextStyle(color: active ? Colors.white : t3, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  onPressed: () {
                    store.setAmount(_amount);
                    store.setExpiry(_selectedMin, _selectedDisp);
                    store.setOverlay(ActiveOverlay.none);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                )),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
