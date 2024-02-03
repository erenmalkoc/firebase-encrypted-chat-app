import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingView extends StatelessWidget {
   const LoadingView({super.key});

   static const spinkit = SpinKitFadingCircle(
     color: Colors.indigo,
     size: 50.0,
   );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10.withOpacity(0.8),
      child:  const Center(
        child: spinkit,
      ),
    );
  }
}