import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/extensions/textstyle.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

class LodgeComplaintScreen extends StatefulWidget {
  const LodgeComplaintScreen({super.key});
  static const String routeName = '/ledge-complaint';

  @override
  State<LodgeComplaintScreen> createState() => _LodgeComplaintScreenState();
}

class _LodgeComplaintScreenState extends State<LodgeComplaintScreen>
    with SingleTickerProviderStateMixin {
  final _subjectController = TextEditingController();
  final _complaintController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late ProfileBloc _profileBloc;

  bool flag = true;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _complaintController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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
              appBar: customAppBarWithTitle(
                context: context,
                title: 'Complaint',
                isShowNotify: true,
              ),
              body: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Form Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _subjectController,
                                label: 'Subject',
                                icon: Icons.message,
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _complaintController,
                                label: 'Complaint',
                                maxLines: 5,
                                icon: Icons.note,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Submit Button
                        BlocConsumer(
                          bloc: _profileBloc,
                          listener: (context, state) {
                            if (state is LedgeComplaintLoadedSuccessState) {
                              if (state.ledgeComplaintEntity.status == 1) {
                                _showSuccessDialog(
                                  state.ledgeComplaintEntity.message!,
                                );
                              }
                            }
                          },
                          builder: (context, state) {
                            if (state is ProfileLoadingState) {
                              return flag
                                  ? const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : Center(
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kGoldenBraunColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 16,
                                            ),
                                          ),
                                          child: const Text(
                                            'SUBMITTING...',
                                          ).textStyleH1W(),
                                        ),
                                      ),
                                    );
                            }
                            if (state is LedgeComplaintFailedErrorState) {
                              return Center(
                                child: Text(
                                  state.error,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }
                            return Center(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _profileBloc.add(
                                      LedgeUserComplaintEvent(
                                        subject: _subjectController.text.trim(),
                                        complaint: _complaintController.text
                                            .trim(),
                                      ),
                                    );
                                    flag = false; // Reset flag for loading
                                    _subjectController.clear();
                                    _complaintController.clear();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kGoldenBraunColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('SUBMIT').textStyleH1W(),
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
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: zBlack),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 18,
          color: zBlack,
          fontWeight: FontWeight.w500,
          fontFamily: FontFamily.globalFontFamily,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(.3),
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
        suffixIcon: Icon(icon, color: zBlack),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
          style: TextStyle(
            color: Colors.greenAccent,
            fontFamily: FontFamily.globalFontFamily,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: FontFamily.globalFontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.blueAccent,
                fontFamily: FontFamily.globalFontFamily,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
