import 'dart:convert';

class Trade {
  final String id;
  final String mktId;
  final String mktName;
  final String side;
  final double amount;
  final double entry;
  final int dec;
  final int payout;
  final String walType;
  final int openedAt;
  final int expiryAt;
  bool resolved;
  double? exit;
  bool? won;
  double? profit;
  int? resolvedAt;
  bool earlyClosed;

  Trade({
    required this.id,
    required this.mktId,
    required this.mktName,
    required this.side,
    required this.amount,
    required this.entry,
    required this.dec,
    required this.payout,
    required this.walType,
    required this.openedAt,
    required this.expiryAt,
    this.resolved = false,
    this.exit,
    this.won,
    this.profit,
    this.resolvedAt,
    this.earlyClosed = false,
  });

  factory Trade.fromJson(Map<String, dynamic> j) => Trade(
    id: j['id'] ?? '',
    mktId: j['mktId'] ?? '',
    mktName: j['mktName'] ?? '',
    side: j['side'] ?? 'buy',
    amount: (j['amount'] ?? 0).toDouble(),
    entry: (j['entry'] ?? 0).toDouble(),
    dec: (j['dec'] ?? 2).toInt(),
    payout: (j['payout'] ?? 82).toInt(),
    walType: j['walType'] ?? 'demo',
    openedAt: (j['openedAt'] ?? 0).toInt(),
    expiryAt: (j['expiryAt'] ?? 0).toInt(),
    resolved: j['resolved'] ?? false,
    exit: j['exit']?.toDouble(),
    won: j['won'],
    profit: j['profit']?.toDouble(),
    resolvedAt: j['resolvedAt']?.toInt(),
    earlyClosed: j['earlyClosed'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'mktId': mktId, 'mktName': mktName, 'side': side,
    'amount': amount, 'entry': entry, 'dec': dec, 'payout': payout,
    'walType': walType, 'openedAt': openedAt, 'expiryAt': expiryAt,
    'resolved': resolved, 'exit': exit, 'won': won, 'profit': profit,
    'resolvedAt': resolvedAt, 'earlyClosed': earlyClosed,
  };

  int get remainingMs => expiryAt - DateTime.now().millisecondsSinceEpoch;
  bool get isExpired => remainingMs <= 0;
}

List<Trade> tradesFromJson(String raw) {
  try {
    final list = jsonDecode(raw) as List;
    return list.map((e) => Trade.fromJson(e)).toList();
  } catch (_) { return []; }
}

String tradesToJson(List<Trade> trades) => jsonEncode(trades.map((t) => t.toJson()).toList());
