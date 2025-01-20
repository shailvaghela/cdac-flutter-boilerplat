import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/views/screens/SearchScreen/profile_detail_row.dart';
import 'package:flutter_demo/views/screens/SearchScreen/profile_list_item.dart';
import 'package:flutter_demo/views/screens/SearchScreen/search_textfield.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../constants/app_colors.dart';
import '../../../services/DatabaseHelper/database_helper.dart';
import '../../../services/EncryptionService/encryption_service.dart';
import '../../../utils/toast_util.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_text_widget.dart';
import '../home/home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> userProfiles = [];
  List<Map<String, dynamic>> filteredProfiles = [];
  String searchQuery = '';
  bool isLoading = false;
  final EncryptionService _encryptionService = EncryptionService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyHundred,
        appBar: MyAppBar.buildAppBar('User Profiles', false),
        body: Column(children: [
          SearchTextField(
            labelText: 'Search profiles...',
            onChanged: (value) {
              debugPrint('Search query: $value'); // Handle the search input
            },
          ),
          Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: AppColors.circularProgressIndicatorBgColor,
                    ))
                  : filteredProfiles.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/nodata_preview.png',
                              width: 200,
                            ),
                            CustomTextWidget(
                              text: 'No profiles found.',
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: filteredProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = filteredProfiles[index];
                            return ProfileListItem(
                              profile: filteredProfiles[index],
                              // Pass a single profile
                              encryptionService: _encryptionService,
                              onEditProfile: _editProfile,
                              onViewProfile: (p0) {
                                _viewProfile(context, filteredProfiles[index]);
                              },
                              onDeleteProfile: (p0) {
                                _deleteProfile(
                                    context, filteredProfiles[index]);
                              },
                              /* profile['id'],
                                _encryptionService
                                    .decrypt(profile['name']
                                        .toString())
                                    .toString(),*/
                              //  ),
                              onShowMapDialog: _showMapDialog,
                            );
                          }))
        ]));
  }

  Future<void> _fetchUserProfiles() async {
    isLoading = true;
    userProfiles = await DatabaseHelper().getUserProfiles();
    setState(() {
      filteredProfiles = userProfiles; // Initialize filtered profiles
      isLoading = false;
    });
  }

  void _editProfile(Map<String, dynamic> profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(userProfile: profile), // Pass the profile data
      ),
    );
  }

  void _viewProfile(BuildContext context, Map<String, dynamic> profile) {
    debugPrint("viewProfile---$profile");

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjust height to content

                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: decryptString(
                                            profile, 'profilePic')
                                        .isNotEmpty
                                    ? FileImage(File(
                                        decryptString(profile, 'profilePic')))
                                    : const AssetImage(
                                            'assets/images/default_profile.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      decryptString(profile, 'name'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'DOB: ${decryptString(profile, 'dob')}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30, thickness: 1),

                          // Profile Details
                          ProfileDetailRow(
                            label: 'Contact',
                            value: decryptString(profile, 'contact'),
                          ),
                          ProfileDetailRow(
                            label: 'Gender',
                            value: decryptString(profile, 'gender'),
                          ),
                          ProfileDetailRow(
                            label: 'Address',
                            value: decryptString(profile, 'address'),
                          ),
                          ProfileDetailRow(
                            label: 'Education',
                            value: decryptString(profile, 'education'),
                          ),
                          ProfileDetailRow(
                            label: 'Location',
                            value:
                                '${decryptString(profile, 'currentlocation')} (${decryptString(profile, 'latlong')})',
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Generate/Download PDF Button
                  ElevatedButton.icon(
                    onPressed: () => _generateAndDownloadPDF(context, profile),
                    icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
                    label: CustomTextWidget(
                      text: 'Generate PDF',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close Button
            Positioned(
              right: 16,
              top: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProfile(
      BuildContext context, Map<String, dynamic> profile) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    // Space for top-right cancel button
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Confirm Deletion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to delete this profile: "${decryptString(profile, 'name')}"?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await DatabaseHelper().deleteUserProfile(
                                  int.parse(profile['id']
                                      .toString())); // Delete the profile
                              Navigator.of(context).pop(); // Close the dialog
                              _fetchUserProfiles(); // Refresh the list after deletion
                              ToastUtil().showToast(context, "Profile Deleted!",
                                  Icons.delete, AppColors.toastBgColorRed);
                            } catch (e) {
                              ToastUtil().showToast(context, e.toString(),
                                  Icons.error, AppColors.toastBgColorRed);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Delete',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMapDialog(
      BuildContext context, double lat, double long, String location) {
    // Implement show map dialog logic
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Map Container
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, long),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: "com.example.myprofile",
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, long),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '$location',
                  // style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.center,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
              // Cancel Button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    // padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this helper function for decryption
  String decryptString(Map<String, dynamic> profile, String key) {
    return _encryptionService.decrypt(profile[key]?.toString() ?? '') ??
        'Not Provided';
  }

  Future<void> _generateAndDownloadPDF(
      BuildContext context, Map<String, dynamic> profile) async {
    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;

    // Fonts for styling
    final PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont headerFont =
        PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 18);

    // Title text
    const String title = 'Profile Information';
    final Size titleSize = titleFont.measureString(title);
    final double pageWidth = page.getClientSize().width;

    // Center the title horizontally
    final double xTitlePosition = (pageWidth - titleSize.width) / 2;

    // Draw the title
    graphics.drawString(
      title,
      titleFont,
      bounds:
          Rect.fromLTWH(xTitlePosition, 10, titleSize.width, titleSize.height),
    );

    // Draw profile picture on the right side
    const double imageSize = 100;
    final double imageXPosition = pageWidth - imageSize - 20; // Right-aligned
    const double imageYPosition = 50;

    String profilePicPath = decryptString(profile, 'profilePic');
    if (profilePicPath.isNotEmpty && File(profilePicPath).existsSync()) {
      final PdfBitmap image = PdfBitmap(File(profilePicPath).readAsBytesSync());
      graphics.drawImage(image,
          Rect.fromLTWH(imageXPosition, imageYPosition, imageSize, imageSize));
    } else {
      // Fallback text for missing image
      graphics.drawString(
        'No Profile Picture',
        contentFont,
        bounds: Rect.fromLTWH(
            imageXPosition, imageYPosition + (imageSize / 2), imageSize, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    }

    // Table start position
    const double tableStartY = 50;
    const double columnWidth = 150;
    const double rowHeight = 30;

    // Table headers
    final List<String> headers = ['Field', 'Value'];
    final List<List<String>> rows = [
      ['Name', decryptString(profile, 'name')],
      ['DOB', decryptString(profile, 'dob')],
      ['Contact', decryptString(profile, 'contact')],
      ['Gender', decryptString(profile, 'gender')],
      ['Address', decryptString(profile, 'address')],
      ['Education', decryptString(profile, 'education')],
      [
        'Location',
        '${decryptString(profile, 'currentlocation')} (${decryptString(profile, 'latlong')})'
      ],
    ];

    // Draw table headers
    double currentY = tableStartY;
    for (int i = 0; i < headers.length; i++) {
      graphics.drawString(
        headers[i],
        headerFont,
        bounds: Rect.fromLTWH(
            i * columnWidth + 20, currentY, columnWidth, rowHeight),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
    }

    // Draw table rows
    currentY += rowHeight;
    for (final row in rows) {
      for (int i = 0; i < row.length; i++) {
        graphics.drawString(
          row[i],
          contentFont,
          bounds: Rect.fromLTWH(
              i * columnWidth + 20, currentY, columnWidth, rowHeight),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            wordWrap: PdfWordWrapType.word,
          ),
        );
      }
      currentY += rowHeight;
    }

    // Save and open the PDF
    Directory output = await getApplicationDocumentsDirectory();
    String fileName = 'profile_info_${decryptString(profile, 'name')}.pdf';
    String filePath = '${output.path}/$fileName';
    final List<int> bytes = await document.save();
    File(filePath).writeAsBytes(bytes);
    document.dispose();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at: $filePath')),
    );

    final result = await OpenFile.open(filePath);
    debugPrint("msg---> ${result.message}");
    if (result.message != "Success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF: ${result.message}')),
      );
    }
  }
}
