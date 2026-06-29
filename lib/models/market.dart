class Market {
  final String id;
  final String name;
  final String symbol;
  final String base;
  final String category;
  double price;
  double change;
  double high24;
  double low24;
  double volume24;
  final int dec;
  final int payout;

  Market({
    required this.id,
    required this.name,
    required this.symbol,
    required this.base,
    required this.category,
    required this.price,
    required this.change,
    required this.high24,
    required this.low24,
    required this.volume24,
    required this.dec,
    required this.payout,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'] ?? json['symbol'] ?? '',
      name: json['name'] ?? json['symbol'] ?? '',
      symbol: json['symbol'] ?? '',
      base: json['base'] ?? '',
      category: json['category'] ?? 'Crypto',
      price: (json['price'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      high24: (json['high24'] ?? 0.0).toDouble(),
      low24: (json['low24'] ?? 0.0).toDouble(),
      volume24: (json['volume24'] ?? 0.0).toDouble(),
      dec: (json['dec'] ?? 2).toInt(),
      payout: (json['payout'] ?? 82).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'symbol': symbol, 'base': base,
    'category': category, 'price': price, 'change': change,
    'high24': high24, 'low24': low24, 'volume24': volume24,
    'dec': dec, 'payout': payout,
  };

  String get iconUrl {
    final overrides = {
      'ton': 'https://i.ibb.co/S4RSYZjM/image.png',
      'xlm': 'https://i.ibb.co/k2v65TWY/image.png',
      'hmstr': 'https://i.ibb.co/3ynGyxFd/image.png',
      'jto': 'https://i.ibb.co/xSmTQrKx/image.png',
    };
    final lower = base.toLowerCase();
    return overrides[lower] ??
        'https://assets.coincap.io/assets/icons/${lower}@2x.png';
  }
}

List<Market> get defaultMarkets => [
  Market(id:'BTCUSDT', name:'BTC/USD', symbol:'BTCUSDT', base:'BTC', category:'Crypto', price:67000, change:0, high24:68000, low24:65000, volume24:1e9, dec:2, payout:82),
  Market(id:'ETHUSDT', name:'ETH/USD', symbol:'ETHUSDT', base:'ETH', category:'Crypto', price:3500, change:0, high24:3600, low24:3400, volume24:5e8, dec:2, payout:80),
  Market(id:'BNBUSDT', name:'BNB/USD', symbol:'BNBUSDT', base:'BNB', category:'Crypto', price:600, change:0, high24:620, low24:580, volume24:2e8, dec:2, payout:80),
  Market(id:'SOLUSDT', name:'SOL/USD', symbol:'SOLUSDT', base:'SOL', category:'Crypto', price:180, change:0, high24:190, low24:170, volume24:3e8, dec:2, payout:82),
  Market(id:'XRPUSDT', name:'XRP/USD', symbol:'XRPUSDT', base:'XRP', category:'Crypto', price:0.62, change:0, high24:0.65, low24:0.58, volume24:1e8, dec:4, payout:80),
  Market(id:'ADAUSDT', name:'ADA/USD', symbol:'ADAUSDT', base:'ADA', category:'Crypto', price:0.45, change:0, high24:0.48, low24:0.42, volume24:5e7, dec:4, payout:80),
  Market(id:'DOGEUSDT', name:'DOGE/USD', symbol:'DOGEUSDT', base:'DOGE', category:'Crypto', price:0.16, change:0, high24:0.17, low24:0.15, volume24:4e8, dec:5, payout:80),
  Market(id:'AVAXUSDT', name:'AVAX/USD', symbol:'AVAXUSDT', base:'AVAX', category:'Crypto', price:38, change:0, high24:40, low24:36, volume24:1e8, dec:2, payout:82),
  Market(id:'PAXGUSDT', name:'PAXG/USD', symbol:'PAXGUSDT', base:'PAXG', category:'Gold', price:2300, change:0, high24:2320, low24:2280, volume24:1e7, dec:2, payout:78),
  Market(id:'EURUSDT', name:'EUR/USD', symbol:'EURUSDT', base:'EUR', category:'Forex', price:1.085, change:0, high24:1.090, low24:1.080, volume24:5e7, dec:4, payout:75),
  Market(id:'GBPUSDT', name:'GBP/USD', symbol:'GBPUSDT', base:'GBP', category:'Forex', price:1.27, change:0, high24:1.275, low24:1.265, volume24:3e7, dec:4, payout:75),
];
