import 'dart:convert';

class Transaction {
  final String id;
  final String type;
  final String desc;
  final double amount;
  String status;
  final int date;
  final String? method;
  final String? currency;

  Transaction({
    required this.id,
    required this.type,
    required this.desc,
    required this.amount,
    required this.status,
    required this.date,
    this.method,
    this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'] ?? '',
    type: j['type'] ?? 'deposit',
    desc: j['desc'] ?? '',
    amount: (j['amount'] ?? 0).toDouble(),
    status: j['status'] ?? 'pending',
    date: (j['date'] ?? 0).toInt(),
    method: j['method'],
    currency: j['currency'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'desc': desc, 'amount': amount,
    'status': status, 'date': date, 'method': method, 'currency': currency,
  };
}

List<Transaction> transactionsFromJson(String raw) {
  try {
    final list = jsonDecode(raw) as List;
    return list.map((e) => Transaction.fromJson(e)).toList();
  } catch (_) { return []; }
}

String transactionsToJson(List<Transaction> txs) =>
    jsonEncode(txs.map((t) => t.toJson()).toList());
