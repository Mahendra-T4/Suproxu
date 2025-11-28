import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/features/auth/bloc/auth_bloc.dart';
import 'package:suproxu/features/auth/login/loginPage.dart';


class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  static const String routeName = '/forgot-password-page';

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late AuthBloc _authBloc;
  final FocusNode _emailFocusNode = FocusNode();
  bool flag = true;
  @override
  void initState() {
    _authBloc = AuthBloc();
    super.initState();
  }

  // authenticateForgotPassword() {
  //   if (_emailController.text == '' && _emailController.text.isEmpty) {
  //     failedToast(context, 'Please Fill Required Field');
  //   } else {
  //     _authBloc.add(AuthForgotUserPasswordEvent(uEmail: _emailController.text));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: InternetConnectionService().connectionStream,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return NoInternetConnection(); // Show your offline UI
          }
          return Container(
            color: greyColor,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: kWhiteColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.black,
                  title: const Text(
                    'Forget Password',
                  ).textStyleHT(),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30.0, left: 50, right: 50),
                            child: const Text(
                              'To send request for recover password fill the details',
                              textAlign: TextAlign.center,
                            ).textStyleH2(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20.0, left: 50, right: 50),
                            child: SizedBox(
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _emailController,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: _emailFocusNode,
                                  // inputFormatters: <TextInputFormatter>[
                                  //   FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                  // ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email ID';
                                    }
                                    final emailRegex = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Please enter a valid email ID';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    // prefixText: "+91",
                                    prefixStyle:
                                        const TextStyle(color: Colors.white),
                                    labelText: "Email ID",
                                    labelStyle: const TextStyle(
                                        // fontFamily: 'JetBrainsMono',
                                        fontSize: 16,
                                        color: zBlack),
                                    // filled: true,
                                    // fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(
                                          color: zBlack, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(
                                          color: zBlack, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(
                                          color: zBlack, width: 2.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            margin: const EdgeInsets.only(left: 50, right: 60),
                            width: 460,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: InkWell(
                                  onTap: () {
                                    context.pushNamed(LoginPages.routeName);
                                  },
                                  child: const Text(
                                    "Back to Login",
                                  ).textStyleH1(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          BlocConsumer(
                            bloc: _authBloc,
                            listener: (context, state) {
                              if (state is AuthForgotPasswordSuccessState) {
                                successToastMsg(
                                    context,
                                    state.forgotPasswordEntity.message
                                        .toString());
                              } else if (state
                                  is AuthForgotPasswordFailedErrorState) {
                                failedToast(context, state.error);
                              }
                            },
                            builder: (_, state) {
                              if (state is AuthLoadingState) {
                                return flag
                                    ? const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      )
                                    : Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 50),
                                        width: MediaQuery.sizeOf(context).width,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // padding: const EdgeInsets.symmetric(
                                            //     horizontal: 100, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            backgroundColor: kGoldenBraunColor,
                                          ),
                                          onPressed: () {},
                                          child: const Text(
                                            "SUBMITTING...",
                                          ).textStyleH1W(),
                                        ),
                                      );
                              }
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                width: MediaQuery.sizeOf(context).width,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // padding: const EdgeInsets.symmetric(
                                    //     horizontal: 100, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    backgroundColor: kGoldenBraunColor,
                                  ),
                                  onPressed: () {
                                    final formState = _formKey.currentState;
                                    if (formState != null) {
                                      final isValid = formState.validate();

                                      if (_emailController.text.isEmpty) {
                                        FocusScope.of(context)
                                            .requestFocus(_emailFocusNode);
                                      }
                                      if (isValid) {
                                        log('Sent Successfully');
                                        _authBloc.add(
                                            AuthForgotUserPasswordEvent(
                                                uEmail: _emailController.text,
                                                context: context));
                                      }
                                    }
                                  },
                                  child: const Text(
                                    "SUBMIT",
                                  ).textStyleH1W(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:trading_app/SignUpPages/loginPage.dart';
// import 'package:trading_app/SignUpPages/otpVerification.dart';
//
// class Forgotpassword extends StatefulWidget {
//   const Forgotpassword({super.key});
//
//   @override
//   State<Forgotpassword> createState() => _ForgotpasswordState();
// }
//
// class _ForgotpasswordState extends State<Forgotpassword> {
//   final GlobalKey<FormState> _formKey = GlobalKey();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [SizedBox(height: 100),
//                 Container(
//                   height: 150,
//                   width: 150,
//                   decoration: BoxDecoration(
//                       image: DecorationImage(image: AssetImage('assets/images/trade-removebg-preview.png'))
//                   ),
//                 ),
//                 Text('Forget Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Padding(padding: const EdgeInsets.only(top: 30.0, left: 50, right: 50),
//                   child: Text('To send request for recover password fill the details', style: TextStyle(fontSize: 12)),
//                 ),//SizedBox(height: 40),
//                 Padding(padding: const EdgeInsets.only(top: 20.0, left: 50, right: 50),
//                   child: SizedBox(
//                     child: TextFormField(
//                       //maxLength: 10,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: <TextInputFormatter>[
//                         FilteringTextInputFormatter.allow(RegExp("[0-9]")),
//                       ],
//                       validator: (value){
//                         if(value!.isEmpty){
//                           return "Please enter valid number";
//                         }else if(value!.length<10){
//                           return "Please enter 10 digit number";
//                         }
//                         else {
//                           return null;
//                         }
//                       },
//                       decoration:  InputDecoration(
//                         prefixText: "+91 ",
//                         labelText: "+91 Mobile",
//                         labelStyle: TextStyle(fontFamily: "Montserrat",fontSize: 15,color: Colors.grey),
//                         border: OutlineInputBorder(),
//                         enabledBorder: OutlineInputBorder(),
//                         disabledBorder: OutlineInputBorder(),
//                         errorBorder: OutlineInputBorder(),
//                       ),
//                       onChanged: (val){},
//                     ),
//                   ),),
//                 SizedBox(height: 2,),
//                 Container(
//                   margin: const EdgeInsets.only(left: 50,right: 50),
//                   width: 460,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Padding(
//                       padding: EdgeInsets.only(top: 20),
//                       child: InkWell(
//                         onTap: (){
//                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPages()));
//                         },
//                         child: Text("Back to Login",style: TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         backgroundColor: Colors.indigoAccent,
//                         minimumSize: const Size(290, 60),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8)
//                         )
//                     ),
//                     onPressed: () {
//                       if(_formKey.currentState!.validate()) {
//                         print('Sent Successfill');
//                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Otpverification()));
//                       }
//                       _formKey.currentState!.save();
//                     },child: Text("Send an OTP",style: TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.bold,fontSize: 15),)
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
