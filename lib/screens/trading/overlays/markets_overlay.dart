import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class MarketsOverlay extends StatefulWidget {
  const MarketsOverlay({super.key});
  @override State<MarketsOverlay> createState() => _MarketsOverlayState();
}

class _MarketsOverlayState extends State<MarketsOverlay> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _tabs = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg : AppColors.lightBg;
    final bg2 = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;

    final allMarkets = store.markets;
    final filtered = _search.isEmpty ? allMarkets : allMarkets.where((m) => m.name.toLowerCase().contains(_search.toLowerCase()) || m.base.toLowerCase().contains(_search.toLowerCase())).toList();
    final crypto = filtered.where((m) => m.category == 'Crypto').toList();
    final forex = filtered.where((m) => m.category == 'Forex').toList();
    final gold = filtered.where((m) => m.category == 'Gold').toList();

    return Positioned.fill(
      child: Container(
        color: bg,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 0),
            decoration: BoxDecoration(color: bg2, border: Border(bottom: BorderSide(color: border))),
            child: Column(children: [
              Row(children: [
                Text('Markets', style: TextStyle(color: t1, fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                GestureDetector(onTap: () => store.setOverlay(ActiveOverlay.none), child: Icon(Icons.close, color: t3, size: 22)),
              ]),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: isDark ? AppColors.bg3 : AppColors.lightBg3, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: TextStyle(color: t1, fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: t3, size: 18),
                    hintText: 'Search markets...', hintStyle: TextStyle(color: t3),
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabs,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: t3,
                isScrollable: true,
                tabs: const [Tab(text: 'All'), Tab(text: 'Crypto'), Tab(text: 'Forex'), Tab(text: 'Gold')],
              ),
            ]),
          ),
          Expanded(child: TabBarView(
            controller: _tabs,
            children: [
              _marketList(filtered, store, isDark, t1, t3, border, bg2),
              _marketList(crypto, store, isDark, t1, t3, border, bg2),
              _marketList(forex, store, isDark, t1, t3, border, bg2),
              _marketList(gold, store, isDark, t1, t3, border, bg2),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _marketList(markets, AppStore store, bool isDark, Color t1, Color t3, Color border, Color bg2) {
    if (markets.isEmpty) return Center(child: Text('No markets found', style: TextStyle(color: t3)));
    return ListView.builder(
      itemCount: markets.length,
      itemBuilder: (ctx, i) {
        final m = markets[i];
        final selected = store.currentMarket?.id == m.id;
        return GestureDetector(
          onTap: () { store.setCurrentMarket(m); store.setOverlay(ActiveOverlay.none); },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent.withOpacity(0.08) : bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.accent.withOpacity(0.4) : border),
            ),
            child: Row(children: [
              CachedNetworkImage(
                imageUrl: m.iconUrl, width: 36, height: 36,
                imageBuilder: (ctx, img) => Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: img, fit: BoxFit.cover)),
                ),
                errorWidget: (ctx, _, __) => Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: AppColors.bg3, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(m.base.length >= 2 ? m.base.substring(0, 2) : m.base, style: const TextStyle(color: AppColors.t2, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(m.category, style: TextStyle(color: t3, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(m.price.toStringAsFixed(m.dec), style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                Text('${m.change >= 0 ? '+' : ''}${m.change.toStringAsFixed(2)}%', style: TextStyle(color: m.change >= 0 ? AppColors.green : AppColors.red, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}
