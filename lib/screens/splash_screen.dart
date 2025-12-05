import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          ),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.note_alt_rounded, size: 100, color: Colors.white,),
                  SizedBox(height: 24,),
                  Text(
                    'NoteMate',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    'Your personal note companion!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  )
                ],
              ),
            ),
          )
        ),
    );
  }

}