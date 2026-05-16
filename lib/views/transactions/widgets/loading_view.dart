import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import './transaction_constants.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Lottie.network(lottieLoading, width: 120, height: 120,
          errorBuilder: (_, __, ___) =>
          const CircularProgressIndicator()),
      const SizedBox(height: 10),
      const Text('Loading transactions…',
          style: TextStyle(color: textSec, fontSize: 13)),
    ]),
  );
}
