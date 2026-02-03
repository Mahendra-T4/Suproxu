import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:suproxu/Assets/font_family.dart';
import 'package:suproxu/core/constants/color.dart';
import 'package:suproxu/core/constants/widget/toast.dart';
import 'package:suproxu/core/service/Auth/auto_logout.dart';
import 'package:suproxu/core/service/Auth/user_validation.dart';

import 'package:suproxu/core/service/connectivity/internet_connection_service.dart';
import 'package:suproxu/core/service/page/not_connected.dart';
import 'package:suproxu/core/widgets/app_bar.dart';
import 'package:suproxu/features/navbar/profile/bloc/profile_bloc.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});
  static const String routeName = '/deposit-screen';

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  late ProfileBloc _profileBloc;
  File? _selectedFiles;
  final TextEditingController _transactionDateController =
      TextEditingController();
  final _amountController = TextEditingController();
  final _utrNumberController = TextEditingController();
  final _noteController = TextEditingController();

  bool isLoading = true;
  Timer? _validationTimer;
  StreamSubscription<void>? _logoutSub;

  @override
  void initState() {
    _profileBloc = ProfileBloc();
    if (!mounted) return;
    // Ensure autoLogoutUser is imported from core/logout/logout.dart
    autoLogoutUser(context, mounted);
    _profileBloc.add(FetchOwnerBankDetailsEvent());
    _validationTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!mounted) return;
      try {
        await AuthService().validateAndLogout(context);
      } catch (e) {
        debugPrint('Notification auth validation error: $e');
      }
    });
    // Subscribe to global logout events to cleanup immediately
    _logoutSub = AuthService().onLogout.listen((_) {
      _validationTimer?.cancel();
      debugPrint('Notification: handled global logout cleanup');
    });

    super.initState();
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _logoutSub?.cancel();
    super.dispose();
  }

  transRequestVerify() {
    if (_amountController.text.isEmpty) {
      waringToast(context, 'Please enter amount');
      return;
    }
    if (_utrNumberController.text.isEmpty) {
      waringToast(context, 'Please enter UTR number');
      return;
    }
    if (_transactionDateController.text.isEmpty) {
      waringToast(context, 'Please select transaction date');
      return;
    }

    // Make API call without requiring the file
    _profileBloc.add(
      MakeTransactionRequestFromServerEvent(
        utrNumber: _utrNumberController.text,
        transDate: _transactionDateController.text,
        transAmount: _amountController.text,
        file: null, // Make file parameter null by default
        context: context,
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'docx', 'xlsx'],
      );

      if (result == null) return;

      final file = result.files.first;
      if (file.path == null) return;

      setState(() {
        _selectedFiles = File(file.path!);
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File selected: ${file.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _transactionDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
      print('Date =>> $_transactionDateController');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                title: 'Deposit',
                isShowNotify: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05, // Responsive padding
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _amountController,
                          maxLines: 1,
                          style: const TextStyle(
                            color: zBlack,
                            fontFamily: FontFamily.globalFontFamily,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: const TextStyle(
                              color: zBlack,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.globalFontFamily,
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.credit_card_outlined,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        TextField(
                          controller: _utrNumberController,
                          maxLines: 1,
                          style: const TextStyle(
                            color: zBlack,
                            fontFamily: FontFamily.globalFontFamily,
                          ),
                          decoration: InputDecoration(
                            labelText: 'UTR Number',
                            labelStyle: const TextStyle(
                              color: zBlack,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.globalFontFamily,
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.numbers,
                              color: zBlack,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),
                        TextField(
                          controller: _transactionDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          style: const TextStyle(
                            color: zBlack,
                            fontFamily: FontFamily.globalFontFamily,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Transaction Date',
                            labelStyle: const TextStyle(
                              color: zBlack,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.globalFontFamily,
                            ),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.date_range,
                              color: zBlack,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Add Attachment',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: FontFamily.globalFontFamily,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Display Selected Files
                        if (_selectedFiles != null)
                          Card(
                            color: Colors.grey.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: _getFileIcon(_selectedFiles!.path),
                              title: Text(
                                _selectedFiles!.path.split('/').last,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedFiles = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        SizedBox(height: screenHeight * 0.05),
                        BlocConsumer(
                          bloc: _profileBloc,
                          listener: (context, state) {
                            if (state is TransactionRequestLoadedSuccessState) {
                              successToastMsg(
                                context,
                                state.transRequestEntity.message.toString(),
                              );

                              // Clear form after successful submission
                              setState(() {
                                _amountController.clear();
                                _utrNumberController.clear();
                                _transactionDateController.clear();
                                _selectedFiles = null;
                              });
                            }
                            if (state is TransactionRequestFailedErrorState) {
                              Center(child: Text(state.error));
                            }
                          },
                          builder: (context, state) {
                            if (state is ProfileLoadingState) {
                              return isLoading
                                  ? const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : Center(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        width: MediaQuery.sizeOf(context).width,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 15,
                                            ),
                                            backgroundColor: kGoldenBraunColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            // elevation: 8,
                                            // shadowColor: Colors.green.shade200,
                                          ),
                                          child: Text(
                                            'PROCESSING...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: kWhiteColor,
                                              fontFamily:
                                                  FontFamily.globalFontFamily,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            }
                            return Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_amountController.text.isEmpty) {
                                    waringToast(context, 'Please enter amount');
                                    return;
                                  }
                                  if (_utrNumberController.text.isEmpty) {
                                    waringToast(
                                      context,
                                      'Please enter UTR number',
                                    );
                                    return;
                                  }
                                  if (_transactionDateController.text.isEmpty) {
                                    waringToast(
                                      context,
                                      'Please select transaction date',
                                    );
                                    return;
                                  }

                                  // if (_selectedFiles == null) {
                                  //   waringToast(context,
                                  //       'Please add Attachment File');
                                  //   return;
                                  // }

                                  // Don't use null coalescing when already null
                                  _profileBloc.add(
                                    MakeTransactionRequestFromServerEvent(
                                      utrNumber: _utrNumberController.text,
                                      transDate:
                                          _transactionDateController.text,
                                      transAmount: _amountController.text,
                                      file:
                                          _selectedFiles, // File is already nullable
                                      context: context,
                                    ),
                                  );
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.35,
                                    vertical: 15,
                                  ),
                                  backgroundColor: kGoldenBraunColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  // elevation: 8,
                                  // shadowColor: Colors.green.shade200,
                                ),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: kWhiteColor,
                                    fontFamily: FontFamily.globalFontFamily,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => qrCodeWidget(context),
                    isScrollControlled: true,
                  );
                },
                backgroundColor: Colors.green.shade600,
                child: const Icon(Icons.qr_code, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget qrCodeWidget(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder(
        bloc: _profileBloc,
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (ProfileLoadingState):
              return const Center(child: CircularProgressIndicator());
            case const (FetchOwnerBankDetailsSuccessStatus):
              final bankDetails =
                  (state as FetchOwnerBankDetailsSuccessStatus).bankDetails;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with subtle shadow
                    Text(
                      "Bank Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kGoldenBraunColor,
                        fontFamily: FontFamily.globalFontFamily,
                        shadows: const [
                          Shadow(
                            color: Colors.black12,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // QR Code with a decorative container
                    Container(
                      child: ClipRRect(
                        // borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          bankDetails.bankRecord!.qrCode.toString(),
                          fit: BoxFit.cover,
                          height: 160,
                          width: 160,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bank details with better typography
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bank Name: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              bankDetails.bankRecord!.bankName.toString(),
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bank Holder Name: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              bankDetails.bankRecord!.accountHolder.toString(),
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Account Number: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              bankDetails.bankRecord!.accountNumber.toString(),
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'IFSC: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              bankDetails.bankRecord!.ifscCode.toString(),
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                height: 1.5, // Line spacing
                                fontFamily: FontFamily
                                    .globalFontFamily, // Optional: Use a clean font
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Text(
                        //       'Bank ID: ',
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         color: Colors.green,
                        //         fontWeight: FontWeight.w600,
                        //         height: 1.5, // Line spacing
                        //         fontFamily:
                        //             'JetBrainsMono', // Optional: Use a clean font
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //     Text(
                        //       bankDetails.bankRecord!.bankID.toString(),
                        //       style: const TextStyle(
                        //         fontSize: 17,
                        //         color: Colors.black87,
                        //         fontWeight: FontWeight.w600,
                        //         height: 1.5, // Line spacing
                        //         fontFamily:
                        //             'JetBrainsMono', // Optional: Use a clean font
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Fancy close button
                  ],
                ),
              );
            case const (FetchOwnerBankDetailsFailedStatus):
              return Center(
                child: Text(
                  'Failed to load bank details',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                ),
              );
            default:
              return const SizedBox.shrink(); // Return an empty widget if no state matches
          }
        },
      ),
    );
  }

  Widget _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Icon(Icons.image, color: Colors.green);
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }
}
