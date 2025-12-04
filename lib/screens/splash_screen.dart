import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
    late AnimationController _controller;
    late Animation<double> _fadeAnimation;

    @override
      void initState() {
      super.initState();
        _controller = AnimationController(vsync: this, duration: Duration(microseconds: 1500));
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
        _controller.forward();
        _initializeApp();
  }

  Future<void> _initializeApp() async {
      await Future.delayed(Duration(seconds: 2));

      if(!mounted) return;

      if(mounted){
       // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen));
      }
  }

  @override
    void dispose() {
      _controller.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }

}