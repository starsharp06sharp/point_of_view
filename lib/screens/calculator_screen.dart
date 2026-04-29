import 'package:flutter/material.dart';

import '../services/secret_service.dart';
import 'folder_picker_screen.dart';
import 'permission_gate.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  /// What's shown on the display, also used for raw secret matching.
  String _entry = '0';

  /// Last committed operand.
  double? _acc;

  /// Pending binary operator: '+', '-', '×', '÷'.
  String? _pendingOp;

  /// True once the user has begun typing the current entry.
  bool _started = false;

  /// True right after '=' was pressed.
  bool _evaluated = false;

  String _secret = SecretService.defaultSecret;
  String _secretBuf = '';

  @override
  void initState() {
    super.initState();
    _loadSecret();
  }

  Future<void> _loadSecret() async {
    final s = await SecretService.read();
    if (!mounted) return;
    setState(() => _secret = s);
  }

  /// Tracks the last [_secret].length keys among the secret alphabet
  /// (every value-bearing calculator key — digits, operators, `=`, `%`,
  /// `±`, `.`, and `AC` encoded as `C`). Anything outside the alphabet
  /// resets the buffer.
  void _trackSecret(String key) {
    if (!SecretService.isAllowed(key)) {
      _secretBuf = '';
      return;
    }
    var buf = _secretBuf + key;
    if (buf.length > _secret.length) {
      buf = buf.substring(buf.length - _secret.length);
    }
    _secretBuf = buf;
    if (_secret.isNotEmpty && _secretBuf == _secret) _unlock();
  }

  // ---------- input handlers ----------

  void _onDigit(String d) {
    setState(() {
      if (_evaluated || !_started) {
        _entry = d;
        _started = true;
        _evaluated = false;
      } else {
        if (_entry.length >= 16) return;
        _entry = _entry + d;
      }
    });
    _trackSecret(d);
  }

  void _onDot() {
    setState(() {
      if (_evaluated || !_started) {
        _entry = '0.';
        _started = true;
        _evaluated = false;
      } else if (!_entry.contains('.')) {
        _entry = '$_entry.';
      }
    });
    _trackSecret('.');
  }

  void _onSign() {
    setState(() {
      if (_entry == '0' || _entry == '0.') return;
      _entry = _entry.startsWith('-') ? _entry.substring(1) : '-$_entry';
    });
    _trackSecret('±');
  }

  void _onPercent() {
    final v = (double.tryParse(_entry) ?? 0.0) / 100.0;
    setState(() {
      _entry = _format(v);
      _evaluated = true;
    });
    _trackSecret('%');
  }

  void _onClear() {
    setState(() {
      _entry = '0';
      _acc = null;
      _pendingOp = null;
      _started = false;
      _evaluated = false;
    });
    _trackSecret(SecretService.acChar);
  }

  void _onOp(String op) {
    final v = double.tryParse(_entry) ?? 0.0;
    setState(() {
      if (_acc != null && _pendingOp != null && _started && !_evaluated) {
        _acc = _apply(_acc!, v, _pendingOp!);
        _entry = _format(_acc!);
      } else {
        _acc = v;
      }
      _pendingOp = op;
      _started = false;
      _evaluated = false;
    });
    _trackSecret(op);
  }

  void _onEquals() {
    if (_acc == null || _pendingOp == null) {
      _trackSecret('=');
      return;
    }
    final v = double.tryParse(_entry) ?? 0.0;
    final result = _apply(_acc!, v, _pendingOp!);
    setState(() {
      _entry = _format(result);
      _acc = null;
      _pendingOp = null;
      _started = false;
      _evaluated = true;
    });
    _trackSecret('=');
  }

  // ---------- helpers ----------

  double _apply(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
    }
    return b;
  }

  String _format(double v) {
    if (v.isNaN || v.isInfinite) return '错误';
    if (v == v.truncateToDouble() && v.abs() < 1e16) {
      return v.toInt().toString();
    }
    var s = v.toStringAsFixed(8);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  Future<void> _unlock() async {
    setState(() {
      _entry = '0';
      _acc = null;
      _pendingOp = null;
      _started = false;
      _evaluated = false;
      _secretBuf = '';
    });
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PermissionGate(child: FolderPickerScreen()),
      ),
    );
    if (mounted) await _loadSecret();
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final displayColor = isDark ? Colors.white : Colors.black;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _entry,
                    maxLines: 1,
                    style: TextStyle(
                      color: displayColor,
                      fontSize: 88,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  _row([
                    _btn('AC', _CalcKind.fn, () => _onClear()),
                    _btn('±', _CalcKind.fn, () => _onSign()),
                    _btn('%', _CalcKind.fn, () => _onPercent()),
                    _btn('÷', _CalcKind.op, () => _onOp('÷'),
                        active: _pendingOp == '÷' && !_started),
                  ]),
                  _row([
                    _btn('7', _CalcKind.number, () => _onDigit('7')),
                    _btn('8', _CalcKind.number, () => _onDigit('8')),
                    _btn('9', _CalcKind.number, () => _onDigit('9')),
                    _btn('×', _CalcKind.op, () => _onOp('×'),
                        active: _pendingOp == '×' && !_started),
                  ]),
                  _row([
                    _btn('4', _CalcKind.number, () => _onDigit('4')),
                    _btn('5', _CalcKind.number, () => _onDigit('5')),
                    _btn('6', _CalcKind.number, () => _onDigit('6')),
                    _btn('-', _CalcKind.op, () => _onOp('-'),
                        active: _pendingOp == '-' && !_started),
                  ]),
                  _row([
                    _btn('1', _CalcKind.number, () => _onDigit('1')),
                    _btn('2', _CalcKind.number, () => _onDigit('2')),
                    _btn('3', _CalcKind.number, () => _onDigit('3')),
                    _btn('+', _CalcKind.op, () => _onOp('+'),
                        active: _pendingOp == '+' && !_started),
                  ]),
                  _row([
                    _btn('0', _CalcKind.number, () => _onDigit('0'), flex: 2),
                    _btn('.', _CalcKind.number, _onDot),
                    _btn('=', _CalcKind.op, _onEquals),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: children),
    );
  }

  Widget _btn(String label, _CalcKind kind, VoidCallback onTap,
      {int flex = 1, bool active = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _CalcButton(
          label: label,
          kind: kind,
          active: active,
          onTap: onTap,
        ),
      ),
    );
  }
}

enum _CalcKind { number, fn, op }

class _CalcButton extends StatelessWidget {
  final String label;
  final _CalcKind kind;
  final bool active;
  final VoidCallback onTap;

  const _CalcButton({
    required this.label,
    required this.kind,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (Color bg, Color fg) = switch (kind) {
      _CalcKind.number => isDark
          ? (const Color(0xFF333333), Colors.white)
          : (const Color(0xFFE0E0E0), Colors.black),
      _CalcKind.fn => isDark
          ? (const Color(0xFFA5A5A5), Colors.black)
          : (const Color(0xFFBFBFBF), Colors.black),
      _CalcKind.op => active
          ? (isDark ? Colors.white : Colors.white, const Color(0xFFFF9500))
          : (const Color(0xFFFF9500), Colors.white),
    };

    return AspectRatio(
      aspectRatio: label == '0' ? 2.1 : 1,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
