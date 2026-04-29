import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../models/sort_option.dart';
import '../services/file_service.dart';
import '../services/prefs_service.dart';
import '../widgets/folder_tile.dart';
import 'gallery_screen.dart';
import 'image_viewer_screen.dart';
import 'settings_screen.dart';

class FolderPickerScreen extends StatefulWidget {
  const FolderPickerScreen({super.key});

  @override
  State<FolderPickerScreen> createState() => _FolderPickerScreenState();
}

class _FolderPickerScreenState extends State<FolderPickerScreen> {
  String _currentPath = FileService.primaryStorageRoot;
  List<Directory> _subdirs = const [];
  List<File> _images = const [];
  SortOption _sort = SortOption.defaultOption;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _sort = await PrefsService.readSort();
    final last = await PrefsService.readLastBrowsedDir();
    if (last != null && Directory(last).existsSync()) {
      _currentPath = last;
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final dirs = FileService.listSubdirectories(_currentPath, option: _sort);
    final imgs = FileService.listImages(_currentPath, _sort);
    if (!mounted) return;
    setState(() {
      _subdirs = dirs;
      _images = imgs;
      _loading = false;
    });
    await PrefsService.writeLastBrowsedDir(_currentPath);
  }

  void _enter(String path) {
    setState(() => _currentPath = path);
    _load();
  }

  void _goUp() {
    if (FileService.isAtFilesystemRoot(_currentPath)) return;
    final parent = p.dirname(_currentPath);
    if (parent == _currentPath) return;
    _enter(parent);
  }

  Future<void> _changeSort(SortOption option) async {
    if (option == _sort) return;
    setState(() => _sort = option);
    await PrefsService.writeSort(option);
    await _load();
  }

  Future<void> _selectThisFolder() async {
    await PrefsService.writeLastFolder(_currentPath);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GalleryScreen(folderPath: _currentPath),
      ),
    );
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          images: _images,
          initialIndex: index,
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final parts = _currentPath.split('/').where((s) => s.isNotEmpty).toList();
    final crumbs = <Widget>[
      _BreadcrumbChip(
        label: '/',
        onTap: () => _enter('/'),
      ),
    ];
    var built = '';
    for (final part in parts) {
      built = '$built/$part';
      final path = built;
      crumbs.add(const Icon(Icons.chevron_right, size: 16));
      crumbs.add(_BreadcrumbChip(
        label: part,
        onTap: () => _enter(path),
      ));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(children: crumbs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atRoot = FileService.isAtFilesystemRoot(_currentPath);
    final canSelect = !atRoot && _images.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择文件夹', style: TextStyle(fontSize: 16)),
            Text(
              '${_subdirs.length} 个文件夹 · ${_images.length} 张图片 · ${_sort.label}',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: '排序方式',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: _changeSort,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: SortOption(SortField.name, SortOrder.asc),
                child: Text('名称 升序 (A→Z)'),
              ),
              PopupMenuItem(
                value: SortOption(SortField.name, SortOrder.desc),
                child: Text('名称 降序 (Z→A)'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: SortOption(SortField.modified, SortOrder.desc),
                child: Text('修改时间 降序 (新→旧)'),
              ),
              PopupMenuItem(
                value: SortOption(SortField.modified, SortOrder.asc),
                child: Text('修改时间 升序 (旧→新)'),
              ),
            ],
          ),
          IconButton(
            tooltip: '回到主存储',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => _enter(FileService.primaryStorageRoot),
          ),
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: _buildBreadcrumb(),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(atRoot),
          ),
        ],
      ),
      floatingActionButton: canSelect
          ? FloatingActionButton.extended(
              onPressed: _selectThisFolder,
              icon: const Icon(Icons.collections_outlined),
              label: const Text('沉浸预览'),
            )
          : null,
    );
  }

  Widget _buildBody(bool atRoot) {
    final showParent = !atRoot;
    final hasContent = _subdirs.isNotEmpty || _images.isNotEmpty;
    final parentCount = showParent ? 1 : 0;
    final emptyHintCount = !hasContent ? 1 : 0;
    final totalCount =
        parentCount + _subdirs.length + _images.length + emptyHintCount;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: totalCount,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (showParent && index == 0) {
          return FolderTile.parent(onTap: _goUp);
        }
        final i = index - parentCount;
        if (i < _subdirs.length) {
          final dir = _subdirs[i];
          final name = p.basename(dir.path);
          final hidden = name.startsWith('.');
          return FolderTile(
            name: name,
            subtitle: dir.path,
            hidden: hidden,
            onTap: () => _enter(dir.path),
          );
        }
        final j = i - _subdirs.length;
        if (j < _images.length) {
          final file = _images[j];
          final name = p.basename(file.path);
          final hidden = name.startsWith('.');
          return FolderTile.image(
            file: file,
            name: name,
            subtitle: file.path,
            hidden: hidden,
            onTap: () => _openViewer(j),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_off, size: 48),
              const SizedBox(height: 12),
              Text(
                atRoot
                    ? '当前位置没有可访问的内容。\n请检查"所有文件访问"权限是否已授予。'
                    : '此处空空如也',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BreadcrumbChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
