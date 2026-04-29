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

  /// List immediate sub-directories of [path], sorted by [option]. Hidden
  /// directories (starting with '.') are kept; entries that fail to stat
  /// (permission denied) are skipped.
  static List<Directory> listSubdirectories(
    String path, {
    SortOption option = SortOption.defaultOption,
  }) {
    final dir = Directory(path);
    if (!dir.existsSync()) return const [];
    final List<_DirEntry> entries = [];
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! Directory) continue;
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

  /// List image files directly inside [path] (no recursion), sorted by [option].
  static List<File> listImages(String path, SortOption option) {
    final dir = Directory(path);
    if (!dir.existsSync()) return const [];

    final List<_ImageEntry> entries = [];
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        final ext = p.extension(entity.path).toLowerCase();
        if (!_imageExtensions.contains(ext)) continue;
        DateTime modified;
        try {
          modified = entity.statSync().modified;
        } on FileSystemException {
          modified = DateTime.fromMillisecondsSinceEpoch(0);
        }
        entries.add(_ImageEntry(entity, modified));
      }
    } on FileSystemException {
      return const [];
    }

    int cmp(_ImageEntry a, _ImageEntry b) {
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
      return entries.reversed.map((e) => e.file).toList(growable: false);
    }
    return entries.map((e) => e.file).toList(growable: false);
  }

  static bool isHidden(String path) => p.basename(path).startsWith('.');
}

class _ImageEntry {
  final File file;
  final DateTime modified;
  _ImageEntry(this.file, this.modified);
}

class _DirEntry {
  final Directory dir;
  final DateTime modified;
  _DirEntry(this.dir, this.modified);
}
