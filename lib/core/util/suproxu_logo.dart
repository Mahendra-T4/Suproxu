import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/features/navbar/home/model/logo_model.dart';
import 'package:suproxu/features/navbar/home/repository/home_repo.dart';

final logoProvider = FutureProvider<LogoModel>(
  (ref) => HomeRepository.getLogo(),
);

class SuproxuLogo extends ConsumerWidget {
  const SuproxuLogo({super.key, this.width, this.isTransparent = true});
  final double? width;
  final bool isTransparent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logo = ref.watch(logoProvider);

    return logo.when(
      data: (data) {
        log('Logo URL: ${data.transparent}');
        return data.status == 1
            ? CachedNetworkImage(
                imageUrl: isTransparent
                    ? data.transparent.toString()
                    : data.logo.toString(),
                width: width ?? 300,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : Center(
                child: Text(
                  data.message.toString(),
                  style: TextStyle(color: Colors.red),
                ),
              );
      },
      loading: () => Center(child: const CircularProgressIndicator()),
      error: (error, stackTrace) => const Icon(Icons.error),
    );
  }
}

// CachedNetworkImage(
//       imageUrl: "https://www.suproxu.com/assets/img/suproxu-logo.jpg",
//       width: width ?? 300,
//       // progressIndicatorBuilder: (context, url, downloadProgress) =>
//       //     CircularProgressIndicator(value: downloadProgress.progress),
//       errorWidget: (context, url, error) => Icon(Icons.error),
//     );
