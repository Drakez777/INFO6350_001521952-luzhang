import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// 根组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const CalculatorPage(),
    );
  }
}

/// 圆形按钮
class CalcButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bgColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: bgColor,
        elevation: 2,
        padding: EdgeInsets.zero,
        fixedSize: const Size(72, 72),
      ),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
    );
  }
}

/// 主页面
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expr = '';
  String _res = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // 显示框
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expr,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 28),
                    ),
                    Text(
                      _res,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 48),
                    ),
                  ],
                ),
              ),
            ),
            // 按钮区
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: _buildButtons(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------- 事件与业务逻辑 ---------- */

  List<Widget> _buildButtons() {
    final ops = ['x', '/', '+', '-'];
    final nums = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0'];
    List<Widget> list = [];

    // 把 “=” 放第一格，跟截图一致
    list.add(CalcButton(
        label: '=',
        bgColor: Colors.orange,
        onTap: _onEqual,
    ));

    // 数字
    for (var n in nums) {
      list.add(CalcButton(label: n, onTap: () => _onNumber(n)));
    }

    // C
    list.add(CalcButton(
        label: 'C',
        bgColor: Colors.grey.shade300,
        onTap: _onClear,
    ));

    // 运算符
    for (var o in ops) {
      list.add(CalcButton(
        label: o,
        bgColor: Colors.grey.shade300,
        onTap: () => _onOperator(o),
      ));
    }

    return list;
  }

  void _onNumber(String n) {
    setState(() => _expr += n);
  }

  void _onOperator(String op) {
    if (_expr.isEmpty) return;
    if (_containsOperator(_expr)) _expr = _evaluate(_expr);
    setState(() => _expr += op);
  }

  void _onEqual() {
    if (!_containsOperator(_expr)) return;
    setState(() {
      _res = _evaluate(_expr);
      _expr = '';
    });
  }

  void _onClear() {
    setState(() {
      _expr = '';
      _res = '0';
    });
  }

  /* ---------- 计算工具 ---------- */

  bool _containsOperator(String s) =>
      s.contains('+') || s.contains('-') || s.contains('x') || s.contains('/');

  String _evaluate(String exp) {
    final op = exp.contains('+')
        ? '+'
        : exp.contains('-')
            ? '-'
            : exp.contains('x')
                ? 'x'
                : '/';

    final parts = exp.split(op);
    if (parts.length != 2) return exp;

    final a = double.parse(parts[0]);
    final b = double.parse(parts[1]);
    double r;
    switch (op) {
      case '+':
        r = a + b;
        break;
      case '-':
        r = a - b;
        break;
      case 'x':
        r = a * b;
        break;
      default:
        r = a / b;
    }
    return r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 2);
  }
}