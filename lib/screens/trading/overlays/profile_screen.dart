import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Row(children: [
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.panel), child: Icon(Icons.arrow_back, color: t1, size: 22)),
              const SizedBox(width: 12),
              Text('Profile', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF2979FF)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20)],
                ),
                alignment: Alignment.center,
                child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 16),
              Text(user?.name ?? 'Trader', style: TextStyle(color: t1, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: TextStyle(color: t3, fontSize: 14)),

              const SizedBox(height: 32),
              _infoRow('Email', user?.email ?? '-', t1, t3, bg2, border),
              const SizedBox(height: 8),
              _infoRow('Account Type', user?.token == 'demo' ? 'Demo Account' : 'Live Account', t1, t3, bg2, border),
              const SizedBox(height: 8),
              _infoRow('Member Since', 'June 2025', t1, t3, bg2, border),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.verified_rounded, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Verify Your Account', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('Complete KYC to unlock full withdrawal limits', style: TextStyle(color: t3, fontSize: 12)),
                  ])),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
                ]),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color t1, Color t3, Color bg, Color border) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
    child: Row(children: [
      Text(label, style: TextStyle(color: t3, fontSize: 13)),
      const Spacer(),
      Text(value, style: TextStyle(color: t1, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}
