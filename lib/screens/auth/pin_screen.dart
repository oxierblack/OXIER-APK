import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_store.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});
  @override State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _firstPin;
  bool _isConfirm = false;
  String _error = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  final List<String> _keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }

  void _press(String key) {
    if (key == '⌫') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
      return;
    }
    if (key.isEmpty) return;
    if (_pin.length >= 4) return;
    setState(() { _pin += key; _error = ''; });

    if (_pin.length == 4) {
      if (!_isConfirm) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          setState(() { _firstPin = _pin; _pin = ''; _isConfirm = true; });
        });
      } else {
        if (_pin == _firstPin) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            context.read<AppStore>().setScreen(AppScreen.trading);
          });
        } else {
          _shakeCtrl.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            setState(() { _pin = ''; _error = 'PINs do not match. Try again.'; });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppStore>().isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          const SizedBox(height: 60),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2979FF)]), borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: const Text('OX', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 24),
          Text(_isConfirm ? 'Confirm your PIN' : 'Create a PIN', style: TextStyle(color: t1, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Secure your account with a 4-digit PIN', style: TextStyle(color: t3, fontSize: 13)),
          const SizedBox(height: 40),

          AnimatedBuilder(
            animation: _shakeAnim,
            builder: (ctx, child) => Transform.translate(
              offset: Offset(_shakeAnim.value * ((_pin.length % 2 == 0) ? 1 : -1), 0),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                width: 16, height: 16, margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? AppColors.accent : bg2,
                  border: Border.all(color: i < _pin.length ? AppColors.accent : AppColors.border, width: 2),
                ),
              )),
            ),
          ),

          if (_error.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13)),
          ],

          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6),
              itemCount: 12,
              itemBuilder: (ctx, i) {
                final key = _keys[i];
                return GestureDetector(
                  onTap: () => _press(key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: key.isEmpty ? Colors.transparent : bg2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: key == '⌫'
                        ? Icon(Icons.backspace_outlined, color: t3, size: 22)
                        : Text(key, style: TextStyle(color: t1, fontSize: 22, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}
