import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:suproxu/core/service/connectivity/connectivity_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/features/auth/login/loginPage.dart';


class Setpassword extends StatefulWidget {
  const Setpassword({super.key});

  @override
  State<Setpassword> createState() => _SetpasswordState();
}

class _SetpasswordState extends State<Setpassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();
  bool isShowPass = true;
  bool isShowConfirm = true;

  @override
  Widget build(BuildContext context) {
     final connectivity = context.watch<ConnectivityService>();
    return connectivity.isConnected ? Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      body: SafeArea(
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Column(
                  children: [
                   

                    Padding(
                      padding:
                          const EdgeInsets.only(top: 40.0, left: 50, right: 50),
                      child: _buildFormFields("New Password"),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20.0, left: 50, right: 50),
                      child: SizedBox(
                        width: 460.0,
                        child: TextFormField(
                          controller: _passController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          obscureText: isShowConfirm,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter a valid password";
                            } else if (value.length < 8) {
                              return "Please enter at least 8 characters";
                            } else if (value != _passController.text) {
                              return "Passwords do not match";
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            label: const Text("Confirm Password"),
                            labelStyle: const TextStyle(
                                fontSize: 18, color: Colors.white),
                            // filled: true,
                            // fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2.0),
                            ),
                            suffixIcon: InkWell(
                              child: Icon(
                                isShowConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Colors.white,
                              ),
                              onTap: () {
                                setState(() {
                                  isShowConfirm = !isShowConfirm;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        // minimumSize: const Size(290, 60),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(50),
                        // ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 83, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print('Password updated successfully');
                        context.pushNamed(  LoginPages.routeName);
                        }
                      },
                      child: const Text(
                        "Update Password",
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
        ),
   
    ): const NoInternetConnection();
  }

  Widget _buildFormFields(String labeltext, {FocusNode? focus}) {
    return SizedBox(
      width: 460.0,
      child:
       
          TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: _confirmpassController,
        keyboardType: TextInputType.emailAddress,
        obscureText: isShowPass,
        focusNode: focus,
        validator: (value) {
          if (value!.isEmpty) {
            return "Please enter a valid password";
          } else if (value.length < 8) {
            return "Please enter at least 8 characters";
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          label: const Text("New Password"),
          labelStyle: const TextStyle(fontSize: 18, color: Colors.white),
          // filled: true,
          // fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          suffixIcon: InkWell(
            child: Icon(
              isShowPass ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: Colors.white,
            ),
            onTap: () {
              setState(() {
                isShowPass = !isShowPass;
              });
            },
          ),
        ),
      ),
    );
  }
}



