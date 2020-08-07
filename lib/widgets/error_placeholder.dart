import 'package:flutter/material.dart';
import 'package:flutter_bebena/widgets/label.dart';

/// Centered Placeholder image for displaying error
class ErrorPlaceholder extends StatelessWidget {

  ErrorPlaceholder({
    this.title              = "Terjadi Kesalahan",
    @required this.message,
    this.placeholderImage
  });

  /// Title for default placeholder, 
  /// 
  /// default __Terjadi Kesalahan__
  final String title;
  final String message;

  /// Placeholder Image from asset
  final String placeholderImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 200,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(placeholderImage, width: double.infinity, height: 100, fit: BoxFit.contain),
            SizedBox(height: 16.0),
            Label(title, type: LabelType.heading6),
            SizedBox(height: 16.0),
            Label(message)
          ],
        ),
      ),
    );
  }
}