import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class EventsOverlay extends StatelessWidget {
  const EventsOverlay({super.key});

  static final _events = [
    {'title': 'US Non-Farm Payrolls', 'time': '14:30 UTC', 'impact': 'high', 'currency': 'USD', 'forecast': '185K', 'previous': '175K'},
    {'title': 'ECB Interest Rate Decision', 'time': '12:45 UTC', 'impact': 'high', 'currency': 'EUR', 'forecast': '4.50%', 'previous': '4.50%'},
    {'title': 'UK CPI y/y', 'time': '07:00 UTC', 'impact': 'medium', 'currency': 'GBP', 'forecast': '2.3%', 'previous': '2.5%'},
    {'title': 'US Initial Jobless Claims', 'time': '13:30 UTC', 'impact': 'medium', 'currency': 'USD', 'forecast': '215K', 'previous': '220K'},
    {'title': 'Japan GDP q/q', 'time': '23:50 UTC', 'impact': 'medium', 'currency': 'JPY', 'forecast': '0.5%', 'previous': '0.3%'},
    {'title': 'Canada Employment Change', 'time': '13:30 UTC', 'impact': 'medium', 'currency': 'CAD', 'forecast': '20K', 'previous': '15K'},
    {'title': 'US FOMC Meeting Minutes', 'time': '18:00 UTC', 'impact': 'high', 'currency': 'USD', 'forecast': '-', 'previous': '-'},
    {'title': 'Australia CPI q/q', 'time': '01:30 UTC', 'impact': 'high', 'currency': 'AUD', 'forecast': '0.8%', 'previous': '1.0%'},
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

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Row(children: [
              Text('Economic Calendar', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
            ]),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _events.length,
            itemBuilder: (ctx, i) {
              final e = _events[i];
              final impact = e['impact']!;
              final impactColor = impact == 'high' ? AppColors.red : impact == 'medium' ? AppColors.gold : AppColors.green;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: impactColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: impactColor.withOpacity(0.3))),
                      child: Text(impact.toUpperCase(), style: TextStyle(color: impactColor, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(e['currency']!, style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    Row(children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.t3),
                      const SizedBox(width: 4),
                      Text(e['time']!, style: TextStyle(color: t3, fontSize: 12)),
                    ]),
                  ]),
                  const SizedBox(height: 8),
                  Text(e['title']!, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _stat('Forecast', e['forecast']!, AppColors.accent, t3),
                    const SizedBox(width: 20),
                    _stat('Previous', e['previous']!, t1, t3),
                  ]),
                ]),
              );
            },
          )),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, Color valueColor, Color labelColor) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
    Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w700)),
  ]);
}
