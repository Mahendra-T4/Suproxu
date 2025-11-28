import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:suproxu/core/service/connectivity/connectivity_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/features/auth/forgot-pass/setPassword.dart';
import 'package:toast/toast.dart';


class Otpverification extends StatefulWidget {
  const Otpverification({super.key});

  @override
  State<Otpverification> createState() => _OtpverificationState();
}

class _OtpverificationState extends State<Otpverification>
    with TickerProviderStateMixin {
  var otpController = TextEditingController();
  String otp = "";
  FocusNode focusNode = FocusNode();
  AnimationController? controller;
  int levelClock = 30;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: levelClock),
    );
    controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
     final connectivity = context.watch<ConnectivityService>();
    return connectivity.isConnected ? Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child:  SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     'OTP Verification',
                  //     style: TextStyle(
                  //       fontSize: 25,
                  //       fontFamily: "Montserrat",
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),S
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 280.0,
                    padding: const EdgeInsets.only(top: 30.0),
                    child: PinCodeFields(
                      onComplete: (onComplete) {
                        otp = onComplete;
                      },
                      onChange: (v) {
                        otp = v;
                      },
                      length: 6,
                      keyboardType: TextInputType.number,
                      autoHideKeyboard: false,
                      textStyle: const TextStyle(color: Colors.white),
                      borderColor: Colors.white,
                      borderWidth: 1,
                      fieldBorderStyle: FieldBorderStyle.square,
                      fieldBackgroundColor: Colors.black,
                      fieldHeight: 40,
                      //animation: Animations.rotateRight,
                      animationDuration: const Duration(seconds: 1),
                      animationCurve: Curves.fastEaseInToSlowEaseOut,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Countdown(
                      animation: StepTween(
                        begin: levelClock,
                        end: 0,
                      ).animate(controller!),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      //backgroundColor: Colors.indigoAccent,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      if (otp == "") {
                        ToastContext().init(context);
                        Toast.show("Please Enter OTP",
                            gravity: Toast.bottom, duration: Toast.lengthLong);
                      } else if (otp.length < 6) {
                        ToastContext().init(context);
                        Toast.show("Please Enter Proper OTP",
                            gravity: Toast.bottom, duration: Toast.lengthLong);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Setpassword()),
                        );
                      }
                    },
                    child: const Text(
                      "Verify",
                      style: TextStyle(
                        //fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
   
    ): const NoInternetConnection();
  }
}

class Countdown extends AnimatedWidget {
  const Countdown({super.key, required this.animation})
      : super(listenable: animation);

  final Animation<int> animation;

  @override
  Widget build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);
    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text(
      'Resend OTP in: $timerText',
      style: const TextStyle(
        //color: Color(0xFF083E92),
        color: Colors.white,
        fontSize: 13,
        fontFamily: "OpenSansRegular",
      ),
    );
  }
}

