import 'package:flutter/material.dart';

import '../services/secret_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _current = '';
  String _draft = '';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SecretService.read();
    if (!mounted) return;
    setState(() {
      _current = s;
      _draft = s;
      _loading = false;
    });
  }

  void _onKey(String key) {
    setState(() {
      _error = null;
      if (key == '⌫') {
        if (_draft.isNotEmpty) {
          _draft = _draft.substring(0, _draft.length - 1);
        }
        return;
      }
      if (_draft.length >= SecretService.maxLength) return;
      _draft = _draft + key;
    });
  }

  void _clearDraft() {
    setState(() {
      _draft = '';
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_draft.length < SecretService.minLength ||
        _draft.length > SecretService.maxLength) {
      setState(() => _error =
          '长度需在 ${SecretService.minLength}-${SecretService.maxLength} 位之间');
      return;
    }
    if (!SecretService.isValid(_draft)) {
      setState(() => _error = '只能包含 0-9 / + - × ÷ % = ± . AC');
      return;
    }
    await SecretService.write(_draft);
    if (!mounted) return;
    setState(() {
      _current = _draft;
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('解锁序列已保存')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const _SectionHeader(label: '主题'),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeService.mode,
                  builder: (_, mode, _) {
                    return RadioGroup<ThemeMode>(
                      groupValue: mode,
                      onChanged: (v) {
                        if (v != null) ThemeService.setMode(v);
                      },
                      child: Column(
                        children: ThemeMode.values.map((m) {
                          return RadioListTile<ThemeMode>(
                            value: m,
                            title: Text(ThemeService.label(m)),
                            secondary: Icon(_iconFor(m)),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                const Divider(height: 24),
                const _SectionHeader(label: '解锁序列'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '当前：${SecretService.display(_current)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      _DraftDisplay(
                        value: _draft,
                        error: _error,
                        onClear: _draft.isEmpty ? null : _clearDraft,
                      ),
                      const SizedBox(height: 12),
                      _SecretKeypad(onKey: _onKey),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _save,
                        child: const Text('保存解锁序列'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '可用字符：0-9 + - × ÷ % = ± . AC。在计算器主界面按下'
                        '同样的键序列即可静默解锁；窗口式匹配，所以序列可以'
                        '"藏"在更长的算式末尾。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _iconFor(ThemeMode m) => switch (m) {
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
        ThemeMode.system => Icons.brightness_auto_outlined,
      };
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DraftDisplay extends StatelessWidget {
  final String value;
  final String? error;
  final VoidCallback? onClear;

  const _DraftDisplay({required this.value, this.error, this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = error != null;
    final shown = value.isEmpty ? '请通过下方键盘输入' : SecretService.display(value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isError ? theme.colorScheme.error : theme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shown,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: value.isEmpty
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: '清空',
                  icon: const Icon(Icons.cancel),
                  onPressed: onClear,
                ),
            ],
          ),
          if (isError) ...[
            const SizedBox(height: 6),
            Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Key {
  final String label;
  final String? _value;
  const _Key(this.label, [this._value]);
  String get value => _value ?? label;
}

class _SecretKeypad extends StatelessWidget {
  final void Function(String key) onKey;

  const _SecretKeypad({required this.onKey});

  static const List<List<_Key>> _layout = [
    [_Key('AC', SecretService.acChar), _Key('±'), _Key('%'), _Key('÷')],
    [_Key('7'), _Key('8'), _Key('9'), _Key('×')],
    [_Key('4'), _Key('5'), _Key('6'), _Key('-')],
    [_Key('1'), _Key('2'), _Key('3'), _Key('+')],
    [_Key('0'), _Key('.'), _Key('='), _Key('⌫')],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _layout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: row.map((k) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _KeyButton(
                    label: k.label,
                    onTap: () => onKey(k.value),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  bool get _isEditor => label == '⌫';
  bool get _isCalcFn => label == 'AC' || label == '±' || label == '%';
  bool get _isCalcOp =>
      label == '+' ||
      label == '-' ||
      label == '×' ||
      label == '÷' ||
      label == '=';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg;
    final Color fg;
    if (_isEditor) {
      bg = theme.colorScheme.errorContainer;
      fg = theme.colorScheme.onErrorContainer;
    } else if (_isCalcOp) {
      bg = theme.colorScheme.primaryContainer;
      fg = theme.colorScheme.onPrimaryContainer;
    } else if (_isCalcFn) {
      bg = theme.colorScheme.tertiaryContainer;
      fg = theme.colorScheme.onTertiaryContainer;
    } else {
      bg = theme.colorScheme.surfaceContainerHighest;
      fg = theme.colorScheme.onSurface;
    }
    return AspectRatio(
      aspectRatio: 1.6,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
