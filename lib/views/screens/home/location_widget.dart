import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class CustomLocationWidget extends StatefulWidget {
  final String labelText;
  final bool isRequired;
  final double? latitude;
  final double? longitude;
  final String initialAddress;
  final bool isLoading;
  final Color backgroundColor;
  final Color refreshIconColor;
  final Color progressIndicatorColor;
  final double mapHeight;
  final double mapWidth;
  final Function() onRefresh;
  final Function(LatLng) onMapTap;

  const CustomLocationWidget({
    Key? key,
    required this.labelText,
    required this.isRequired,
    required this.latitude,
    required this.longitude,
    required this.initialAddress,
    this.isLoading = false,
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.refreshIconColor = Colors.black,
    this.progressIndicatorColor = Colors.blue,
    this.mapHeight = 200.0,
    this.mapWidth = 300.0,
    required this.onRefresh,
    required this.onMapTap,
  }) : super(key: key);

  @override
  _CustomLocationWidgetState createState() => _CustomLocationWidgetState();
}

class _CustomLocationWidgetState extends State<CustomLocationWidget> {
  String currentAddress = '';
  bool _isSatellite = false;


  @override
  void initState() {
    super.initState();
    currentAddress = widget.initialAddress;
  }

  @override
  Widget build(BuildContext context) {
    return widget.latitude != null && widget.longitude != null
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.labelText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 5), // Space between text and image
            widget.isRequired == true
                ? Image.asset(
              'assets/images/asterisk.png', // Path to your asset
              width: 8, // Set the width of the image
              height: 8, // Set the height of the image
            )
                : SizedBox.shrink(),
            Spacer(), // This will push the next widget to the end
            widget.isLoading
                ? SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: widget.progressIndicatorColor,
              ),
            )
                : IconButton(
              icon: Icon(
                Icons.refresh,
                color: widget.refreshIconColor,
                size: 25,
              ),
              onPressed: widget.onRefresh,
            ),
          ],
        ),
            Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( widget.initialAddress.toString()),
              const SizedBox(height: 8),
           /*   Switch(
                value: _isSatellite,
                onChanged: (value) {
                  setState(() {
                    _isSatellite = value;
                  });
                },
              ),*/
              Container(
                width: widget.mapWidth,
                height: widget.mapHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(widget.latitude!, widget.longitude!),
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) async {
                        widget.onMapTap(point);
                        final placemarks = await placemarkFromCoordinates(
                          point.latitude,
                          point.longitude,
                        );
                        setState(() {
                          currentAddress =
                          '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea} - ${placemarks.first.postalCode}, ${placemarks.first.country}.';
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate://_isSatellite ? "http://ecn.t{switch:a,b,c}.tiles.virtualearth.net/tiles/a{quadkey}.jpeg?g=1":
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",// "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                       // subdomains: ['0', '1', '2', '3'],
                        userAgentPackageName: "com.example.myprofile",
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point:
                            LatLng(widget.latitude!, widget.longitude!),
                            width: 50.0,
                            height: 50.0,
                            child:  Icon(
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
            ],
                  ),
                ),
          ],
        )
        : const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }
}
