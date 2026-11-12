import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static Future<void> init() => MobileAds.instance.initialize();

  static void showRewarded({required void Function() onReward, required void Function() onFail}) {
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          bool earned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) {
              a.dispose();
              if (!earned) onFail();
            },
            onAdFailedToShowFullScreenContent: (a, e) {
              a.dispose();
              onFail();
            },
          );
          ad.show(onUserEarnedReward: (_, __) {
            earned = true;
            onReward();
          });
        },
        onAdFailedToLoad: (_) => onFail(),
      ),
    );
  }
}
