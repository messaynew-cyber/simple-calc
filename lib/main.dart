import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calc',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _display = '0';
  String _expression = '';
  String _result = '';
  bool _justEvaluated = false;

  void _onPress(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _result = '';
        _justEvaluated = false;
      } else if (value == '⌫') {
        if (_justEvaluated) return;
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
        }
      } else if (value == '=') {
        _evaluate();
      } else {
        if (_justEvaluated) {
          if (_isOperator(value)) {
            _expression = _result + value;
            _display = _expression;
          } else {
            _expression = value;
            _display = _expression;
          }
          _result = '';
          _justEvaluated = false;
        } else {
          if (_expression == 'Error') {
            _expression = '';
          }
          _expression += value;
          _display = _expression;
        }
      }
    });
  }

  void _evaluate() {
    try {
      String expr = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _result = eval == eval.roundToDouble()
          ? eval.toInt().toString()
          : eval.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      _display = _result;
      _expression = _expression;
      _justEvaluated = true;
    } catch (e) {
      _display = 'Error';
      _expression = 'Error';
      _result = '';
      _justEvaluated = true;
    }
  }

  bool _isOperator(String v) => v == '+' || v == '−' || v == '×' || v == '÷' || v == '%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: GoogleFonts.spaceMono(
                        fontSize: 22,
                        color: Colors.white54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: GoogleFonts.spaceMono(
                        fontSize: _display.length > 10 ? 36 : 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Buttons
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _row(['C', '÷', '×', '⌫'], isTop: true),
                    _row(['7', '8', '9', '−']),
                    _row(['4', '5', '6', '+']),
                    _row(['1', '2', '3', '%']),
                    _row(['0', '00', '.', '='], isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> buttons, {bool isTop = false, bool isLast = false}) {
    return Expanded(
      child: Row(
        children: buttons.map((b) {
          final isOp = _isOperator(b) || b == '%' || b == '=' || b == 'C' || b == '⌫';
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: b == '='
                    ? const Color(0xFF6C5CE7)
                    : isOp
                        ? const Color(0xFF1E1E2E)
                        : const Color(0xFF2D2D3F),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _onPress(b),
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      b,
                      style: GoogleFonts.spaceMono(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isOp ? const Color(0xFF6C5CE7) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
