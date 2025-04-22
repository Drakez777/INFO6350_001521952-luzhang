import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(home: MultiAnimationExample()));
}

class MultiAnimationExample extends StatefulWidget {
  @override
  _MultiAnimationExampleState createState() => _MultiAnimationExampleState();
}

class _MultiAnimationExampleState extends State<MultiAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _opacityVisible = true;
  bool _isMoved = false;

  @override
  void initState() {
    super.initState();

    // 初始化 AnimationController
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // 缩放动画
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOpacity() {
    setState(() {
      _opacityVisible = !_opacityVisible;
    });
  }

  void _togglePosition() {
    setState(() {
      _isMoved = !_isMoved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi Animation Example')),
      body: Stack(
        children: [
          // 1. 渐变透明度动画
          Center(
            child: AnimatedOpacity(
              opacity: _opacityVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 2),
              child: Image.asset('assets/flutter.png', width: 100),
            ),
          ),
          // 2. 旋转动画
          Positioned(
            top: 50,
            left: 50,
            child: AnimatedBuilder(
              animation: _controller,
              child: Image.asset('assets/flutter.png', width: 100),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: child,
                );
              },
            ),
          ),
          // 3. 缩放动画
          Positioned(
            top: 200,
            left: 50,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset('assets/flutter.png', width: 100),
            ),
          ),
          // 4. 位置动画
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            top: _isMoved ? 400 : 50,
            left: _isMoved ? 300 : 50,
            child: GestureDetector(
              onTap: _togglePosition,
              child: Image.asset('assets/flutter.png', width: 100),
            ),
          ),
          // 5. 页面间动画 (Hero)
          Positioned(
            top: 50,
            right: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPage()),
                );
              },
              child: Hero(
                tag: 'imageHero',
                child: Image.asset('assets/flutter.png', width: 100),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleOpacity,
        child: Icon(Icons.visibility),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Page')),
      body: Center(
        child: Hero(
          tag: 'imageHero',
          child: Image.asset('assets/flutter.png'),
        ),
      ),
    );
  }
}