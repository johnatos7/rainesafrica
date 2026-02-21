// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Nunito-Bold.ttf
  String get nunitoBold => 'assets/fonts/Nunito-Bold.ttf';

  /// File path: assets/fonts/Nunito-Light.ttf
  String get nunitoLight => 'assets/fonts/Nunito-Light.ttf';

  /// File path: assets/fonts/Nunito-Medium.ttf
  String get nunitoMedium => 'assets/fonts/Nunito-Medium.ttf';

  /// File path: assets/fonts/Nunito-Regular.ttf
  String get nunitoRegular => 'assets/fonts/Nunito-Regular.ttf';

  /// List of all assets
  List<String> get values => [
    nunitoBold,
    nunitoLight,
    nunitoMedium,
    nunitoRegular,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/banktransfer.png
  AssetGenImage get banktransfer =>
      const AssetGenImage('assets/images/banktransfer.png');

  /// Directory path: assets/images/bn
  $AssetsImagesBnGen get bn => const $AssetsImagesBnGen();

  /// File path: assets/images/cash2.png
  AssetGenImage get cash2 => const AssetGenImage('assets/images/cash2.png');

  /// Directory path: assets/images/de
  $AssetsImagesDeGen get de => const $AssetsImagesDeGen();

  /// File path: assets/images/dpozambia.png
  AssetGenImage get dpozambia =>
      const AssetGenImage('assets/images/dpozambia.png');

  /// Directory path: assets/images/en
  $AssetsImagesEnGen get en => const $AssetsImagesEnGen();

  /// Directory path: assets/images/es
  $AssetsImagesEsGen get es => const $AssetsImagesEsGen();

  /// Directory path: assets/images/fr
  $AssetsImagesFrGen get fr => const $AssetsImagesFrGen();

  /// Directory path: assets/images/ja
  $AssetsImagesJaGen get ja => const $AssetsImagesJaGen();

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/logo.png.placeholder
  String get logoPng => 'assets/images/logo.png.placeholder';

  /// File path: assets/images/logo_dark.png
  AssetGenImage get logoDark =>
      const AssetGenImage('assets/images/logo_dark.png');

  /// File path: assets/images/logo_light.png
  AssetGenImage get logoLight =>
      const AssetGenImage('assets/images/logo_light.png');

  /// File path: assets/images/logo_sm.png
  AssetGenImage get logoSm => const AssetGenImage('assets/images/logo_sm.png');

  /// File path: assets/images/payfast.png
  AssetGenImage get payfast => const AssetGenImage('assets/images/payfast.png');

  /// File path: assets/images/pese2.png
  AssetGenImage get pese2 => const AssetGenImage('assets/images/pese2.png');

  /// File path: assets/images/slide_1.jpg
  AssetGenImage get slide1 => const AssetGenImage('assets/images/slide_1.jpg');

  /// File path: assets/images/yoco.png
  AssetGenImage get yoco => const AssetGenImage('assets/images/yoco.png');

  /// List of all assets
  List<dynamic> get values => [
    banktransfer,
    cash2,
    dpozambia,
    logo,
    logoPng,
    logoDark,
    logoLight,
    logoSm,
    payfast,
    pese2,
    slide1,
    yoco,
  ];
}

class $AssetsSplashGen {
  const $AssetsSplashGen();

  /// File path: assets/splash/splash-land.png
  AssetGenImage get splashLand =>
      const AssetGenImage('assets/splash/splash-land.png');

  /// File path: assets/splash/splash.png
  AssetGenImage get splash => const AssetGenImage('assets/splash/splash.png');

  /// List of all assets
  List<AssetGenImage> get values => [splashLand, splash];
}

class $AssetsImagesBnGen {
  const $AssetsImagesBnGen();

  /// File path: assets/images/bn/welcome.png.placeholder
  String get welcomePng => 'assets/images/bn/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesDeGen {
  const $AssetsImagesDeGen();

  /// File path: assets/images/de/welcome.png.placeholder
  String get welcomePng => 'assets/images/de/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesEnGen {
  const $AssetsImagesEnGen();

  /// File path: assets/images/en/welcome.png.placeholder
  String get welcomePng => 'assets/images/en/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesEsGen {
  const $AssetsImagesEsGen();

  /// File path: assets/images/es/welcome.png.placeholder
  String get welcomePng => 'assets/images/es/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesFrGen {
  const $AssetsImagesFrGen();

  /// File path: assets/images/fr/welcome.png.placeholder
  String get welcomePng => 'assets/images/fr/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class $AssetsImagesJaGen {
  const $AssetsImagesJaGen();

  /// File path: assets/images/ja/welcome.png.placeholder
  String get welcomePng => 'assets/images/ja/welcome.png.placeholder';

  /// List of all assets
  List<String> get values => [welcomePng];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSplashGen splash = $AssetsSplashGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
