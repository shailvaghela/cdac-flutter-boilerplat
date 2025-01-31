// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/utils/camera_utils.dart';
import 'package:flutter_demo/services/MasterDataService/master_data_service.dart';
import 'package:flutter_demo/views/screens/home/profile_photo_widget.dart';
import 'package:flutter_demo/views/widgets/custom_char_count_text_field_container.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../services/DatabaseHelper/database_helper.dart';
import '../../../services/EncryptionService/encryption_service.dart';
import '../../../utils/toast_util.dart';
import '../../../viewmodels/MasterData/masterdata_viewmodel.dart';
import '../../../viewmodels/permission_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_help_dialog.dart';
import '../../widgets/custom_text_field_container.dart';
import '../../widgets/custom_text_icon_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_confirmation_dialog.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_gender_selector.dart';
import '../../widgets/dropdown_searchable_widget.dart';
import '../BottomNavBar/bottom_navigation_home.dart';
import 'location_widget.dart';
import 'note_widget.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;

  const HomeScreen({super.key, this.userProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final masterDataService = MasterData();

  final _formKey = GlobalKey<FormState>();
  final EncryptionService _encryptionService = EncryptionService();

  // ignore: prefer_typing_uninitialized_variables
  var screenHeight, screenWidth;

  File? profilePic;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  DateTime? selectedDate;

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  String selectedGender = 'Male';

  String education = 'Bachelor\'s';
  final List<String> educationOptions = [
    'High School',
    'Diploma',
    'Bachelor\'s',
    'Master\'s',
    'PhD'
  ];

  List<String> states = [];
  List<String> districts = [];

  bool isLoading = false;
  double? positionLat;
  double? positionLong;
  String currentLocationAddress = '';
  String location = 'Unknown';

  @override
  void initState() {
    super.initState();
    if (widget.userProfile != null) {
      // _loadExistingData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final permissionProvider =
            Provider.of<PermissionProvider>(context, listen: false);
        _loadExistingData(permissionProvider);
      });
    } else {
      // _getLocation();
      // }
      // Schedule the fetchCurrentLocation call after the first frame is drawn
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final permissionProvider =
            Provider.of<PermissionProvider>(context, listen: false);
        /* permissionProvider.profilePic = null;
        permissionProvider.fetchCurrentLocation();
        permissionProvider.requestMicrophonePermission();
        permissionProvider.requestCameraPermission();*/

        permissionProvider.profilePic = null;

        // Request necessary permissions
        await permissionProvider.requestMicrophonePermission();
        await permissionProvider.requestCameraPermission();
        await permissionProvider.requestLocationPermission();

        // Fetch the current location
        permissionProvider.fetchCurrentLocation();
      });
    }

    // masterDataService.fetchMasterData("john_toe2", "district");
     final masterDataViewModel = context.read<MasterDataViewModel>();
    masterDataViewModel.insertData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final permissionProvider = Provider.of<PermissionProvider>(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        // Ensures UI adjusts with the keyboard
        backgroundColor: AppColors.greyHundred,
        appBar: MyAppBar.buildAppBar('User Profile Form', true),
        drawer: widget.userProfile != null ? null : const CustomDrawer(),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputCard(
                        screenHeight, screenWidth, permissionProvider),
                    SizedBox(height: screenHeight * 0.02),
                    _buildActionButtons(screenHeight, screenWidth),
                    // 2% of the screen height
                  ],
                ))));
  }

  Widget _buildInputCard(double screenHeight, double screenWidth,
      PermissionProvider permissionProvider) {
    debugPrint(
        "permissionProvider.profilePic----${permissionProvider.profilePic}");
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfilePhotoWidget(
            onTap: () async {
              final hasPermission =
                  await permissionProvider.requestLocationPermission();
              final hasPermissionCamera =
                  await permissionProvider.requestLocationPermission();
              final hasPermissionRecord =
                  await permissionProvider.requestLocationPermission();
              if (hasPermission && hasPermissionRecord && hasPermissionCamera) {
                // await permissionProvider.fetchCurrentLocation();
                _showImageSourceDialog(); // Call your image source dialog
              } else {
                _showPermissionDialog(); // Call your permission dialog
              }
            },
            profilePic: permissionProvider.profilePic,
          ),

          SizedBox(height: 16),

          NoteWidget(
              noteTextTitle: 'Note: ',
              noteText: 'All fields and photo are mandatory.'),
          //, Please fill in all the details carefully.
          SizedBox(height: 16),

          CustomTextField(
            labelText: 'First :',
            label: 'Enter First Name',
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            maxLength: 15,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your first name';
              }
              if (!RegExp(AppStrings.namePattern).hasMatch(value)) {
                return 'Enter a valid first name (letters, spaces, \'- allowed)';
              }
              return null;
            },
            isRequired: true,
            onChanged: (value) {
              debugPrint("$value");
              // You can perform additional actions on change if needed
            },
          ),

          CustomTextField(
            labelText: 'Middle Name:',
            label: 'Enter Middle Name',
            controller: _middleNameController,
            keyboardType: TextInputType.name,
            maxLength: 12,
            validator: null,
            isRequired: false,
          ),

          CustomTextField(
            labelText: 'Last Name:',
            label: 'Enter Last Name',
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            maxLength: 15,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your last name';
              }
              if (!RegExp(AppStrings.namePattern).hasMatch(value)) {
                return 'Enter a valid last name (letters, spaces, \'- allowed)';
              }
              return null;
            },
            isRequired: true,
          ),

          CustomTextField(
            labelText: 'Contact Number:',
            label: 'Enter Contact Number',
            controller: _contactController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your contact number';
              }
              // Validate the contact number format (10 to 15 digits)
              if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                return 'Please enter a valid contact number';
              }
              // Ensure the number does not contain the same digit repeated 10 times
              if (!RegExp(r'^(?!([0-9])\1+$)[0-9]{10}$').hasMatch(value)) {
                return 'Enter a valid contact number';
              }
              return null; // Valid contact number
            },
            isRequired: true,
            isNumberWithPrefix: true,
          ),

          CustomTextField(
            labelText: 'Date of Birth:',
            label: 'Enter Date of Birth',
            controller: _dobController,
            readOnly: true,
            onTap: () =>
                _selectDate(context, 18, 1950 /*, (DateTime.year - 60)*/),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your date of birth';
              }
              DateTime dob = DateFormat('dd/MM/yyyy').parse(value);
              final age = _calculateAge(dob);
              if (age < 18) {
                return 'You must be at least 18 years old.';
              }
              return null;
            },
            isRequired: true,
          ),

          CustomGenderSelector(
            labelText: 'Gender:',
            genderOptions: genderOptions,
            selectedGender: selectedGender,
            onGenderChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
            isRequired: true,
          ),

          FlutterDropdownSearch(
            labelText: 'Education:',
            hintText: "Please Select",
            textController: _educationController,
            items: educationOptions,
            dropdownHeight: 300,
            isRequired: true,
          ),

          FutureBuilder<List<String>>(
            future: fetchdata(), // Fetch the data asynchronously
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the data
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Show an error message if the data fetch failed
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                // When data is available, pass it to FlutterDropdownSearch
                return Column(
                  children: [
                    FlutterDropdownSearch(
                      labelText: 'State:',
                      hintText: "Please Select",
                      textController: _stateController,
                      items: snapshot.data!,
                      dropdownHeight: 300,
                      isRequired: true,
                      onChanged: (value) async {
                        if (value != null) {
                          // Fetch the districts for the selected state
                          final viewModel = Provider.of<MasterDataViewModel>(context, listen: false);

                          // Fetch districts
                          List<String> fetchedDistricts = await viewModel.fetchDistricts(value);

                          // Use setState to update the UI
                          setState(() {
                            districts = fetchedDistricts;
                            _districtController.clear(); // Clear the district dropdown text
                          });
                        }
                      },
                    ),

                    // District dropdown
                    FlutterDropdownSearch(
                      labelText: 'District:',
                      hintText: "Please Select",
                      textController: _districtController,
                      items: districts.isEmpty ? [''] : districts, // Show a fallback empty option if districts is empty
                      dropdownHeight: 300,
                      isRequired: true,
                    ),

                  ],
                );
              } else {
                return Text('No data available');
              }
            },
          ),


          CustomCharCountTextField(
              labelText: 'Address:',
              label: 'Enter Address',
              controller: _addressController,
              maxLines: 3,
              maxLength: 255,
              keyboardType: TextInputType.streetAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your address';
                }
                if (!RegExp(AppStrings.addressPattern).hasMatch(value)) {
                  return 'Enter a valid address (letters, nums, ,.-/# allowed)';
                }
                if (value.length > 255) {
                  return 'Address cannot exceed 255 characters';
                }
                return null;
              },
              isRequired: true,
              onTapHelp: () => ShowCustomHelpDialog(
                    context: context,
                    title: AppStrings.addressTag,
                    content: AppStrings.addressHelpText,
                  )),

          CustomTextField(
            labelText: 'Pin Code:',
            label: 'Enter Pin Code',
            controller: _pinCodeController,
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your pin code';
              }
              // Validate the valid pin code format (0 to 8 digits)
              if (!RegExp(r'^[0-9]{0,9}$').hasMatch(value)) {
                return 'Please enter a valid pin code';
              }
              // Ensure the number does not contain the same digit repeated 8 times
              if (!RegExp(r'^(?!([0-9])\1+$)[0-9]{6}$').hasMatch(value)) {
                return 'Enter a valid pin code';
              }
              return null; // Valid contact number
            },
            isRequired: true,
          ),

          permissionProvider.isLoading
              ? CircularProgressIndicator()
              : CustomLocationWidget(
                  labelText: 'Current Location:',
                  isRequired: true,
                  latitude: permissionProvider.latitude,
                  longitude: permissionProvider.longitude,
                  initialAddress: permissionProvider.address.toString(),
                  isLoading: permissionProvider.isLoading,
                  mapHeight: screenHeight * 0.2,
                  mapWidth: screenWidth * 0.8,
                  onRefresh: () async {
                    await permissionProvider.fetchCurrentLocation();
                  },
                  onMapTap: (point) async {
                    await permissionProvider.setLocation(
                        point.latitude, point.longitude);
                  },
                ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    final permissionProvider =
        Provider.of<PermissionProvider>(context, listen: false);

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Choose image source'),
              actions: [
                CustomTextIconButton(
                  icon: Icons.camera,
                  label: 'Camera',
                  onPressed: () async {
                    await permissionProvider
                        .handleCameraAndMicrophonePermissions(context);
                    Navigator.pop(context); // Close the dialog
                  },
                  backgroundColor: Colors.blue[50],
                  textColor: Colors.blue,
                  iconColor: Colors.blue,
                ),
                CustomTextIconButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () async {
                    await permissionProvider.pickImageFromGallery(context);
                    Navigator.pop(context); // Close the dialog
                  },
                  backgroundColor: Colors.blue[50],
                  textColor: Colors.blue,
                  iconColor: Colors.blue,
                ),
              ]);
        });
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(
      BuildContext context, int previousYear, int startYear) async {
    DateTime today = DateTime.now();
    DateTime startYearsAgo = DateTime(startYear);
    DateTime lastDate =
        DateTime((today.year - previousYear), today.month, today.day);

    // Ensure that the initial date does not exceed the last date (2007)
    DateTime initialDate = today.isAfter(lastDate) ? lastDate : today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // Adjust initial date
      firstDate: startYearsAgo, // Start date: January 1, 1900
      lastDate: lastDate, // End date: December 31, 2007
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      });
    }
  }

  // ignore: unused_element
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint("serviceEnabled----$serviceEnabled");
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.best,
    ));

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (mounted) {
      setState(() {
        positionLat = position.latitude;
        positionLong = position.longitude;
        location = '${position.latitude}, ${position.longitude}';
        currentLocationAddress =
            '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea} - ${placemarks.first.postalCode}, ${placemarks.first.country}.';
        isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text(
            'Location permissions are required for this feature. Please enable them in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                openAppSettings();
                Navigator.pop(context);
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: CustomButton(
            icon: Icons.clear,
            label: 'Clear',
            onPressed: () {
              // Add clear form logic here
            },
            backgroundColor: Colors.red.shade500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            icon: Icons.save,
            label: widget.userProfile != null ? 'Update' : 'Save',
            onPressed: _saveForm,
            backgroundColor: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Future<void> _saveForm() async {
    final permissionProvider =
        Provider.of<PermissionProvider>(context, listen: false);

    if (permissionProvider.profilePic == null) {
      ToastUtil().showToastKeyBoard(
        context: context,
        message: "Please select profile picture",
      );
      // ToastUtil().showToast(context, "Please Choose Profile Picture",
      //     Icons.camera_alt_outlined, AppColors.toastBgColorRed);
    } else if (permissionProvider.latitude == null &&
        permissionProvider.longitude == null) {
      ToastUtil().showToastKeyBoard(
        context: context,
        message: "This is a generic toast!",
      );
      // ToastUtil().showToast(context, "Please wait, Current Location not found.",
      //     Icons.location_on_outlined, AppColors.toastBgColorRed);
    } else if (_formKey.currentState!.validate()) {
      _showSaveConfirmationDialog(context);
    }
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    showCustomConfirmationDialog(
      context: context,
      title: 'Are you sure?',
      content:
          'Do you really want to ${widget.userProfile != null ? 'update' : 'save'} the form?',
      icon: Icons.help_outline,
      backgroundColor: Colors.blue,
      iconColor: Colors.blue,
      onYesPressed: () async {
        final permissionProvider =
            Provider.of<PermissionProvider>(context, listen: false);
        CameraUtil.saveImageToDirectory(context);
        final database = DatabaseHelper();
        final userProfile = {
          'firstname': encryptString(_firstNameController.text),
          'middlename': haveValue(_middleNameController.text),
          'lastname': encryptString(_lastNameController.text),
          'dob': encryptString(_dobController.text),
          'contact': encryptString(_contactController.text),
          'gender': encryptString(selectedGender),
          'address': encryptString(_addressController.text),
          'pinCode': encryptString(_pinCodeController.text),
          'education': encryptString(_educationController.text),
          'state': encryptString(_stateController.text),
          'district': encryptString(_districtController.text),
          'profilePic': encryptString(permissionProvider.profilePic?.path),
          'latlong': encryptString(permissionProvider.location),
          'currentlocation': encryptString(permissionProvider.address),
        };

        debugPrint("userprofile---$userProfile");

        if (widget.userProfile != null) {
          // If editing, update the existing profile
          userProfile['id'] = widget.userProfile!['id']
              .toString(); // Include the ID for the update
          await database.updateUserProfile(userProfile);
          ToastUtil().showToast(context, "Profile Updated!", Icons.edit,
              AppColors.toastBgColorGreen);
        } else {
          // If new profile, insert it
          await database.insertUserProfile(userProfile);
          ToastUtil().showToast(context, "Profile Saved!", Icons.save,
              AppColors.toastBgColorGreen);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigationHome(
              initialIndex: 1,
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadExistingData(permissionProvider) async {
    final profile = widget.userProfile!;
    List<double> coordinates = decryptCoordinates(profile, 'latlong');
    debugPrint("coordinates_loadExist----$coordinates");
    double lat = coordinates[0];
    double long = coordinates[1];

    setState(() {
      _firstNameController.text = decryptString(profile, 'firstname');
      _middleNameController.text = decryptString(profile, 'middlename');
      _lastNameController.text = decryptString(profile, 'lastname');
      _dobController.text = decryptString(profile, 'dob');
      _contactController.text = decryptString(profile, 'contact');
      selectedGender = decryptString(profile, 'gender');
      _addressController.text = decryptString(profile, 'address');
      _pinCodeController.text = decryptString(profile, 'pinCode');
      _stateController.text = decryptString(profile, 'state');
      _districtController.text = decryptString(profile, 'district');
      _educationController.text = decryptString(profile, 'education');

      final profilePicPath = decryptString(profile, 'profilePic');
      if (profilePicPath.isNotEmpty) {
        permissionProvider.profilePic = File(profilePicPath);
      }
    });

    final placemarks = await placemarkFromCoordinates(
      lat,
      long,
    );
    if (mounted) {
      setState(() {
        positionLat = lat;
        positionLong = long;
        location = '$lat, $long';
        currentLocationAddress =
            '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea} - ${placemarks.first.postalCode}, ${placemarks.first.country}.';
      });
    }
  }

// Helper function for encryption
  String encryptString(String? value) {
    return _encryptionService.encrypt(value?.trim() ?? '');
  }

// Helper function for decryption
  String decryptString(Map<String, dynamic> profile, String key) {
    return _encryptionService.decrypt(profile[key]?.toString() ?? '');
  }

  // Helper function to decrypt and split coordinates
  List<double> decryptCoordinates(Map<String, dynamic> profile, String key) {
    final decrypted = decryptString(profile, key);
    final parts = decrypted.split(', ');
    return parts.length == 2
        ? [double.parse(parts[0]), double.parse(parts[1])]
        : [0.0, 0.0];
  }

  Future<void> fetchMasterData() async {
    final masterDataViewModel = context.read<MasterDataViewModel>();

/*
    userDetails['username']
*/

    // String? loginOperationResultMessage =
    //     await loginViewmodel.performLogin(_usernameController.text, _passwordController.text);

    if (kDebugMode) {
      log("Inside login screen");
      // log(loginOperationResultMessage!);
    }

    /* if (!loginOperationResultMessage!.toLowerCase().contains("success")) {
      ToastUtil().showToast(
        // ignore: use_build_context_synchronously
        context,
        loginOperationResultMessage,
        Icons.error_outline,
        AppColors.toastBgColorRed,
      );

      return;
    }
*/
    ToastUtil().showToast(
      context,
      'Successfully logged in',
      Icons.check_circle_outline,
      AppColors.toastBgColorGreen,
    );
    // Navigate to the home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const BottomNavigationHome(
                initialIndex: 0,
              )),
    );
  }

  Future<List<String>> fetchdata() async {
    final viewModel = Provider.of<MasterDataViewModel>(context, listen: false);

    // Await the result of fetchState()
    states = await viewModel.fetchState();

    return states;
  }


  Future<List<String>> fetchdistrict(value) async {
    final viewModel = Provider.of<MasterDataViewModel>(context, listen: false);

    // Await the result of fetchState()
    districts = await viewModel.fetchDistricts(value);

    return districts;
  }

  String haveValue(String value){
    if(value.isEmpty){
      return "";
    }
    else{
      return value;
    }
  }
}
