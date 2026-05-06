import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/image_info_service.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  late int _index;
  bool _chromeVisible = true;
  bool _infoVisible = false;

  /// Cache of resolved metadata by file path. Avoids re-parsing EXIF on every
  /// rebuild when the user toggles the overlay or swipes back to a page.
  final Map<String, Future<ImageMetadata>> _infoCache = {};

  /// Cache of reverse-geocoded place names keyed by "lat,lng" so swiping
  /// between images (or toggling the overlay) doesn't repeatedly hit the
  /// platform geocoder. The platform service is rate-limited.
  final Map<String, Future<String?>> _placeCache = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleChrome() {
    if (_infoVisible) {
      setState(() => _infoVisible = false);
      return;
    }
    setState(() => _chromeVisible = !_chromeVisible);
  }

  void _toggleInfo() {
    setState(() {
      _infoVisible = !_infoVisible;
      if (_infoVisible) _chromeVisible = true;
    });
  }

  Future<ImageMetadata> _metadataFor(File file) {
    return _infoCache.putIfAbsent(
      file.path,
      () => ImageInfoService.load(file),
    );
  }

  Future<String?> _placeNameFor(double lat, double lng, String localeName) {
    final key = '$lat,$lng';
    return _placeCache.putIfAbsent(
      key,
      () => ImageInfoService.reverseGeocode(
        lat,
        lng,
        localeName: localeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.images[_index];
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _chromeVisible
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.basename(current.path),
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_index + 1} / ${widget.images.length}',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l.imageInfoTooltip,
                  icon: Icon(
                    _infoVisible
                        ? Icons.info
                        : Icons.info_outline,
                  ),
                  onPressed: _toggleInfo,
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleChrome,
              child: PhotoViewGallery.builder(
                itemCount: widget.images.length,
                pageController: _pageController,
                scrollPhysics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.black),
                loadingBuilder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                builder: (ctx, i) {
                  final file = widget.images[i];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(file),
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4,
                    heroAttributes: PhotoViewHeroAttributes(tag: file.path),
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white54, size: 64),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_infoVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ImageInfoOverlay(
                file: current,
                metadataFuture: _metadataFor(current),
                placeNameResolver: (lat, lng) => _placeNameFor(
                  lat,
                  lng,
                  Localizations.localeOf(context).toString(),
                ),
                onClose: _toggleInfo,
              ),
            ),
        ],
      ),
    );
  }
}

/// Async lookup for a human-readable place name given GPS coordinates.
/// Implementations are expected to memoize per coordinate; the overlay calls
/// this every rebuild while open.
typedef _PlaceNameResolver = Future<String?> Function(double lat, double lng);

class _ImageInfoOverlay extends StatelessWidget {
  final File file;
  final Future<ImageMetadata> metadataFuture;
  final _PlaceNameResolver placeNameResolver;
  final VoidCallback onClose;

  const _ImageInfoOverlay({
    required this.file,
    required this.metadataFuture,
    required this.placeNameResolver,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: GestureDetector(
        // Swallow taps so they don't bubble up to the chrome-toggle handler
        // behind the overlay.
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.imageInfoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l.imageInfoCloseTooltip,
                      icon: const Icon(Icons.close, color: Colors.white70),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: FutureBuilder<ImageMetadata>(
                    future: metadataFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return _LoadingBody(label: l.imageInfoLoading);
                      }
                      final data = snap.data;
                      if (data == null) {
                        return _LoadingBody(label: l.imageInfoUnknown);
                      }
                      return _InfoBody(
                        meta: data,
                        placeNameResolver: placeNameResolver,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  final String label;
  const _LoadingBody({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _InfoBody extends StatelessWidget {
  final ImageMetadata meta;
  final _PlaceNameResolver placeNameResolver;
  const _InfoBody({required this.meta, required this.placeNameResolver});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMd(localeName).add_jms();
    final rows = <Widget>[
      _Row(
        label: l.imageInfoPath,
        value: meta.path,
        copyable: true,
      ),
      _Row(
        label: l.imageInfoType,
        value: meta.type.isEmpty ? l.imageInfoUnknown : meta.type,
      ),
      _Row(
        label: l.imageInfoResolution,
        value: (meta.width != null && meta.height != null)
            ? l.imageInfoResolutionValue(meta.width!, meta.height!)
            : l.imageInfoUnknown,
      ),
      _Row(
        label: l.imageInfoSize,
        value: meta.sizeBytes != null
            ? _formatBytes(meta.sizeBytes!, localeName)
            : l.imageInfoUnknown,
      ),
      _Row(
        label: l.imageInfoCreated,
        value: meta.created != null
            ? dateFmt.format(meta.created!)
            : l.imageInfoUnknown,
      ),
      _Row(
        label: l.imageInfoModified,
        value: meta.modified != null
            ? dateFmt.format(meta.modified!)
            : l.imageInfoUnknown,
      ),
    ];

    if (meta.latitude != null && meta.longitude != null) {
      rows.add(_LocationRow(
        label: l.imageInfoLocation,
        latitude: meta.latitude!,
        longitude: meta.longitude!,
        placeNameResolver: placeNameResolver,
      ));
    }
    if (meta.camera != null) {
      rows.add(_Row(label: l.imageInfoCamera, value: meta.camera!));
    }
    if (meta.cameraParams != null) {
      rows.add(_Row(
        label: l.imageInfoCameraParams,
        value: meta.cameraParams!,
      ));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  static String _formatBytes(int bytes, String localeName) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes < 1024) return '$bytes ${units[0]}';
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final fmt = NumberFormat.decimalPattern(localeName)
      ..maximumFractionDigits = value < 10 ? 2 : 1
      ..minimumFractionDigits = 0;
    return '${fmt.format(value)} ${units[unit]}';
  }
}

/// Renders the GPS location row with the format
/// `"{placeName}({lat}°N, {lng}°E)"` once reverse geocoding resolves, falling
/// back to the bare coordinate pair while loading or on failure. Long-press
/// copies the full rendered value (matching [_Row.copyable]).
class _LocationRow extends StatelessWidget {
  final String label;
  final double latitude;
  final double longitude;
  final _PlaceNameResolver placeNameResolver;

  const _LocationRow({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.placeNameResolver,
  });

  static String _formatCoords(double lat, double lng) {
    final latStr = '${lat.abs().toStringAsFixed(6)}°${lat >= 0 ? 'N' : 'S'}';
    final lngStr = '${lng.abs().toStringAsFixed(6)}°${lng >= 0 ? 'E' : 'W'}';
    return '$latStr, $lngStr';
  }

  @override
  Widget build(BuildContext context) {
    final coords = _formatCoords(latitude, longitude);
    return FutureBuilder<String?>(
      future: placeNameResolver(latitude, longitude),
      builder: (ctx, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final placeName = snap.data;
        final value = (placeName != null && placeName.isNotEmpty)
            ? '$placeName($coords)'
            : coords;
        return _Row(
          label: label,
          value: value,
          copyable: true,
          trailing: loading
              ? const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white54,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final Widget? trailing;

  const _Row({
    required this.label,
    required this.value,
    this.copyable = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (!copyable) return body;
    return InkWell(
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: body,
    );
  }
}
