import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/views/screens/GeoTagWithPicture/geo_picture_item.dart';

import '../../../constants/app_colors.dart';
import '../../../services/DatabaseHelper/database_helper.dart';
import '../../widgets/app_bar.dart';

class GeoTagWithPictureList extends StatefulWidget {
  const GeoTagWithPictureList({super.key});

  @override
  State<GeoTagWithPictureList> createState() => _GeoTagWithPictureListState();
}

class _GeoTagWithPictureListState extends State<GeoTagWithPictureList> {
  List<Map<String, dynamic>> geoPictures = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPictures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.greyHundred,
        appBar: MyAppBar.buildAppBar('GeoTag Picture List', true),
        body: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: geoPictures.length,
            itemBuilder: (context, index) {
              return GeoPictureItem(
                profile: geoPictures[index],
              );
            }));
  }

  Future<void> _fetchPictures() async {
    isLoading = true;
    geoPictures = await DatabaseHelper().getUGeoPictures();
    setState(() {});
    isLoading = false;
  }
}
