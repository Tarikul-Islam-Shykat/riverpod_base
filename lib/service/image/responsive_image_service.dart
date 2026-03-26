// ignore_for_file: unnecessary_underscores

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Enums
// ─────────────────────────────────────────────────────────────────────────────

enum ImageShape {
  rectangle,
  roundedRectangle,
  circle,
}

enum ImageSourceType { network, asset, file }

// ─────────────────────────────────────────────────────────────────────────────
//  Asset image cache helper
//  Flutter's ImageCache already caches decoded images in memory. This helper
//  pre-warms a specific asset into that cache so the first paint is instant.
// ─────────────────────────────────────────────────────────────────────────────

class AssetImageCacheHelper {
  AssetImageCacheHelper._();

  /// Pre-loads [assetPath] into Flutter's in-memory image cache.
  /// Call this once (e.g. in initState or a splash screen) to warm the cache.
  static Future<void> prewarm(
    BuildContext context,
    String assetPath,
  ) async {
    await precacheImage(AssetImage(assetPath), context);
  }

  /// Pre-loads a list of asset paths in parallel.
  static Future<void> prewarmAll(
    BuildContext context,
    List<String> assetPaths,
  ) async {
    await Future.wait(
      assetPaths.map((path) => precacheImage(AssetImage(path), context)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Full-screen viewer
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenImageViewer extends StatelessWidget {
  final Widget imageWidget;
  final String? heroTag;

  const _FullScreenImageViewer({required this.imageWidget, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: heroTag != null
                  ? Hero(tag: heroTag!, child: imageWidget)
                  : imageWidget,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ResponsiveImage
// ─────────────────────────────────────────────────────────────────────────────

class ResponsiveImage extends StatelessWidget {
  /// The image source: URL for network, asset path for asset, file path for file.
  final String imageSource;

  /// Where the image comes from.
  final ImageSourceType sourceType;

  /// Visual shape: [ImageShape.rectangle], [ImageShape.roundedRectangle],
  /// or [ImageShape.circle].
  final ImageShape shape;

  /// Corner radius — only applies to [ImageShape.roundedRectangle].
  final double borderRadius;

  // ── Optional border ──────────────────────────────────────────────────────

  /// Adds a colored border around the image when set.
  final Color? borderColor;

  /// Width of the border. Defaults to 2.0 when [borderColor] is provided.
  final double borderWidth;

  // ── Sizing ────────────────────────────────────────────────────────────────

  /// Width as a fraction of screen width (0.0–1.0). Overrides [width].
  final double? widthPercent;

  /// Height as a fraction of screen height (0.0–1.0). Overrides [height].
  final double? heightPercent;

  /// Absolute width in logical pixels.
  final double? width;

  /// Absolute height in logical pixels.
  final double? height;

  // ── Image options ─────────────────────────────────────────────────────────

  /// How the image is inscribed into its box.
  final BoxFit fit;

  /// Custom loading placeholder (network only).
  final Widget? placeholderWidget;

  /// Custom error widget (all source types).
  final Widget? errorWidget;

  // ── Network cache options ─────────────────────────────────────────────────

  /// Maximum width (in logical pixels) to decode and cache the network image.
  /// Use this to avoid storing a 4K image when you only display it at 200px.
  /// Defaults to 200. Pass null to let CachedNetworkImage decide.
  final int? memCacheWidth;

  /// Maximum height (in logical pixels) to decode and cache the network image.
  /// Defaults to null (unconstrained). Often you only need [memCacheWidth].
  final int? memCacheHeight;

  // ── Interaction ───────────────────────────────────────────────────────────

  /// Opens a full-screen viewer when the image is tapped.
  final bool enableImageView;

  /// Optional hero animation tag for the full-screen transition.
  final String? heroTag;

  const ResponsiveImage({
    Key? key,
    required this.imageSource,
    this.sourceType = ImageSourceType.network,
    this.shape = ImageShape.roundedRectangle,
    this.borderRadius = 8.0,
    this.borderColor,
    this.borderWidth = 2.0,
    this.widthPercent,
    this.heightPercent,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderWidget,
    this.errorWidget,
    this.memCacheWidth = 200,
    this.memCacheHeight,
    this.enableImageView = false,
    this.heroTag,
  }) : super(key: key);

  // ── Named constructors ────────────────────────────────────────────────────

  /// Network image with in-memory cache size control.
  const ResponsiveImage.network({
    Key? key,
    required String url,
    ImageShape shape = ImageShape.roundedRectangle,
    double borderRadius = 8.0,
    Color? borderColor,
    double borderWidth = 2.0,
    double? widthPercent,
    double? heightPercent,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholderWidget,
    Widget? errorWidget,
    int? memCacheWidth = 200,
    int? memCacheHeight,
    bool enableImageView = false,
    String? heroTag,
  }) : this(
         key: key,
         imageSource: url,
         sourceType: ImageSourceType.network,
         shape: shape,
         borderRadius: borderRadius,
         borderColor: borderColor,
         borderWidth: borderWidth,
         widthPercent: widthPercent,
         heightPercent: heightPercent,
         width: width,
         height: height,
         fit: fit,
         placeholderWidget: placeholderWidget,
         errorWidget: errorWidget,
         memCacheWidth: memCacheWidth,
         memCacheHeight: memCacheHeight,
         enableImageView: enableImageView,
         heroTag: heroTag,
       );

  /// Asset image — Flutter's ImageCache is used automatically.
  /// Pre-warm with [AssetImageCacheHelper.prewarm] for instant first paint.
  const ResponsiveImage.asset({
    Key? key,
    required String assetPath,
    ImageShape shape = ImageShape.roundedRectangle,
    double borderRadius = 8.0,
    Color? borderColor,
    double borderWidth = 2.0,
    double? widthPercent,
    double? heightPercent,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    bool enableImageView = false,
    String? heroTag,
  }) : this(
         key: key,
         imageSource: assetPath,
         sourceType: ImageSourceType.asset,
         shape: shape,
         borderRadius: borderRadius,
         borderColor: borderColor,
         borderWidth: borderWidth,
         widthPercent: widthPercent,
         heightPercent: heightPercent,
         width: width,
         height: height,
         fit: fit,
         errorWidget: errorWidget,
         enableImageView: enableImageView,
         heroTag: heroTag,
       );

  /// Local file image (e.g. picked from gallery).
  const ResponsiveImage.file({
    Key? key,
    required String filePath,
    ImageShape shape = ImageShape.roundedRectangle,
    double borderRadius = 8.0,
    Color? borderColor,
    double borderWidth = 2.0,
    double? widthPercent,
    double? heightPercent,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    bool enableImageView = false,
    String? heroTag,
  }) : this(
         key: key,
         imageSource: filePath,
         sourceType: ImageSourceType.file,
         shape: shape,
         borderRadius: borderRadius,
         borderColor: borderColor,
         borderWidth: borderWidth,
         widthPercent: widthPercent,
         heightPercent: heightPercent,
         width: width,
         height: height,
         fit: fit,
         errorWidget: errorWidget,
         enableImageView: enableImageView,
         heroTag: heroTag,
       );

  // ── Resolve sizes ─────────────────────────────────────────────────────────

  double? _resolveWidth(BuildContext context) {
    if (widthPercent != null) {
      return MediaQuery.of(context).size.width * widthPercent!;
    }
    return width;
  }

  double? _resolveHeight(BuildContext context) {
    if (heightPercent != null) {
      return MediaQuery.of(context).size.height * heightPercent!;
    }
    return height;
  }

  // ── Build raw image ───────────────────────────────────────────────────────

  Widget _buildRawImage(BuildContext context, double? w, double? h) {
    final fallbackError =
        errorWidget ??
        Container(
          width: w ?? double.infinity,
          height: h ?? double.infinity,
          color: Colors.grey[850],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
          ),
        );

    switch (sourceType) {
      case ImageSourceType.network:
        return CachedNetworkImage(
          imageUrl: imageSource,
          width: w,
          height: h,
          fit: fit,
          // Constrain the decoded image stored in memory.
          // 200px default keeps RAM usage low for thumbnail-heavy feeds.
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          placeholder: (_, __) =>
              placeholderWidget ??
              Container(
                width: w ?? double.infinity,
                height: h ?? double.infinity,
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          errorWidget: (_, __, ___) => fallbackError,
        );

      case ImageSourceType.asset:
        // Image.asset uses Flutter's ImageCache automatically.
        // For instant first-paint, pre-warm with AssetImageCacheHelper.prewarm().
        return Image.asset(
          imageSource,
          width: w,
          height: h,
          fit: fit,
          // cacheWidth / cacheHeight resize the decoded bitmap stored in the
          // ImageCache, reducing memory usage the same way memCacheWidth does
          // for network images. Omit to cache at native resolution.
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          errorBuilder: (_, __, ___) => fallbackError,
        );

      case ImageSourceType.file:
        return Image.file(
          File(imageSource),
          width: w,
          height: h,
          fit: fit,
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          errorBuilder: (_, __, ___) => fallbackError,
        );
    }
  }

  // ── Apply shape clipping ──────────────────────────────────────────────────

  Widget _applyShape(Widget child, double? w, double? h) {
    switch (shape) {
      case ImageShape.circle:
        return ClipOval(child: child);

      case ImageShape.roundedRectangle:
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        );

      case ImageShape.rectangle:
        return ClipRect(child: child);
    }
  }

  // ── Apply optional border ─────────────────────────────────────────────────

  Widget _applyBorder(Widget child, double? w, double? h) {
    if (borderColor == null) return child;

    switch (shape) {
      case ImageShape.circle:
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor!, width: borderWidth),
          ),
          child: child,
        );

      case ImageShape.roundedRectangle:
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor!, width: borderWidth),
          ),
          child: child,
        );

      case ImageShape.rectangle:
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor!, width: borderWidth),
          ),
          child: child,
        );
    }
  }

  // ── Full-screen viewer ────────────────────────────────────────────────────

  void _openFullScreen(BuildContext context, Widget rawImage) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) =>
            _FullScreenImageViewer(imageWidget: rawImage, heroTag: heroTag),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = _resolveWidth(context);
    final h = _resolveHeight(context);

    // Unshaped raw image for the full-screen viewer
    final rawImage = _buildRawImage(context, null, null);

    // Shape → border → optional hero
    final shaped = _applyShape(_buildRawImage(context, w, h), w, h);
    final bordered = _applyBorder(shaped, w, h);
    final displayWidget =
        heroTag != null ? Hero(tag: heroTag!, child: bordered) : bordered;

    if (!enableImageView) return displayWidget;

    return GestureDetector(
      onTap: () => _openFullScreen(context, rawImage),
      child: displayWidget,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  USAGE EXAMPLES
// ─────────────────────────────────────────────────────────────────────────────

/*

// ── 1. Network · rounded rectangle · tap to view ──────────────────────────────
ResponsiveImage.network(
  url: 'https://example.com/cover.jpg',
  shape: ImageShape.roundedRectangle,
  borderRadius: 16,
  widthPercent: 0.9,
  heightPercent: 0.25,
  enableImageView: true,
  heroTag: 'cover-hero',
),

// ── 2. Network · circle avatar with border ────────────────────────────────────
ResponsiveImage.network(
  url: user.profileImage,
  shape: ImageShape.circle,
  width: 56,
  height: 56,
  borderColor: Colors.blueAccent,
  borderWidth: 2.5,
  enableImageView: true,
  heroTag: 'avatar-${user.id}',
),

// ── 3. Network · custom mem-cache size (400px wide thumbnails) ────────────────
ResponsiveImage.network(
  url: 'https://example.com/product.jpg',
  shape: ImageShape.roundedRectangle,
  borderRadius: 12,
  widthPercent: 0.45,
  heightPercent: 0.2,
  memCacheWidth: 400,   // override the default 200
),

// ── 4. Asset · rounded rectangle · pre-warm in initState ──────────────────────
//   In your widget's initState:
//   await AssetImageCacheHelper.prewarm(context, 'assets/images/hero.png');
//
ResponsiveImage.asset(
  assetPath: 'assets/images/hero.png',
  shape: ImageShape.roundedRectangle,
  borderRadius: 8,
  widthPercent: 0.9,
  heightPercent: 0.3,
),

// ── 5. Asset · circle with border ─────────────────────────────────────────────
ResponsiveImage.asset(
  assetPath: 'assets/icons/profile.png',
  shape: ImageShape.circle,
  width: 80,
  height: 80,
  borderColor: Colors.orange,
  borderWidth: 3,
),

// ── 6. File · plain rectangle · tap to view ───────────────────────────────────
ResponsiveImage.file(
  filePath: pickedFile.path,
  shape: ImageShape.rectangle,
  width: double.infinity,
  heightPercent: 0.35,
  enableImageView: true,
),

// ── 7. Generic constructor with all options ────────────────────────────────────
ResponsiveImage(
  imageSource: 'https://example.com/product.jpg',
  sourceType: ImageSourceType.network,
  shape: ImageShape.roundedRectangle,
  borderRadius: 20,
  borderColor: Colors.white,
  borderWidth: 2,
  widthPercent: 0.5,
  heightPercent: 0.2,
  fit: BoxFit.cover,
  memCacheWidth: 300,
  enableImageView: true,
  placeholderWidget: MyCustomShimmer(),
  errorWidget: MyCustomErrorWidget(),
  heroTag: 'product-card',
),

*/