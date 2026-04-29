import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../services/secret_service.dart';
import 'folder_picker_screen.dart';
import 'permission_gate.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  /// Current operand text (also used for raw secret matching).
  String _entry = '0';

  /// Literal expression the user is currently building, e.g. "123+456".
  /// After `=` this is reset to the formatted result so the main display
  /// continues to read from a single source.
  String _expression = '';

  /// Previously evaluated expression, shown small/dim above the main
  /// display until the user starts a new input.
  String _lastExpression = '';

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

  static final RegExp _opPattern = RegExp(r'[+\-×÷]');

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
      if (_evaluated) {
        _entry = d;
        _expression = d;
        _lastExpression = '';
        _started = true;
        _evaluated = false;
      } else if (!_started) {
        _entry = d;
        _started = true;
        // If a pending op was just entered, _expression already ends with the
        // op and we append the digit; otherwise this is a fresh entry.
        _expression =
            _pendingOp != null && _expression.isNotEmpty ? '$_expression$d' : d;
      } else {
        if (_entry.length >= 16) return;
        _entry = _entry + d;
        _expression = _expression + d;
      }
    });
    _trackSecret(d);
  }

  void _onDot() {
    setState(() {
      if (_evaluated) {
        _entry = '0.';
        _expression = '0.';
        _lastExpression = '';
        _started = true;
        _evaluated = false;
      } else if (!_started) {
        _entry = '0.';
        _started = true;
        _expression = _pendingOp != null && _expression.isNotEmpty
            ? '${_expression}0.'
            : '0.';
      } else if (!_entry.contains('.')) {
        _entry = '$_entry.';
        _expression = '$_expression.';
      }
    });
    _trackSecret('.');
  }

  void _onSign() {
    setState(() {
      if (_entry == '0' || _entry == '0.') return;
      final wasNegative = _entry.startsWith('-');
      _entry = wasNegative ? _entry.substring(1) : '-$_entry';
      _expression = _toggleOperandSign(_expression, makeNegative: !wasNegative);
    });
    _trackSecret('±');
  }

  void _onPercent() {
    final v = (double.tryParse(_entry) ?? 0.0) / 100.0;
    setState(() {
      final committed = _expression.isEmpty ? _entry : '$_expression%';
      _entry = _format(v);
      _expression = _entry;
      _lastExpression = committed;
      _evaluated = true;
    });
    _trackSecret('%');
  }

  void _onClear() {
    setState(() {
      _entry = '0';
      _expression = '';
      _lastExpression = '';
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
      if (_evaluated) {
        // Chaining off the just-shown result: start a fresh expression from
        // the result, drop the prior history line.
        _expression = '$_entry$op';
        _lastExpression = '';
        _acc = v;
      } else if (_acc != null && _pendingOp != null && _started) {
        _acc = _apply(_acc!, v, _pendingOp!);
        _entry = _format(_acc!);
        _expression = '$_expression$op';
      } else if (!_started && _pendingOp != null && _expression.isNotEmpty) {
        // User changed their mind about the operator before typing the next
        // operand: replace the trailing op in the expression.
        _expression = _expression.substring(0, _expression.length - 1) + op;
        _acc = v;
      } else {
        // First op for this calculation.
        _expression =
            _expression.isEmpty ? '$_entry$op' : '$_expression$op';
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
      _lastExpression = _expression;
      _entry = _format(result);
      _expression = _entry;
      _acc = null;
      _pendingOp = null;
      _started = false;
      _evaluated = true;
    });
    _trackSecret('=');
  }

  /// Returns [expression] with the trailing operand's sign toggled to match
  /// [makeNegative]. The trailing operand is whatever follows the last
  /// arithmetic operator (or the entire string if there is no operator).
  String _toggleOperandSign(String expression, {required bool makeNegative}) {
    if (expression.isEmpty) return expression;
    final matches = _opPattern.allMatches(expression).toList();
    final operandStart = matches.isEmpty ? 0 : matches.last.end;
    final head = expression.substring(0, operandStart);
    var tail = expression.substring(operandStart);
    final isNegative = tail.startsWith('-');
    if (makeNegative && !isNegative) {
      tail = '-$tail';
    } else if (!makeNegative && isNegative) {
      tail = tail.substring(1);
    }
    return '$head$tail';
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
    if (v.isNaN || v.isInfinite) return AppLocalizations.of(context).calcError;
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
      _expression = '';
      _lastExpression = '';
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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_lastExpression.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _lastExpression,
                            maxLines: 1,
                            style: TextStyle(
                              color: displayColor.withValues(alpha: 0.45),
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _expression.isEmpty ? _entry : _expression,
                        maxLines: 1,
                        style: TextStyle(
                          color: displayColor,
                          fontSize: 88,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
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
