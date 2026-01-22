import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/error/error_widget.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/util/suproxu_logo.dart';
import 'package:suproxu/core/widgets/trade_warning.dart';
import 'package:suproxu/features/Rules/rulesPage.dart';
import 'package:suproxu/features/auth/bloc/auth_bloc.dart';
import 'package:suproxu/features/auth/forgot-pass/forgetPassword.dart';


class LoginPages extends StatefulWidget {
  @override
  _LoginPagesState createState() => _LoginPagesState();
  static const String routeName = '/login-screen';

  const LoginPages({super.key});
}

class _LoginPagesState extends State<LoginPages> {
  late AuthBloc _authBloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false; // For toggling password visibility

  bool flag = true;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // userAuthentication() {
  //   if (_emailController.text == '' && _emailController.text.isEmpty ||
  //       _passwordController.text == '' && _passwordController.text.isEmpty) {
  //     failedToast(context, 'Please Enter Required Fields');
  //   } else {
  //     _authBloc.add(AuthUserLoginEvent(
  //         uEmail: _emailController.text, uPassword: _passwordController.text));
  //   }
  // }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Rulespage()),
      );
    }
  }

  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     if (_emailController.text == "trading@gmail.com" &&
  //         _passwordController.text == "Super@trade#123") {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool(loginKey, true); // Save login status
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => Rulespage()));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Invalid email or password')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: InternetConnectionService().connectionStream,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return const NoInternetConnection(); // Show your offline UI
        }
        return Scaffold(
          backgroundColor: zBlack,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  // SizedBox(height: 50),
                  Center(child: SuproxuLogo(width: 200)),
                  // const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      // vertical: 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Email Field
                            SizedBox(
                              child: TextFormField(
                                style: TextStyle(color: kWhiteColor),
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_passwordFocusNode);
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 20.0,
                                  ),
                                  label: const Text("Username/Email ID"),
                                  labelStyle: TextStyle(
                                    // fontFamily: 'JetBrainsMono',
                                    fontSize: 16,
                                    color: kWhiteColor,
                                  ),
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: kGoldenBraunColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: kGoldenBraunColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: kGoldenBraunColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email ID';
                                  }
                                  // final emailRegex = RegExp(
                                  //     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  // if (!emailRegex.hasMatch(value)) {
                                  //   return 'Please enter a valid email ID';
                                  // }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 15.h),
                            // Password Field
                            SizedBox(
                              child: TextFormField(
                                style: TextStyle(color: kWhiteColor),
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  fillColor: zBlack,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 20.0,
                                  ),
                                  label: const Text("Password"),
                                  labelStyle: TextStyle(
                                    // fontFamily: 'JetBrainsMono',
                                    fontSize: 16,
                                    color: kWhiteColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: kGoldenBraunColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: kGoldenBraunColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                      color: kGoldenBraunColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: zBlack,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (value.length < 6) {
                                    return 'Password too short (min 6 chars)';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Forgot Password Text
                  InkWell(
                    onTap: () {
                      context.pushNamed(Forgetpassword.routeName);
                      // Navigator.pushNamed(context, Forgetpassword.routeName);
                    },
                    child: const Text("Forgot Password?").textStyleH1(),
                  ),
                  SizedBox(height: 30.h),
                  BlocConsumer(
                    bloc: _authBloc,
                    listener: (context, state) async {
                      if (state is AuthLoadedSuccessStateForUserLogin) {
                        if (state.loginModel.status == 1) {
                          successToastMsg(
                            context,
                            state.loginModel.message.toString(),
                          );
                          _authBloc.add(NavigateToGlobalNavbarEvent());
                        } else {
                          failedToast(
                            context,
                            state.loginModel.message.toString(),
                          );
                        }
                      } else if (state is AuthFailedErrorStateForUserLogin) {
                        ErrorPage(errorMessage: state.error);
                      } else if (state
                          is NavigateToGlobalNavBarAuthActionState) {
                        GoRouter.of(context).goNamed(TradeWarning.routeName);
                        // Navigator.pushReplacementNamed(
                        //     context, GlobalNavBar.routeName);
                      }
                    },
                    builder: (_, state) {
                      if (state is AuthLoadingState) {
                        return flag
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: kGoldenBraunColor,
                                  //minimumSize: const Size(120, 20),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 80,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "LOGGING IN...",
                                ).textStyleH1W(),
                              );
                      }
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: kGoldenBraunColor,
                          //minimumSize: const Size(120, 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          final formState = _formKey.currentState;
                          if (formState != null) {
                            final isValid = formState.validate();
                            // Autofocus logic for empty fields
                            if (_emailController.text.isEmpty) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_emailFocusNode);
                            } else if (_passwordController.text.isEmpty) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocusNode);
                            }
                            if (isValid) {
                              formState.save();
                              _authBloc.add(
                                AuthUserLoginEvent(
                                  uEmail: _emailController.text,
                                  uPassword: _passwordController.text,
                                ),
                              );
                              flag = false;
                            }
                          }
                          setState(() {});
                        },
                        child: const Text("LOG IN").textStyleH1W(),
                      );
                    },
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Disclaimer:').textStyleH1(),
                        SizedBox(height: 8.h),
                        ...[
                          const Text(
                            'No real money involved. This is a virtual trading application which has all features to trade.',
                          ).textStyleH5(),
                          SizedBox(height: 8.h),
                          const Text(
                            'This application is used for exchanging views on market for trading purposes only.',
                          ).textStyleH5(),
                          SizedBox(height: 8.h),
                          const Text(
                            'The Super Trade is not liable for any real money transaction. We dont deal in any real money.',
                          ).textStyleH5(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
