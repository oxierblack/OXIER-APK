import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_store.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String _error = '';

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || pass.isEmpty) { setState(() => _error = 'Please fill all fields'); return; }
    if (pass.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiService.register(email, pass, name);
      if (!mounted) return;
      if (res != null && (res['statusCode'] == 200 || res['statusCode'] == 201)) {
        final store = context.read<AppStore>();
        store.verifyEmail = email;
        store.setScreen(AppScreen.verify);
      } else {
        final body = res?['body'];
        setState(() => _error = body?['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (_) {
      setState(() => _error = 'Network error. Please try again.');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppStore>().isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final border = isDark ? AppColors.border : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 48),
            Center(child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2979FF)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20)],
              ),
              alignment: Alignment.center,
              child: const Text('OX', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            )),
            const SizedBox(height: 32),
            Text('Create account', style: TextStyle(color: t1, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Start trading today', style: TextStyle(color: t3, fontSize: 14)),
            const SizedBox(height: 32),

            _label('Full Name', t3), const SizedBox(height: 8),
            _field(_nameCtrl, 'Enter your full name', bg2, border, t1, t3),
            const SizedBox(height: 16),
            _label('Email', t3), const SizedBox(height: 8),
            _field(_emailCtrl, 'Enter your email', bg2, border, t1, t3, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _label('Password', t3), const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _passCtrl, obscureText: _obscure,
                  style: TextStyle(color: t1, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Min. 6 characters', hintStyle: TextStyle(color: t3),
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                )),
                IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: t3, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ]),
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.red.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13))),
                ]),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
              onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            )),

            const SizedBox(height: 24),
            Center(child: GestureDetector(
              onTap: () => context.read<AppStore>().setScreen(AppScreen.login),
              child: RichText(text: TextSpan(children: [
                TextSpan(text: 'Already have an account? ', style: TextStyle(color: t3, fontSize: 14)),
                const TextSpan(text: 'Sign In', style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
              ])),
            )),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600));

  Widget _field(TextEditingController ctrl, String hint, Color bg, Color border, Color t1, Color t3, {TextInputType? type}) =>
      Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: TextField(
          controller: ctrl, keyboardType: type,
          style: TextStyle(color: t1, fontSize: 14),
          decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: t3), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        ),
      );
}
