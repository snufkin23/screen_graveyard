import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Test banner ad widget.
///
/// Uses Google's test ad unit ID by default. Swap [adUnitId] for a real
/// AdMob unit when the app is ready for production.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key, this.adUnitId});

  /// Override for production AdMob unit ID.
  final String? adUnitId;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static const String _testAdUnitId = '/6499/example/banner';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    BannerAd(
      adUnitId: widget.adUnitId ?? _testAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('AdBanner failed to load: $error');
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
