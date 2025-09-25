// widgets/loading_spinner.dart
import 'package:flutter/material.dart';
import '../main.dart';

class LoadingSpinner extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingSpinner({
    Key? key,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppConstants.primaryGreen,
        ),
        strokeWidth: 2.5,
      ),
    );
  }
}