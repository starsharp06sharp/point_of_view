import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/sort_option.dart';

class FileService {
  static const Set<String> _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.heic',
    '.heif',
  };

  static const String primaryStorageRoot = '/storage/emulated/0';
  static const String storageVolumesRoot = '/storage';

  /// List immediate sub-directories of [path], sorted by [option]. When
  /// [includeHidden] is false, dot-prefixed directories are filtered out.
  /// Entries that fail to stat (permission denied) are skipped.
  static List<Directory> listSubdirectories(
    String path, {
    SortOption option = SortOption.defaultOption,
    bool includeHidden = true,
  }) {
    final dir = Directory(path);
    if (!dir.existsSync()) return const [];
    final List<_DirEntry> entries = [];
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! Directory) continue;
        if (!includeHidden && isHidden(entity.path)) continue;
        DateTime modified;
        try {
          modified = entity.statSync().modified;
        } on FileSystemException {
          modified = DateTime.fromMillisecondsSinceEpoch(0);
        }
        entries.add(_DirEntry(entity, modified));
      }
    } on FileSystemException {
      return const [];
    }

    int cmp(_DirEntry a, _DirEntry b) {
      switch (option.field) {
        case SortField.name:
          return p
              .basename(a.dir.path)
              .toLowerCase()
              .compareTo(p.basename(b.dir.path).toLowerCase());
        case SortField.modified:
          return a.modified.compareTo(b.modified);
      }
    }

    entries.sort(cmp);
    if (option.order == SortOrder.desc) {
      return entries.reversed.map((e) => e.dir).toList(growable: false);
    }
    return entries.map((e) => e.dir).toList(growable: false);
  }

  /// Whether the path represents the root that the user is allowed to back
  /// out of.
  static bool isAtFilesystemRoot(String path) {
    return path == '/' || path == storageVolumesRoot;
  }

  /// List image entries directly inside [path] (no recursion), sorted by
  /// [option]. Each entry carries the cached `modified` timestamp so callers
  /// don't need to re-`stat` for grouping/display. When [includeHidden] is
  /// false, dot-prefixed files are filtered out.
  static List<ImageEntry> listImageEntries(
    String path,
    SortOption option, {
    bool includeHidden = true,
  }) {
    final dir = Directory(path);
    if (!dir.existsSync()) return const [];

    final List<ImageEntry> entries = [];
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        if (!includeHidden && isHidden(entity.path)) continue;
        final ext = p.extension(entity.path).toLowerCase();
        if (!_imageExtensions.contains(ext)) continue;
        DateTime modified;
        try {
          modified = entity.statSync().modified;
        } on FileSystemException {
          modified = DateTime.fromMillisecondsSinceEpoch(0);
        }
        entries.add(ImageEntry(entity, modified));
      }
    } on FileSystemException {
      return const [];
    }

    int cmp(ImageEntry a, ImageEntry b) {
      switch (option.field) {
        case SortField.name:
          return p
              .basename(a.file.path)
              .toLowerCase()
              .compareTo(p.basename(b.file.path).toLowerCase());
        case SortField.modified:
          return a.modified.compareTo(b.modified);
      }
    }

    entries.sort(cmp);
    if (option.order == SortOrder.desc) {
      return entries.reversed.toList(growable: false);
    }
    return List.unmodifiable(entries);
  }

  /// List image files directly inside [path] (no recursion), sorted by [option].
  static List<File> listImages(
    String path,
    SortOption option, {
    bool includeHidden = true,
  }) {
    return listImageEntries(path, option, includeHidden: includeHidden)
        .map((e) => e.file)
        .toList(growable: false);
  }

  static bool isHidden(String path) => p.basename(path).startsWith('.');
}

class ImageEntry {
  final File file;
  final DateTime modified;
  const ImageEntry(this.file, this.modified);
}

class _DirEntry {
  final Directory dir;
  final DateTime modified;
  _DirEntry(this.dir, this.modified);
}
