import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';
import '../../../services/binance_service.dart';

class TradingChart extends StatefulWidget {
  const TradingChart({super.key});
  @override State<TradingChart> createState() => _TradingChartState();
}

class _TradingChartState extends State<TradingChart> {
  List<Candle> _candles = [];
  WebSocketChannel? _ws;
  bool _loading = true;
  String? _loadedSymbol;
  String? _loadedTF;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChart());
  }

  @override
  void dispose() {
    _ws?.sink.close();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadChart() async {
    final store = context.read<AppStore>();
    final mkt = store.currentMarket;
    if (mkt == null) return;
    if (_loadedSymbol == mkt.symbol && _loadedTF == store.currentTF) return;

    setState(() { _loading = true; _candles = []; });
    _ws?.sink.close();

    final interval = store.currentTF;
    final symbol = mkt.symbol;
    _loadedSymbol = symbol;
    _loadedTF = interval;

    try {
      final klines = await BinanceService.fetchKlines(symbol, interval);
      if (!mounted) return;
      setState(() {
        _candles = klines.map((k) => Candle(
          date: DateTime.fromMillisecondsSinceEpoch(k.time * 1000),
          open: k.open, high: k.high, low: k.low, close: k.close, volume: k.volume,
        )).toList();
        _loading = false;
      });
      _connectWebSocket(symbol, interval);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _connectWebSocket(String symbol, String interval) {
    try {
      _ws = BinanceService.subscribeToKline(symbol, interval);
      _ws!.stream.listen((data) {
        if (!mounted) return;
        try {
          final json = jsonDecode(data.toString());
          final k = json['k'];
          if (k == null) return;
          final newCandle = Candle(
            date: DateTime.fromMillisecondsSinceEpoch((k['t'] as int)),
            open: double.parse(k['o'].toString()),
            high: double.parse(k['h'].toString()),
            low: double.parse(k['l'].toString()),
            close: double.parse(k['c'].toString()),
            volume: double.parse(k['v'].toString()),
          );
          setState(() {
            if (_candles.isNotEmpty) {
              if (_candles.last.date.millisecondsSinceEpoch == newCandle.date.millisecondsSinceEpoch) {
                _candles[_candles.length - 1] = newCandle;
              } else {
                _candles.add(newCandle);
                if (_candles.length > 1000) _candles.removeAt(0);
              }
            }
          });
          final price = double.parse(k['c'].toString());
          context.read<AppStore>().updateMarketPrice(symbol, price, 0);
        } catch (_) {}
      }, onError: (_) {
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) _connectWebSocket(symbol, interval);
        });
      });
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.watch<AppStore>();
    final mkt = store.currentMarket;
    if (mkt != null && (mkt.symbol != _loadedSymbol || store.currentTF != _loadedTF)) {
      _loadChart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;

    if (_loading) {
      return Container(
        color: bg,
        child: const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
      );
    }

    if (_candles.isEmpty) {
      return Container(
        color: bg,
        child: const Center(child: Text('No chart data', style: TextStyle(color: AppColors.t3))),
      );
    }

    return Container(
      color: bg,
      child: Candlesticks(
        candles: _candles,
        onLoadMoreCandles: () async {},
        actions: [
          ToolBarAction(
            child: const Icon(Icons.fullscreen, color: AppColors.t3, size: 18),
            onPressed: () => store.setChartExpanded(!store.chartExpanded),
          ),
        ],
      ),
    );
  }
}
