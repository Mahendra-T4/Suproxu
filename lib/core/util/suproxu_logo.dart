import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suproxu/features/global/bloc/global_bloc.dart';

class SuproxuLogo extends StatefulWidget {
  const SuproxuLogo({super.key, this.width, this.isTransparent = true});
  final double? width;
  final bool isTransparent;

  @override
  State<SuproxuLogo> createState() => _SuproxuLogoState();
}

class _SuproxuLogoState extends State<SuproxuLogo> {
  late final GlobalBloc _globalBloc;

  @override
  void initState() {
    super.initState();
    _globalBloc = GlobalBloc();
    _globalBloc.add(LoadPerkLogoImageFromServerEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _globalBloc,
      builder: (context, state) {
        switch (state.runtimeType) {
          case GlobalLoadingState:
            return Center(child: const CircularProgressIndicator());
          case LoadPerkLogoImageFromServerSuccessState:
            final logoState =
                (state as LoadPerkLogoImageFromServerSuccessState).logoModel;
            return logoState.status == 1
                ? CachedNetworkImage(
                    imageUrl: widget.isTransparent
                        ? logoState.transparent.toString()
                        : logoState.logo.toString(),
                    width: widget.width ?? 300,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : Center(
                    child: Text(
                      logoState.message ?? 'Failed to load logo',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
          case LoadPerkLogoImageFromServerFailedErrorState:
            return const Icon(Icons.error);
          default:
            return const SizedBox();
        }
      },
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
