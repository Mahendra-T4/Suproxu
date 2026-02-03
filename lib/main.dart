import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/router/router_confic.dart';
import 'package:suproxu/core/service/Auth/auth_wiget_service.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/notification/notification_service.dart';
import 'package:suproxu/core/service/repositorie/global_respo.dart';
import 'package:suproxu/features/auth/bloc/auth_bloc.dart';
import 'package:suproxu/features/navbar/TradeScreen/bloc/trade_bloc.dart';
import 'package:suproxu/features/navbar/home/bloc/home_bloc.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  InternetConnectionService().startMonitoring();
  // AuthService().checkUserValidation(context!);

  NotificationService().fetchUnreadCount();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => TradeBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => HomeBloc()),
      ],
      child: const MyApp(),
    ),
  );
  // ClientConfig.initStudents();
  GlobalRepository.stocksMapper();
  // getDeviceID();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: ProviderScope(
        child: MaterialApp.router(
          title: 'Suproxu',
          theme: ThemeData(
            scaffoldBackgroundColor: kWhiteColor,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routerConfig: routerConfig,

          // builder: (context, child) {
          //   return AuthCheckWidget(child: child ?? const SizedBox());
          // },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
