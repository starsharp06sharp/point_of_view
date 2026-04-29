import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../l10n/generated/app_localizations.dart';
import '../l10n/labels.dart';
import '../models/sort_option.dart';
import '../services/file_service.dart';
import '../services/hidden_files_service.dart';
import '../services/prefs_service.dart';
import 'image_viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String folderPath;

  const GalleryScreen({super.key, required this.folderPath});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const int _minCols = 2;
  static const int _maxCols = 12;
  static const int _groupThreshold = 6;

  SortOption _sort = SortOption.defaultOption;
  List<ImageEntry> _entries = const [];
  bool _loading = true;

  /// Null until the first LayoutBuilder pass picks a sensible default based on
  /// available width.
  int? _columnCount;
  int _baseColumnsAtScaleStart = 0;

  List<_GalleryGroup>? _groupsCache;

  @override
  void initState() {
    super.initState();
    HiddenFilesService.show.addListener(_onHiddenChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    HiddenFilesService.show.removeListener(_onHiddenChanged);
    super.dispose();
  }

  void _onHiddenChanged() {
    if (!mounted) return;
    _reload();
  }

  Future<void> _bootstrap() async {
    _sort = await PrefsService.readSort();
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final list = FileService.listImageEntries(
      widget.folderPath,
      _sort,
      includeHidden: HiddenFilesService.show.value,
    );
    if (!mounted) return;
    setState(() {
      _entries = list;
      _groupsCache = null;
      _loading = false;
    });
  }

  Future<void> _changeSort(SortOption option) async {
    if (option == _sort) return;
    setState(() {
      _sort = option;
      _groupsCache = null;
    });
    await PrefsService.writeSort(option);
    await _reload();
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          images: _entries.map((e) => e.file).toList(growable: false),
          initialIndex: index,
        ),
      ),
    );
  }

  String _groupKey(ImageEntry e) {
    switch (_sort.field) {
      case SortField.name:
        final name = p.basename(e.file.path).trimLeft();
        if (name.isEmpty) return '#';
        final ch = name.characters.first;
        final upper = ch.toUpperCase();
        // Bucket non-letters under '#'.
        if (upper.length == 1) {
          final code = upper.codeUnitAt(0);
          final isAsciiLetter =
              (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);
          if (!isAsciiLetter) {
            // Allow non-ASCII letters (e.g. CJK) to be their own bucket; only
            // reject ASCII non-letters like digits and punctuation.
            if (code < 0x80) return '#';
          }
        }
        return upper;
      case SortField.modified:
        final dt = e.modified;
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
    }
  }

  List<_GalleryGroup> _buildGroups() {
    final cached = _groupsCache;
    if (cached != null) return cached;
    final List<_GalleryGroup> groups = [];
    String? currentKey;
    int currentStart = 0;
    final List<ImageEntry> currentItems = [];
    for (var i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      final key = _groupKey(entry);
      if (currentKey == null) {
        currentKey = key;
        currentStart = i;
      } else if (key != currentKey) {
        groups.add(_GalleryGroup(
          key: currentKey,
          startIndex: currentStart,
          items: List.unmodifiable(currentItems),
        ));
        currentItems.clear();
        currentKey = key;
        currentStart = i;
      }
      currentItems.add(entry);
    }
    if (currentKey != null) {
      groups.add(_GalleryGroup(
        key: currentKey,
        startIndex: currentStart,
        items: List.unmodifiable(currentItems),
      ));
    }
    _groupsCache = groups;
    return groups;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseColumnsAtScaleStart = _columnCount ?? _minCols;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;
    final scale = details.scale;
    if (scale <= 0) return;
    final next =
        (_baseColumnsAtScaleStart / scale).round().clamp(_minCols, _maxCols);
    if (next != _columnCount) {
      setState(() => _columnCount = next);
    }
  }

  Widget _buildTile(ImageEntry entry, int globalIndex) {
    return GestureDetector(
      onTap: () => _openViewer(globalIndex),
      child: Hero(
        tag: entry.file.path,
        child: Image.file(
          entry.file,
          fit: BoxFit.cover,
          cacheWidth: 320,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => Container(
            color: Colors.black26,
            child: const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatGrid(int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: _entries.length,
      itemBuilder: (context, index) => _buildTile(_entries[index], index),
    );
  }

  Widget _buildGroupedView(int columns) {
    final groups = _buildGroups();
    final slivers = <Widget>[];
    for (final group in groups) {
      slivers.add(
        SliverToBoxAdapter(
          child: _GroupHeader(label: group.key),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, localIndex) {
                final entry = group.items[localIndex];
                return _buildTile(entry, group.startIndex + localIndex);
              },
              childCount: group.items.length,
            ),
          ),
        ),
      );
    }
    return CustomScrollView(slivers: slivers);
  }

  int _defaultColumnsForWidth(double maxWidth) {
    return (maxWidth / 130).floor().clamp(_minCols, _groupThreshold);
  }

  @override
  Widget build(BuildContext context) {
    final folderName = p.basename(widget.folderPath);
    final l = AppLocalizations.of(context);
    final sortLabel = _sort.shortLabel(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(folderName.isEmpty ? widget.folderPath : folderName,
                overflow: TextOverflow.ellipsis),
            Text(
              _columnCount == null
                  ? l.gallerySubtitleNoZoom(_entries.length, sortLabel)
                  : l.gallerySubtitleZoom(
                      _entries.length, sortLabel, _columnCount!),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: l.sortTooltip,
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: _changeSort,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: const SortOption(SortField.name, SortOrder.asc),
                child: Text(l.sortMenuNameAsc),
              ),
              PopupMenuItem(
                value: const SortOption(SortField.name, SortOrder.desc),
                child: Text(l.sortMenuNameDesc),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: const SortOption(SortField.modified, SortOrder.desc),
                child: Text(l.sortMenuModifiedDesc),
              ),
              PopupMenuItem(
                value: const SortOption(SortField.modified, SortOrder.asc),
                child: Text(l.sortMenuModifiedAsc),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_not_supported_outlined,
                            size: 48),
                        const SizedBox(height: 12),
                        Text(
                          l.noImages,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        _columnCount ?? _defaultColumnsForWidth(constraints.maxWidth);
                    if (_columnCount == null) {
                      // Initialize lazily so first frame matches the previous
                      // behaviour for the current viewport width.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _columnCount == null) {
                          setState(() => _columnCount = columns);
                        }
                      });
                    }
                    final body = columns >= _groupThreshold
                        ? _buildGroupedView(columns)
                        : _buildFlatGrid(columns);
                    return GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      child: body,
                    );
                  },
                ),
    );
  }
}

class _GalleryGroup {
  final String key;
  final int startIndex;
  final List<ImageEntry> items;

  const _GalleryGroup({
    required this.key,
    required this.startIndex,
    required this.items,
  });
}

class _GroupHeader extends StatelessWidget {
  final String label;

  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
