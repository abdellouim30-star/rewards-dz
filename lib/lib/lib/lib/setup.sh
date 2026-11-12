#!/usr/bin/env bash
set -e
if [ ! -d android ]; then
  mkdir -p /tmp/bak && cp -r lib /tmp/bak/lib && cp pubspec.yaml /tmp/bak/pubspec.yaml
  flutter create --platforms=android --org com.yourname --project-name rewards_dz .
  rm -rf lib test && cp -r /tmp/bak/lib lib && cp /tmp/bak/pubspec.yaml pubspec.yaml
fi
M=android/app/src/main/AndroidManifest.xml
grep -q "android.permission.INTERNET" $M || sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' $M
grep -q "gms.ads.APPLICATION_ID" $M || sed -i 's#</application>#    <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-3940256099942544~3347511713"/>\n    </application>#' $M
echo "done"
