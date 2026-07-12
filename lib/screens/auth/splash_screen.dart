import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2E7D32),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.school,
              color: Colors.white,
              size: 80,
            ),

            const SizedBox(height:20),

            const Text(
              "ALU Connect",
              style: TextStyle(
                color: Colors.white,
                fontSize:32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:10),

            Text(
              "Connecting Students & Startups",
              style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontSize:16,
              ),
            ),

            const SizedBox(height:40),

            const CircularProgressIndicator(
              color: Colors.white,
            )

          ],
        ),
      ),
    );
  }
}