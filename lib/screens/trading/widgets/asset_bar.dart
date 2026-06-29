import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/app_store.dart';

class AssetBar extends StatelessWidget {
  const AssetBar({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isDark = store.isDark;
    final bg = isDark ? AppColors.bg2 : AppColors.lightBg2;
    final border = isDark ? AppColors.border : AppColors.lightBorder;
    final t1 = isDark ? AppColors.t1 : AppColors.lightT1;
    final t3 = isDark ? AppColors.t3 : AppColors.lightT3;
    final mkt = store.currentMarket;

    return Container(
      height: 64,
      decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: border))),
      child: Row(children: [
        GestureDetector(
          onTap: () => store.setOverlay(ActiveOverlay.markets),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              if (mkt != null) ...[
                _assetIcon(mkt.iconUrl, mkt.base),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(mkt.name, style: TextStyle(color: t1, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(mkt.category, style: TextStyle(color: t3, fontSize: 11)),
                ]),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down, color: t3, size: 16),
              ],
            ]),
          ),
        ),

        Container(width: 1, height: 32, color: border),

        if (mkt != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(mkt.price.toStringAsFixed(mkt.dec), style: TextStyle(color: t1, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
              Row(children: [
                Icon(mkt.change >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: mkt.change >= 0 ? AppColors.green : AppColors.red, size: 16),
                Text('${mkt.change >= 0 ? '+' : ''}${mkt.change.toStringAsFixed(2)}%', style: TextStyle(color: mkt.change >= 0 ? AppColors.green : AppColors.red, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
          Container(width: 1, height: 32, color: border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Payout', style: TextStyle(color: t3, fontSize: 10)),
              Text('${mkt.payout}%', style: const TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],

        const Spacer(),
        _tfSelector(context, store, t1, t3, border, bg),
      ]),
    );
  }

  Widget _assetIcon(String url, String base) {
    return CachedNetworkImage(
      imageUrl: url,
      width: 30, height: 30,
      imageBuilder: (ctx, img) => Container(
        width: 30, height: 30,
        decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: img, fit: BoxFit.cover)),
      ),
      errorWidget: (ctx, _, __) => Container(
        width: 30, height: 30,
        decoration: const BoxDecoration(color: AppColors.bg3, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(base.substring(0, base.length < 2 ? base.length : 2), style: const TextStyle(color: AppColors.t2, fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _tfSelector(BuildContext context, AppStore store, Color t1, Color t3, Color border, Color bg) {
    final tfs = ['1m', '5m', '15m', '1h', '4h'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: tfs.map((tf) {
          final active = store.currentTF == tf;
          return GestureDetector(
            onTap: () => store.setCurrentTF(tf),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: active ? AppColors.accent : border),
              ),
              child: Text(tf, style: TextStyle(color: active ? Colors.white : t3, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
