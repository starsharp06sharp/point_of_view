import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Aggregated metadata for an image file shown in the in-app viewer overlay.
///
/// Fields are independently optional so the UI can render whatever it manages
/// to extract: a non-EXIF PNG still has a path/size/resolution, a stat-failed
/// file still has a path. [error] is set when reading the file failed entirely
/// (permission denied, file disappeared, etc.).
///
/// Named with the `Metadata` suffix to avoid collision with Flutter's own
/// `ImageInfo` class from `dart:ui` / `package:flutter/painting.dart`.
class ImageMetadata {
  final String path;
  final String type;
  final int? width;
  final int? height;
  final int? sizeBytes;
  final DateTime? created;
  final DateTime? modified;
  final double? latitude;
  final double? longitude;
  final String? camera;
  final String? cameraParams;
  final Object? error;

  const ImageMetadata({
    required this.path,
    required this.type,
    this.width,
    this.height,
    this.sizeBytes,
    this.created,
    this.modified,
    this.latitude,
    this.longitude,
    this.camera,
    this.cameraParams,
    this.error,
  });
}

class ImageInfoService {
  /// Load metadata for [file]. Reads bytes once, then decodes for resolution
  /// and parses EXIF in parallel. Never throws — failures show up via partial
  /// fields or [ImageMetadata.error].
  static Future<ImageMetadata> load(File file) async {
    final path = file.path;
    final type = _extensionType(path);

    int? sizeBytes;
    DateTime? modified;
    DateTime? changed;
    try {
      final stat = await file.stat();
      sizeBytes = stat.size;
      modified = stat.modified;
      changed = stat.changed;
    } on FileSystemException catch (e) {
      return ImageMetadata(path: path, type: type, error: e);
    }

    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } on FileSystemException catch (e) {
      return ImageMetadata(
        path: path,
        type: type,
        sizeBytes: sizeBytes,
        modified: modified,
        created: changed,
        error: e,
      );
    }

    final results = await Future.wait<Object?>([
      _decodeSize(bytes),
      _readExif(bytes),
    ]);
    final size = results[0] as _ImageSize?;
    final exif = results[1] as _ExifSummary?;

