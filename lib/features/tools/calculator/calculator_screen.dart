import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  List<String> _history = [];

  final List<List<String>> _buttons = [
    ['AC', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  void _onButton(String val) {
    setState(() {
      if (val == 'AC') {
        _expression = '';
        _result = '0';
      } else if (val == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (val == '=') {
        _calculate();
      } else if (val == '±') {
        if (_expression.isNotEmpty && !_expression.startsWith('-')) {
          _expression = '-$_expression';
        } else if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        }
      } else {
        _expression += val;
        _liveCalculate();
      }
    });
  }

  void _liveCalculate() {
    try {
      final expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');
      final p = GrammarParser();
      final exp = p.parse(expr);
      final result = exp.evaluate(EvaluationType.REAL, ContextModel());
      _result = result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
    } catch (_) {}
  }

  void _calculate() {
    try {
      final expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');
      final p = GrammarParser();
      final exp = p.parse(expr);
      final result = exp.evaluate(EvaluationType.REAL, ContextModel());
      final res = result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '');
      _history.insert(0, '$_expression = $res');
      if (_history.length > 20) _history.removeLast();
      _expression = res;
      _result = res;
    } catch (_) {
      _result = 'Error';
    }
  }

  Color _btnColor(String val) {
    if (val == '=') return Theme.of(context).colorScheme.primary;
    if (['÷', '×', '-', '+'].contains(val))
      return Theme.of(context).colorScheme.secondary;
    if (['AC', '⌫', '%'].contains(val))
      return Theme.of(context).colorScheme.error.withOpacity(0.8);
    return Theme.of(context).colorScheme.surfaceVariant;
  }

  Color _txtColor(String val) {
    if (['=', '÷', '×', '-', '+', 'AC', '⌫', '%'].contains(val))
      return Colors.white;
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculator),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _result));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.copied)));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: TextStyle(
                        fontSize: 28,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _result,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _buttons
                    .map((row) => Expanded(
                          child: Row(
                            children: row
                                .map((val) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _btnColor(val),
                                            foregroundColor: _txtColor(val),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () => _onButton(val),
                                          child: Text(
                                            val,
                                            style:
                                                const TextStyle(fontSize: 22),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(_history[i]),
          leading: const Icon(Icons.history),
        ),
      ),
    );
  }
}
