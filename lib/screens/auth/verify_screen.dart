import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_store.dart';
import '../../services/api_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  @override State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<TextEditingController> _ctrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    for (var c in _ctrls) c.dispose();
    for (var n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) { setState(() => _error = 'Enter the 6-digit code'); return; }
    final store = context.read<AppStore>();
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiService.verifyOtp(store.verifyEmail, _otp);
      if (!mounted) return;
      if (res != null && res['statusCode'] == 200) {
        final body = res['body'];
        store.setUserInfo(UserInfo(email: store.verifyEmail, name: body['name'] ?? '', token: body['token'] ?? ''));
        store.setScreen(AppScreen.pin);
      } else {
        setState(() => _error = 'Invalid code. Please try again.');
      }
    } catch (_) {
      setState(() => _error = 'Network error. Please try again.');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final bg = store.isDark ? AppColors.bg : AppColors.lightBg;
    final t1 = store.isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = store.isDark ? AppColors.t3 : AppColors.lightT3;
    final border = store.isDark ? AppColors.border : AppColors.lightBorder;
    final bg2 = store.isDark ? AppColors.bg2 : AppColors.lightBg2;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => store.setScreen(AppScreen.register),
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                child: Icon(Icons.arrow_back, color: t1, size: 20)),
            ),
            const SizedBox(height: 32),
            Text('Verify your email', style: TextStyle(color: t1, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Enter the 6-digit code sent to\n${store.verifyEmail}', style: TextStyle(color: t3, fontSize: 14, height: 1.5)),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => SizedBox(
                width: 46, height: 56,
                child: TextField(
                  controller: _ctrls[i], focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(color: t1, fontSize: 22, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true, fillColor: bg2,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                    else if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                    setState(() {});
                  },
                ),
              )),
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ],

            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _verify,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Verify', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      ),
    );
  }
}
