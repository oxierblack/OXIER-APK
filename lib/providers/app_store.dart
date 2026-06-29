import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market.dart';
import '../models/trade.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

enum AppScreen { splash, login, register, verify, pin, trading }
enum ActiveOverlay { none, history, signals, indicators, events, panel, expiry, deposit, profile, transfers, markets }

class UserInfo {
  final String email;
  final String name;
  final String token;
  UserInfo({required this.email, required this.name, required this.token});
  factory UserInfo.fromJson(Map<String, dynamic> j) =>
      UserInfo(email: j['email'] ?? '', name: j['name'] ?? '', token: j['token'] ?? '');
  Map<String, dynamic> toJson() => {'email': email, 'name': name, 'token': token};
}

class AppStore extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _initialized = false;

  AppScreen screen = AppScreen.splash;
  bool isDark = true;
  String walType = 'demo';
  double demoBalance = 10000;
  double realBalance = 0;
  List<Market> markets = [];
  Market? currentMarket;
  String currentTF = '1m';
  double amount = 10;
  int expMin = 1;
  String expDisp = '1m';
  List<Trade> trades = [];
  List<Transaction> transactions = [];
  ActiveOverlay overlay = ActiveOverlay.none;
  String toast = '';
  UserInfo? userInfo;
  List<String> activeInds = [];
  bool chartExpanded = false;
  bool soundEnabled = true;
  Map<String, Map<String, double>> indicatorSettings = {};
  String verifyEmail = '';
  Timer? _toastTimer;

  double get balance => walType == 'demo' ? demoBalance : realBalance;
  List<Trade> get openTrades => trades.where((t) => !t.resolved).toList();

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    isDark = _prefs.getString('ox_theme') != 'light';
    demoBalance = double.tryParse(_prefs.getString('ox_demo_bal') ?? '') ?? 10000;
    realBalance = double.tryParse(_prefs.getString('ox_real_bal') ?? '') ?? 0;
    final tradesRaw = _prefs.getString('ox_trades') ?? '[]';
    trades = tradesFromJson(tradesRaw);
    final txRaw = _prefs.getString('ox_transactions') ?? '[]';
    transactions = transactionsFromJson(txRaw);
    final userRaw = _prefs.getString('ox_user');
    if (userRaw != null) {
      try { userInfo = UserInfo.fromJson(jsonDecode(userRaw)); } catch (_) {}
    }
    markets = defaultMarkets;
    currentMarket = markets.first;
    _initialized = true;
    notifyListeners();
  }

  void setScreen(AppScreen s) { screen = s; notifyListeners(); }
  void toggleTheme() {
    isDark = !isDark;
    _prefs.setString('ox_theme', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  void setWalType(String t) { walType = t; notifyListeners(); }
  void setDemoBalance(double n) {
    demoBalance = n;
    _prefs.setString('ox_demo_bal', n.toString());
    notifyListeners();
  }
  void setRealBalance(double n) {
    realBalance = n;
    _prefs.setString('ox_real_bal', n.toString());
    notifyListeners();
  }
  void adjustBalance(double delta, {String? type}) {
    final t = type ?? walType;
    if (t == 'demo') setDemoBalance((demoBalance + delta).clamp(0, double.infinity));
    else setRealBalance((realBalance + delta).clamp(0, double.infinity));
  }

  void setMarkets(List<Market> m) { markets = m; notifyListeners(); }
  void setCurrentMarket(Market m) { currentMarket = m; notifyListeners(); }
  void setCurrentTF(String tf) { currentTF = tf; notifyListeners(); }
  void setAmount(double n) { amount = n; notifyListeners(); }
  void setExpiry(int min, String disp) { expMin = min; expDisp = disp; notifyListeners(); }

  void addTrade(Trade t) {
    trades.add(t);
    _saveTrades();
    notifyListeners();
  }

  void resolveTrade(String id, double exit, bool won) {
    final idx = trades.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    trades[idx].resolved = true;
    trades[idx].exit = exit;
    trades[idx].won = won;
    trades[idx].profit = won ? trades[idx].amount * (trades[idx].payout / 100) : -trades[idx].amount;
    trades[idx].resolvedAt = DateTime.now().millisecondsSinceEpoch;
    _saveTrades();
    notifyListeners();
  }

  void earlyCloseTrade(String id, double exit) {
    final idx = trades.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    trades[idx].resolved = true;
    trades[idx].exit = exit;
    trades[idx].won = false;
    trades[idx].earlyClosed = true;
    trades[idx].profit = -(trades[idx].amount / 2);
    trades[idx].resolvedAt = DateTime.now().millisecondsSinceEpoch;
    adjustBalance(trades[idx].amount / 2);
    _saveTrades();
    notifyListeners();
  }

  void _saveTrades() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final recent = trades.where((t) =>
      !t.resolved || (t.resolvedAt != null && now - t.resolvedAt! < 86400000 * 7)).toList();
    _prefs.setString('ox_trades', tradesToJson(recent));
  }

  void addTransaction(Transaction tx) {
    transactions.insert(0, tx);
    _prefs.setString('ox_transactions', transactionsToJson(transactions));
    notifyListeners();
  }

  void updateTransactionStatus(String id, String status) {
    final idx = transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    transactions[idx].status = status;
    _prefs.setString('ox_transactions', transactionsToJson(transactions));
    notifyListeners();
  }

  void setOverlay(ActiveOverlay o) { overlay = o; notifyListeners(); }

  void showToast(String msg) {
    toast = msg;
    notifyListeners();
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      toast = '';
      notifyListeners();
    });
  }

  void setUserInfo(UserInfo? u) {
    userInfo = u;
    _prefs.setString('ox_user', u != null ? jsonEncode(u.toJson()) : 'null');
    notifyListeners();
    if (u != null && u.token.isNotEmpty && u.token != 'demo') {
      _fetchRemoteBalanceAndHistory(u.token);
    }
  }

  Future<void> _fetchRemoteBalanceAndHistory(String token) async {
    try {
      final balData = await ApiService.get('/api/trade/balance', token: token);
      if (balData != null) {
        if (balData['demoBalance'] != null) setDemoBalance((balData['demoBalance']).toDouble());
        if (balData['realBalance'] != null) setRealBalance((balData['realBalance']).toDouble());
      }
    } catch (_) {}
    try {
      final histData = await ApiService.getList('/api/trade/history', token: token);
      if (histData != null) {
        trades = histData.map<Trade>((t) => Trade(
          id: t['id'] ?? t['_id'] ?? '',
          mktId: t['mktId'] ?? t['symbol'] ?? '',
          mktName: t['symbol'] ?? t['mktName'] ?? '',
          side: (t['direction'] ?? t['side'] ?? 'buy'),
          amount: (t['amount'] ?? 0).toDouble(),
          entry: (t['entryPrice'] ?? t['entry'] ?? 0).toDouble(),
          exit: t['exitPrice']?.toDouble() ?? t['exit']?.toDouble(),
          payout: (t['payout'] ?? 80).toInt(),
          dec: (t['dec'] ?? 2).toInt(),
          expiryAt: t['expiryAt'] != null ? DateTime.parse(t['expiryAt']).millisecondsSinceEpoch
              : (t['settledAt'] != null ? DateTime.parse(t['settledAt']).millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch),
          openedAt: t['openedAt'] != null ? DateTime.parse(t['openedAt']).millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch,
          resolvedAt: t['settledAt'] != null ? DateTime.parse(t['settledAt']).millisecondsSinceEpoch : null,
          resolved: t['settledAt'] != null,
          won: t['result'] == 'win',
          profit: t['profit']?.toDouble(),
          walType: t['walletType'] ?? 'real',
        )).toList();
        _saveTrades();
        notifyListeners();
      }
    } catch (_) {}
  }

  void toggleInd(String id) {
    if (activeInds.contains(id)) activeInds.remove(id);
    else activeInds.add(id);
    notifyListeners();
  }

  void setIndicatorParam(String id, String key, double value) {
    indicatorSettings[id] ??= {};
    indicatorSettings[id]![key] = value;
    notifyListeners();
  }

  void setSoundEnabled(bool v) { soundEnabled = v; notifyListeners(); }
  void setChartExpanded(bool v) { chartExpanded = v; notifyListeners(); }

  void updateMarketPrice(String symbol, double price, double change) {
    final idx = markets.indexWhere((m) => m.symbol == symbol);
    if (idx != -1) {
      markets[idx].price = price;
      markets[idx].change = change;
      if (currentMarket?.symbol == symbol) {
        currentMarket = markets[idx];
      }
      notifyListeners();
    }
  }
}