    return ImageMetadata(
      path: path,
      type: type,
      width: size?.width,
      height: size?.height,
      sizeBytes: sizeBytes,
      created: exif?.dateTimeOriginal ?? changed,
      modified: modified,
      latitude: exif?.latitude,
      longitude: exif?.longitude,
      camera: exif?.camera,
      cameraParams: exif?.cameraParams,
    );
  }

  static String _extensionType(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot + 1).toUpperCase();
  }

  static Future<_ImageSize?> _decodeSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final size = _ImageSize(image.width, image.height);
      image.dispose();
      codec.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  static Future<_ExifSummary?> _readExif(Uint8List bytes) async {
    try {
      final tags = await readExifFromBytes(bytes);
      if (tags.isEmpty) return null;
      tags.remove('JPEGThumbnail');
      tags.remove('TIFFThumbnail');
      return _ExifSummary.fromTags(tags);
    } catch (_) {
      return null;
    }
  }

  /// Reverse-geocode a coordinate into a localized "{admin},{city},{district},
  /// {country}" string by calling BigDataCloud's free public
  /// `reverse-geocode-client` endpoint over HTTPS. No API key, no signup.
  ///
  /// We deliberately bypass the platform geocoder (CoreLocation /
  /// `android.location.Geocoder`) because its Android implementation is
  /// frequently unavailable on devices without Google Play Services (most
  /// notably in mainland China). Going straight to a public HTTPS service
  /// gives consistent behavior across all devices at the cost of a single
  /// network round-trip per coordinate.
  ///
  /// [localeName] is e.g. "zh_HK" or "en"; converted to a BCP-47 tag for
  /// `localityLanguage` so the names come back in the user's language.
  /// Returns `null` if the lookup fails for any reason — never throws.
  static Future<String?> reverseGeocode(
    double latitude,
    double longitude, {
    String? localeName,
  }) async {
    final lang = _bcp47From(localeName);
    final uri = Uri.https(
      'api.bigdatacloud.net',
      '/data/reverse-geocode-client',
      {
        'latitude': latitude.toStringAsFixed(6),
        'longitude': longitude.toStringAsFixed(6),
        'localityLanguage': lang,
      },
    );
    try {
      final resp = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          // BigDataCloud rejects calls that look like server-side traffic
          // (datacenter IPs, missing UA). A descriptive UA helps it route
          // requests through the free client tier.
          'User-Agent': 'PointOfView/1.0 (Flutter; Android/iOS image viewer)',
        },
      ).timeout(const Duration(seconds: 6));
      if (resp.statusCode != 200) return null;
      final json = jsonDecode(resp.body);
      if (json is! Map<String, dynamic>) return null;
      // The endpoint signals refusal/error via a `status` field set to a
      // non-200 number while still responding HTTP 200 with JSON.
      final apiStatus = json['status'];
      if (apiStatus is num && apiStatus.toInt() >= 400) return null;
      return _assemblePlaceNameFromBigDataCloud(json);
    } on TimeoutException {
      return null;
    } on http.ClientException {
      return null;
    } on SocketException {
      return null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Convert a Dart `Locale.toString()` value (uses underscore, e.g. "zh_HK")
  /// to the BCP-47 form BigDataCloud expects ("zh-HK").
  ///
  /// Chinese gets special treatment. BigDataCloud's reverse-geocoder is
  /// backed by OpenStreetMap, where the same coordinate may have three
  /// independent Chinese name tags — `name:zh`, `name:zh-Hans` (Simplified)
  /// and `name:zh-Hant` (Traditional) — and they're not kept in sync. If
  /// we send the bare `zh` tag the API picks `name:zh`, whose script then
  /// depends on which OSM contributor entered the data: e.g. Shenzhen ends
  /// up Simplified ("广东省") while Yantai ends up Traditional
  /// ("山東省"). Forcing a script subtag (`zh-Hans` / `zh-Hant`) makes the
  /// result deterministic and matches the user's app locale:
  ///   * `zh`            → `zh-Hans`        (the app's default Chinese is Simplified)
  ///   * `zh_HK/TW/MO`   → `zh-Hant-{REGION}`
  ///   * `zh_CN/SG`      → `zh-Hans-{REGION}`
  ///
  /// Falls back to "en" when no usable locale was supplied.
  static String _bcp47From(String? localeName) {
    if (localeName == null || localeName.isEmpty) return 'en';
    final parts = localeName.split('_');
    if (parts.first == 'zh') {
      final region = parts.length > 1 ? parts[1] : null;
      const traditionalRegions = {'HK', 'TW', 'MO'};
      final script =
          traditionalRegions.contains(region) ? 'Hant' : 'Hans';
      return region == null ? 'zh-$script' : 'zh-$script-$region';
    }
    return localeName.replaceAll('_', '-');
  }

  /// Parse BigDataCloud's reverse-geocode JSON into a
  /// `"{admin},{city},{district},{country}"` string.
  ///
  /// We use `localityInfo.administrative` (an array of records with `name`,
  /// `order` and `adminLevel`) and rely on OpenStreetMap-style
  /// [adminLevel](https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative#admin_level)
  /// values rather than `order`, which is friendlier across countries:
  ///
  ///   adminLevel 2  → country         (e.g. "中华人民共和国")
  ///   adminLevel 4  → state/province  (e.g. "广东省")
  ///   adminLevel 5  → prefecture city (e.g. "深圳市")
  ///   adminLevel 6+ → district / town / suburb / street
  ///
  /// We:
  ///   * skip everything *above* the country (continent/world have lower
  ///     levels — without this fix the country itself was leaking into the
  ///     output as the very first part);
  ///   * skip the country entry from this list (it's added at the end);
  ///   * keep up to the first three sub-country levels (admin/city/district);
  ///   * append the country name at the end, preferring the top-level
  ///     `countryName` field (BigDataCloud already localizes it, and for
  ///     zh-CN that gives "中国" rather than the formal "中华人民共和国" that
  ///     lives inside the administrative list); fall back to the
  ///     administrative entry only when `countryName` is missing.
  static String? _assemblePlaceNameFromBigDataCloud(
    Map<String, dynamic> json,
  ) {
    final info = json['localityInfo'];
    final admins = info is Map<String, dynamic> ? info['administrative'] : null;

    final subParts = <String>[];
    void addUnique(String s) {
      final t = s.trim();
      if (t.isEmpty) return;
      if (subParts.contains(t)) return;
      subParts.add(t);
    }

    String? countryFromAdmin;
    if (admins is List) {
      final entries = admins.whereType<Map<String, dynamic>>().toList()
        ..sort((a, b) {
          final ao = (a['order'] as num?)?.toInt() ?? 0;
          final bo = (b['order'] as num?)?.toInt() ?? 0;
          return ao.compareTo(bo);
        });
      for (final entry in entries) {
        final adminLevel = (entry['adminLevel'] as num?)?.toInt() ?? 0;
        final name = (entry['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        if (adminLevel < 2) continue;
        if (adminLevel == 2) {
          countryFromAdmin ??= name;
          continue;
        }
        addUnique(name);
        if (subParts.length >= 3) break;
      }
    }

    // Fallback when `localityInfo.administrative` was missing or sparse —
    // BigDataCloud always returns these flat fields.
    if (subParts.isEmpty) {
      final principal = (json['principalSubdivision'] as String?)?.trim();
      if (principal != null && principal.isNotEmpty) addUnique(principal);
      final city = (json['city'] as String?)?.trim();
      if (city != null && city.isNotEmpty) addUnique(city);
      final locality = (json['locality'] as String?)?.trim();
      if (locality != null && locality.isNotEmpty) addUnique(locality);
    }

    final countryName = (json['countryName'] as String?)?.trim();
    final country = (countryName != null && countryName.isNotEmpty)
        ? countryName
        : countryFromAdmin;
    if (country != null && country.isNotEmpty && !subParts.contains(country)) {
      subParts.add(country);
    }

    if (subParts.isEmpty) return null;
    return subParts.join(',');
  }
}

class _ImageSize {
  final int width;
  final int height;
  const _ImageSize(this.width, this.height);
}

class _ExifSummary {
  final DateTime? dateTimeOriginal;
  final double? latitude;
  final double? longitude;
  final String? camera;
  final String? cameraParams;

  const _ExifSummary({
    this.dateTimeOriginal,
    this.latitude,
    this.longitude,
    this.camera,
    this.cameraParams,
  });

  factory _ExifSummary.fromTags(Map<String, IfdTag> tags) {
    final make = _printable(tags['Image Make']);
    final model = _printable(tags['Image Model']);
    String? camera;
    if (make != null && model != null) {
      // Some cameras already include the brand inside the model field
      // ("NIKON CORPORATION" + "NIKON D850") — collapse the duplicate.
      camera = model.toLowerCase().startsWith(make.toLowerCase())
          ? model
          : '$make $model';
    } else {
      camera = make ?? model;
    }

    final params = <String>[];
    final focal = _formatFocalLength(tags['EXIF FocalLength']);
    if (focal != null) params.add(focal);
    final fnumber = _formatFNumber(tags['EXIF FNumber']);
    if (fnumber != null) params.add(fnumber);
    final exposure = _formatExposureTime(tags['EXIF ExposureTime']);
    if (exposure != null) params.add(exposure);
    final iso = _printable(tags['EXIF ISOSpeedRatings']);
    if (iso != null && iso.isNotEmpty) params.add('ISO $iso');

    return _ExifSummary(
      dateTimeOriginal: _parseExifDateTime(tags['EXIF DateTimeOriginal']) ??
          _parseExifDateTime(tags['EXIF DateTimeDigitized']) ??
          _parseExifDateTime(tags['Image DateTime']),
      latitude: _gpsCoord(
        tags['GPS GPSLatitude'],
        tags['GPS GPSLatitudeRef'],
        positiveRef: 'N',
      ),
      longitude: _gpsCoord(
        tags['GPS GPSLongitude'],
        tags['GPS GPSLongitudeRef'],
        positiveRef: 'E',
      ),
      camera: camera,
      cameraParams: params.isEmpty ? null : params.join(' · '),
    );
  }

  static String? _printable(IfdTag? tag) {
    final s = tag?.printable.trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  /// Convert an EXIF rational/int into a double. Returns null on failure.
  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    // The exif package's Ratio type exposes `numerator` and `denominator`
    // dynamically; access via dynamic dispatch to avoid a hard import path
    // dependency on its private symbols.
    try {
      final dyn = value as dynamic;
      final num n = dyn.numerator as num;
      final num d = dyn.denominator as num;
      if (d == 0) return null;
      return n / d;
    } catch (_) {
      return null;
    }
  }

  static String? _formatFocalLength(IfdTag? tag) {
    final list = tag?.values.toList();
    if (list == null || list.isEmpty) return null;
    final v = _toDouble(list.first);
    if (v == null) return null;
    return '${_trimZero(v.toStringAsFixed(1))} mm';
  }

  static String? _formatFNumber(IfdTag? tag) {
    final list = tag?.values.toList();
    if (list == null || list.isEmpty) return null;
    final v = _toDouble(list.first);
    if (v == null) return null;
    return 'f/${_trimZero(v.toStringAsFixed(1))}';
  }

  static String? _formatExposureTime(IfdTag? tag) {
    final list = tag?.values.toList();
    if (list == null || list.isEmpty) return null;
    final raw = list.first;
    try {
      final dyn = raw as dynamic;
      final int n = (dyn.numerator as num).toInt();
      final int d = (dyn.denominator as num).toInt();
      if (d == 0) return null;
      if (n == 0) return '0 s';
      if (n == 1) return '1/$d s';
      if (d == 1) return '$n s';
      // Sub-second exposures often come through as e.g. 10/2500.
      if (n < d) return '1/${(d / n).round()} s';
      return '${(n / d).toStringAsFixed(1)} s';
    } catch (_) {
      final v = _toDouble(raw);
      if (v == null) return null;
      if (v >= 1) return '${_trimZero(v.toStringAsFixed(1))} s';
      return '1/${(1 / v).round()} s';
    }
  }

  static String _trimZero(String s) {
    if (!s.contains('.')) return s;
    var t = s;
    while (t.endsWith('0')) {
      t = t.substring(0, t.length - 1);
    }
    if (t.endsWith('.')) t = t.substring(0, t.length - 1);
    return t;
  }

  /// Parse EXIF "YYYY:MM:DD HH:MM:SS" timestamps. Treats the value as local
  /// time since EXIF doesn't carry a timezone in the basic DateTime fields.
  static DateTime? _parseExifDateTime(IfdTag? tag) {
    final s = _printable(tag);
    if (s == null) return null;
    final parts = s.split(' ');
    if (parts.length != 2) return null;
    final date = parts[0].split(':');
    final time = parts[1].split(':');
    if (date.length != 3 || time.length != 3) return null;
    final y = int.tryParse(date[0]);
    final mo = int.tryParse(date[1]);
    final d = int.tryParse(date[2]);
    final h = int.tryParse(time[0]);
    final mi = int.tryParse(time[1]);
    final se = int.tryParse(time[2]);
    if (y == null ||
        mo == null ||
        d == null ||
        h == null ||
        mi == null ||
        se == null) {
      return null;
    }
    return DateTime(y, mo, d, h, mi, se);
  }

  /// Convert (deg, min, sec) rationals + N/S/E/W reference into a signed
  /// decimal coordinate. Returns null when the tag is missing or malformed.
  static double? _gpsCoord(
    IfdTag? coord,
    IfdTag? ref, {
    required String positiveRef,
  }) {
    final parts = coord?.values.toList();
    if (parts == null || parts.length < 3) return null;
    final deg = _toDouble(parts[0]);
    final min = _toDouble(parts[1]);
    final sec = _toDouble(parts[2]);
    if (deg == null || min == null || sec == null) return null;
    var value = deg + min / 60.0 + sec / 3600.0;
    final r = _printable(ref)?.toUpperCase();
    if (r != null && r.isNotEmpty && r != positiveRef) value = -value;
    return value;
  }
}
