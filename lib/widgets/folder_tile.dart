import 'dart:io';

import 'package:flutter/material.dart';

class FolderTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final bool hidden;
  final IconData icon;
  final Widget? leading;
  final VoidCallback? onTap;

  const FolderTile({
    super.key,
    required this.name,
    this.subtitle,
    this.hidden = false,
    this.icon = Icons.folder,
    this.leading,
    this.onTap,
  });

  factory FolderTile.parent({VoidCallback? onTap}) {
    return FolderTile(
      name: '..',
      subtitle: '返回上一级',
      icon: Icons.arrow_upward,
      onTap: onTap,
    );
  }

  /// Image entry: same row layout, but the leading icon is replaced by a
  /// thumbnail of [file].
  factory FolderTile.image({
    required File file,
    required String name,
    String? subtitle,
    bool hidden = false,
    VoidCallback? onTap,
  }) {
    return FolderTile(
      name: name,
      subtitle: subtitle,
      hidden: hidden,
      onTap: onTap,
      leading: _Thumbnail(file: file, hidden: hidden),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hidden
        ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
        : theme.colorScheme.onSurface;
    final iconColor = hidden
        ? theme.colorScheme.primary.withValues(alpha: 0.55)
        : theme.colorScheme.primary;

    return ListTile(
      leading: leading ??
          Icon(
            hidden ? Icons.folder_special : icon,
            color: iconColor,
          ),
      title: Text(
        name,
        style: TextStyle(
          color: color,
          fontStyle: hidden ? FontStyle.italic : FontStyle.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final File file;
  final bool hidden;

  const _Thumbnail({required this.file, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.file(
        file,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        cacheWidth: 120,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Container(
          width: 40,
          height: 40,
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image,
              size: 20, color: Colors.white54),
        ),
      ),
    );
    if (!hidden) return image;
    return Opacity(opacity: 0.55, child: image);
  }
}
