import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../models/sort_option.dart';
import '../services/file_service.dart';
import '../services/prefs_service.dart';
import 'image_viewer_screen.dart';

class GalleryScreen extends StatefulWidget {
  final String folderPath;

  const GalleryScreen({super.key, required this.folderPath});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  SortOption _sort = SortOption.defaultOption;
  List<File> _images = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _sort = await PrefsService.readSort();
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final list = FileService.listImages(widget.folderPath, _sort);
    if (!mounted) return;
    setState(() {
      _images = list;
      _loading = false;
    });
  }

  Future<void> _changeSort(SortOption option) async {
    if (option == _sort) return;
    setState(() => _sort = option);
    await PrefsService.writeSort(option);
    await _reload();
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

  @override
  Widget build(BuildContext context) {
    final folderName = p.basename(widget.folderPath);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(folderName.isEmpty ? widget.folderPath : folderName,
                overflow: TextOverflow.ellipsis),
            Text(
              '${_images.length} 张图片 · ${_sort.label}',
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
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
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
                          '此文件夹中没有可识别的图片。\n（支持 jpg/jpeg/png/gif/webp/bmp/heic/heif）',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        (constraints.maxWidth / 130).floor().clamp(2, 6);
                    return GridView.builder(
                      padding: const EdgeInsets.all(2),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        final file = _images[index];
                        return GestureDetector(
                          onTap: () => _openViewer(index),
                          child: Hero(
                            tag: file.path,
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              cacheWidth: 320,
                              gaplessPlayback: true,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.black26,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.white54),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
