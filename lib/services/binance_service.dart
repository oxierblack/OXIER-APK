import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_constants.dart';

class CandleData {
  final int time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  CandleData({required this.time, required this.open, required this.high, required this.low, required this.close, required this.volume});
}

class BinanceService {
  static WebSocketChannel? _channel;
  static String? _currentStream;

  static Future<List<CandleData>> fetchKlines(String symbol, String interval, {int limit = 500}) async {
    try {
      final url = '${ApiConstants.binanceRest}/klines?symbol=$symbol&interval=$interval&limit=$limit';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        return data.map((d) => CandleData(
          time: (d[0] as int) ~/ 1000,
          open: double.parse(d[1].toString()),
          high: double.parse(d[2].toString()),
          low: double.parse(d[3].toString()),
          close: double.parse(d[4].toString()),
          volume: double.parse(d[5].toString()),
        )).toList();
      }
    } catch (_) {}
    return _generateSimData(1000, interval);
  }

  static Future<double?> fetchCurrentPrice(String symbol) async {
    try {
      final url = '${ApiConstants.binanceRest}/ticker/price?symbol=$symbol';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return double.tryParse(data['price'].toString());
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> fetch24hTicker(String symbol) async {
    try {
      final url = '${ApiConstants.binanceRest}/ticker/24hr?symbol=$symbol';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static WebSocketChannel subscribeToKline(String symbol, String interval) {
    final stream = '${symbol.toLowerCase()}@kline_$interval';
    if (_currentStream != stream) {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse('${ApiConstants.binanceWs}/$stream'));
      _currentStream = stream;
    }
    return _channel!;
  }

  static WebSocketChannel subscribeToMiniTicker(List<String> symbols) {
    _channel?.sink.close();
    final streams = symbols.map((s) => '${s.toLowerCase()}@miniTicker').join('/');
    _channel = WebSocketChannel.connect(Uri.parse('wss://stream.binance.com:9443/stream?streams=$streams'));
    return _channel!;
  }

  static void dispose() {
    _channel?.sink.close();
    _channel = null;
    _currentStream = null;
  }

  static List<CandleData> _generateSimData(double price, String tf) {
    final bars = <CandleData>[];
    double p = price;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final step = _tfToSeconds(tf);
    final rng = Random();
    for (int i = 499; i >= 0; i--) {
      final t = now - i * step;
      final open = p;
      final chg = (rng.nextDouble() - 0.48) * p * 0.018;
      final close = max(p * 0.01, p + chg);
      final high = max(open, close) + rng.nextDouble() * chg.abs() * 0.5;
      final low = min(open, close) - rng.nextDouble() * chg.abs() * 0.5;
      bars.add(CandleData(time: t, open: open, high: high, low: low, close: close, volume: rng.nextDouble() * 1e6));
      p = close;
    }
    return bars;
  }

  static int _tfToSeconds(String tf) {
    switch (tf) {
      case '1m': return 60;
      case '5m': return 300;
      case '15m': return 900;
      case '1h': return 3600;
      case '4h': return 14400;
      default: return 60;
    }
  }
}
