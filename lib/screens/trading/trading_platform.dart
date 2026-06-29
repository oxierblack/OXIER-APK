import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_store.dart';
import '../../services/binance_service.dart';
import 'widgets/top_bar.dart';
import 'widgets/asset_bar.dart';
import 'widgets/trading_chart.dart';
import 'widgets/bottom_controls.dart';
import 'widgets/nav_bar.dart';
import 'overlays/history_overlay.dart';
import 'overlays/signals_overlay.dart';
import 'overlays/indicators_overlay.dart';
import 'overlays/events_overlay.dart';
import 'overlays/panel_overlay.dart';
import 'overlays/expiry_overlay.dart';
import 'overlays/deposit_screen.dart';
import 'overlays/profile_screen.dart';
import 'overlays/transfers_screen.dart';
import 'overlays/markets_overlay.dart';

class TradingPlatform extends StatefulWidget {
  const TradingPlatform({super.key});
  @override State<TradingPlatform> createState() => _TradingPlatformState();
}

class _TradingPlatformState extends State<TradingPlatform> {
  Timer? _priceTimer;

  @override
  void initState() {
    super.initState();
    _startPriceUpdates();
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    BinanceService.dispose();
    super.dispose();
  }

  void _startPriceUpdates() {
    _priceTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final store = context.read<AppStore>();
      for (final market in store.markets) {
        try {
          final ticker = await BinanceService.fetch24hTicker(market.symbol);
          if (ticker != null && mounted) {
            final price = double.tryParse(ticker['lastPrice']?.toString() ?? '') ?? market.price;
            final change = double.tryParse(ticker['priceChangePercent']?.toString() ?? '') ?? market.change;
            final high = double.tryParse(ticker['highPrice']?.toString() ?? '') ?? market.high24;
            final low = double.tryParse(ticker['lowPrice']?.toString() ?? '') ?? market.low24;
            final vol = double.tryParse(ticker['quoteVolume']?.toString() ?? '') ?? market.volume24;
            market.price = price;
            market.change = change;
            market.high24 = high;
            market.low24 = low;
            market.volume24 = vol;
          }
        } catch (_) {}
      }
      if (mounted) store.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final bg = store.isDark ? AppColors.bg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Column(
            children: [
              const TopBar(),
              const AssetBar(),
              const Expanded(child: TradingChart()),
              const BottomControls(),
              const NavBar(),
            ],
          ),

          if (store.toast.isNotEmpty)
            Positioned(
              bottom: 90, left: 24, right: 24,
              child: _ToastWidget(message: store.toast),
            ),

          if (store.overlay != ActiveOverlay.none) _buildOverlay(store),
        ],
      ),
    );
  }

  Widget _buildOverlay(AppStore store) {
    switch (store.overlay) {
      case ActiveOverlay.history: return const HistoryOverlay();
      case ActiveOverlay.signals: return const SignalsOverlay();
      case ActiveOverlay.indicators: return const IndicatorsOverlay();
      case ActiveOverlay.events: return const EventsOverlay();
      case ActiveOverlay.panel: return const PanelOverlay();
      case ActiveOverlay.expiry: return const ExpiryOverlay();
      case ActiveOverlay.deposit: return const DepositScreen();
      case ActiveOverlay.profile: return const ProfileScreen();
      case ActiveOverlay.transfers: return const TransfersScreen();
      case ActiveOverlay.markets: return const MarketsOverlay();
      default: return const SizedBox.shrink();
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  const _ToastWidget({required this.message});
  @override State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _isWin => widget.message.contains('WIN');
  bool get _isLoss => widget.message.contains('LOSS');

  @override
  Widget build(BuildContext context) {
    final color = _isWin ? AppColors.green : _isLoss ? AppColors.red : AppColors.accent;
    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_anim),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.message, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600))),
          ]),
        ),
      ),
    );
  }
}
