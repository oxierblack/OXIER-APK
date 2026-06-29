class ApiConstants {
  static const String backend = 'https://oxier-backend-production.up.railway.app';
  static const String binanceRest = 'https://api.binance.com/api/v3';
  static const String binanceWs = 'wss://stream.binance.com:9443/ws';
  static const String coincapIcons = 'https://assets.coincap.io/assets/icons';

  static const String loginPath = '/api/auth/login';
  static const String registerPath = '/api/auth/register';
  static const String verifyPath = '/api/auth/verify';
  static const String balancePath = '/api/trade/balance';
  static const String historyPath = '/api/trade/history';
  static const String depositPath = '/api/deposit/request';
  static const String withdrawPath = '/api/withdraw/request';
  static const String profilePath = '/api/user/profile';
  static const String signalsPath = '/api/signals';
  static const String eventsPath = '/api/events';
}
