import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

const _indicators = [
  {'id': 'rsi', 'name': 'RSI', 'desc': 'Relative Strength Index', 'color': 0xFF9C27B0},
  {'id': 'macd', 'name': 'MACD', 'desc': 'Moving Average Convergence Divergence', 'color': 0xFF2196F3},
  {'id': 'bb', 'name': 'Bollinger Bands', 'desc': 'Volatility bands around SMA', 'color': 0xFFFF9800},
  {'id': 'ema20', 'name': 'EMA 20', 'desc': 'Exponential Moving Average 20', 'color': 0xFF00BCD4},
  {'id': 'ema50', 'name': 'EMA 50', 'desc': 'Exponential Moving Average 50', 'color': 0xFFE91E63},
  {'id': 'sma', 'name': 'SMA 20', 'desc': 'Simple Moving Average 20', 'color': 0xFF4CAF50},
  {'id': 'cci', 'name': 'CCI', 'desc': 'Commodity Channel Index', 'color': 0xFFFF5722},
  {'id': 'atr', 'name': 'ATR', 'desc': 'Average True Range', 'color': 0xFF795548},
  {'id': 'stoch', 'name': 'Stochastic', 'desc': 'Stochastic Oscillator', 'color': 0xFF607D8B},
  {'id': 'williams', 'name': 'Williams %R', 'desc': 'Williams Percent Range', 'color': 0xFFCDDC39},
  {'id': 'volume', 'name': 'Volume', 'desc': 'Trading Volume Bars', 'color': 0xFF9E9E9E},
];

class IndicatorsOverlay extends StatelessWidget {
  const IndicatorsOverlay({super.key});

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
              Text('Indicators', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
            ]),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _indicators.length,
            itemBuilder: (ctx, i) {
              final ind = _indicators[i];
              final id = ind['id'] as String;
              final active = store.activeInds.contains(id);
              final color = Color(ind['color'] as int);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: active ? color.withOpacity(0.08) : bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: active ? color.withOpacity(0.4) : border),
                ),
                child: Row(children: [
                  Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ind['name'] as String, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(ind['desc'] as String, style: TextStyle(color: t3, fontSize: 11)),
                  ])),
                  Switch.adaptive(value: active, onChanged: (_) => store.toggleInd(id), activeColor: color),
                ]),
              );
            },
          )),
        ]),
      ),
    );
  }
}
