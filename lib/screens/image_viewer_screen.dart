import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
    setState(() => _chromeVisible = !_chromeVisible);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.images[_index];
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
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleChrome,
        child: PhotoViewGallery.builder(
          itemCount: widget.images.length,
          pageController: _pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          onPageChanged: (i) => setState(() => _index = i),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
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
    );
  }
}
