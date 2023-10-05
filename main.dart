import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:maps/maps_screen.dart';

const LatLng currentLocation = LatLng(25.1193, 55.3773);
void main() {
  runApp(const ProviderScope(child: NearByDr()));
}

class NearByDr extends StatefulWidget {
  const NearByDr({super.key});

  @override
  State<NearByDr> createState() => _NearByDrState();
}

class _NearByDrState extends State<NearByDr> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zen Maps",
      //theme: ThemeData(),
      home: SplashScreen(),
    );
  }
}

//SplashSCreen will be small ANIMATION before opening maps
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5)).then((value) => Navigator.of(context)
        .pushReplacement(
            MaterialPageRoute(builder: (context) => MapsScreen())));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        height: 200,
        width: 200,
        child: LottieBuilder.asset("assets/animassets/mapanimation.json"),
      )),
    );
  }
}
