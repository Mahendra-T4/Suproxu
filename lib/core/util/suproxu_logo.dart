import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SuproxuLogo extends StatelessWidget {
  const SuproxuLogo({super.key, this.width});
  final double? width;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: "https://www.suproxu.com/assets/img/suproxu-logo.jpg",
      width: width ?? 300,
      // progressIndicatorBuilder: (context, url, downloadProgress) =>
      //     CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
