import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/custom_toast.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/logout/logout.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/features/auth/bloc/auth_bloc.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  static const String routeName = '/change-password';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final curController = TextEditingController();
  final newpassController = TextEditingController();
  final cpassController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AuthBloc _authBloc;

  bool isLoading = true;

  bool isShowNewPass = true;
  bool isShowConfirmPass = true;
  bool isShowCurrentPass = true;

  final FocusNode _currentPassFocusNode = FocusNode();
  final FocusNode _newPassFocusNode = FocusNode();
  final FocusNode _confirmPassFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  // authenticateChangePassword() {
  //   if (curController.text == '' && curController.text.isEmpty ||
  //       newpassController.text == '' && newpassController.text.isEmpty ||
  //       cpassController.text == '' && cpassController.text.isEmpty) {
  //     failedToast(context, 'Please fill required field');
  //   } else {

  //   }
  // }

  @override
  void dispose() {
    curController.dispose();
    newpassController.dispose();
    cpassController.dispose();
    _currentPassFocusNode.dispose();
    _newPassFocusNode.dispose();
    _confirmPassFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: InternetConnectionService().connectionStream,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return const NoInternetConnection(); // Show your offline UI
          }
          return Container(
            color: greyColor,
            child: Scaffold(
              backgroundColor: zBlack,
              appBar: AppBar(
                backgroundColor: appBarColor,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Form Container
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: kWhiteColor),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: curController,
                                  focusNode: _currentPassFocusNode,
                                  isShowPass: isShowCurrentPass,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password too short (min 6 chars)';
                                    }
                                    return null;
                                  },
                                  label: 'Current Password',
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: newpassController,
                                  focusNode: _newPassFocusNode,
                                  isShowPass: isShowNewPass,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password too short (min 6 chars)';
                                    }
                                    return null;
                                  },
                                  label: 'New Password',
                                ),
                                const SizedBox(height: 24),
                                _buildTextField(
                                  controller: cpassController,
                                  focusNode: _confirmPassFocusNode,
                                  isShowPass: isShowConfirmPass,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password too short (min 6 chars)';
                                    }
                                    return null;
                                  },
                                  label: 'Confirm Password',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Submit Button
                          BlocConsumer(
                            bloc: _authBloc,
                            listener: (context, state) {
                              if (state is AuthChangeUserPasswordSuccessState) {
                                if (state.changePasswordEntity.status == 1) {
                                  // Show success message first
                                  successToastMsg(
                                    context,
                                    state.changePasswordEntity.message
                                        .toString(),
                                  );
                                  // Then navigate after a short delay
                                  logoutUser(context);
                                } else {
                                  if (mounted) {
                                    // Check if widget is still mounted
                                    CustomToast.showSuccess(
                                      context,
                                      state.changePasswordEntity.message
                                          .toString(),
                                    );
                                  }
                                }
                              } else if (state
                                  is AuthChangePasswordFailedErrorState) {
                                if (mounted) {
                                  CustomToast.showError(
                                      context, state.error.toString());
                                  // Check if widget is still mounted
                                }
                              }
                            },
                            builder: (_, state) {
                              if (state is AuthLoadingState) {
                                return isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      )
                                    : Center(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: greyColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40,
                                                      vertical: 16),
                                              // elevation: 4,
                                              // shadowColor: Colors.black.withOpacity(0.3),
                                            ),
                                            child: const Text(
                                              'PROCESSING...',
                                            ).textStyleH1W(),
                                          ),
                                        ),
                                      );
                              }
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  width: MediaQuery.sizeOf(context).width,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final formState = _formKey.currentState;
                                      if (formState != null) {
                                        final isValid = formState.validate();

                                        if (curController.text.isEmpty) {
                                          FocusScope.of(context).requestFocus(
                                              _currentPassFocusNode);
                                        } else if (newpassController
                                            .text.isEmpty) {
                                          FocusScope.of(context)
                                              .requestFocus(_newPassFocusNode);
                                        } else if (cpassController
                                            .text.isEmpty) {
                                          FocusScope.of(context).requestFocus(
                                              _confirmPassFocusNode);
                                        }

                                        if (isValid) {
                                          _authBloc.add(
                                              AuthChangeUserPasswordEvent(
                                                  currentPass:
                                                      curController.text,
                                                  newPassword:
                                                      newpassController.text,
                                                  confirmPassword:
                                                      cpassController.text));
                                          isLoading = false;
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kGoldenBraunColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 16),
                                      // elevation: 4,
                                      // shadowColor: Colors.black.withOpacity(0.3),
                                    ),
                                    child: const Text(
                                      'CHANGE PASSWORD',
                                    ).textStyleH1W(),
                                  ),
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required FocusNode focusNode,
      required bool isShowPass,
      required FormFieldValidator validator}) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: zBlack),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 18,
          color: zBlack,
          fontWeight: FontWeight.w500,
          fontFamily: 'JetBrainsMono',
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isShowPass ? Icons.visibility_off : Icons.visibility,
            color: kGoldenBraunColor,
          ),
          onPressed: () {
            setState(() {
              if (label == 'Current Password') {
                isShowCurrentPass = !isShowCurrentPass;
              } else if (label == 'New Password') {
                isShowNewPass = !isShowNewPass;
              } else if (label == 'Confirm Password') {
                isShowConfirmPass = !isShowConfirmPass;
              }
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
      obscureText: isShowPass,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  void _handlePasswordChange() {
    String currentPassword = curController.text.trim();
    String newPassword = newpassController.text.trim();
    String confirmPassword = cpassController.text.trim();

    if (currentPassword.isEmpty) {
      _showErrorDialog('Please enter your current password.');
      return;
    }

    if (newPassword.isEmpty) {
      _showErrorDialog('Please enter a new password.');
      return;
    }

    if (newPassword.length < 8) {
      _showErrorDialog('New password must be at least 8 characters long.');
      return;
    }

    if (!RegExp(r'(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~])')
        .hasMatch(newPassword)) {
      _showErrorDialog(
          'New password must include uppercase, lowercase, number, and special character.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Passwords do not match.');
      return;
    }

    // Proceed with password change logic
    _showSuccessDialog('Password changed successfully.');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Success',
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
