import 'dart:developer';

import 'package:flutter/foundation.dart';
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
  late LatLng markerPosition; // Tracks marker and circle position
  final double allowedRadius = 500; // Radius in meters
  late LatLng initialPosition;
  final Distance distanceCalculator = const Distance();

  @override
  void initState() {
    super.initState();
    // currentAddress = widget.initialAddress;
    loadLatLongDataOnInit();
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
                    Text(widget.initialAddress.toString()),
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
                            initialCenter:
                                LatLng(widget.latitude!, widget.longitude!),
                            initialZoom: 15.0,
                            maxZoom: 18.0,
                            onTap: (tapPosition, point) async {
                              var oldPosition = markerPosition;
                              var newPosition = point;
                              if(markerPosition.longitude != point.longitude && markerPosition.latitude != point.latitude){
                                // if(kDebugMode){
                                //   log("old and new position are different");
                                // }
                                final distance = distanceCalculator.as(LengthUnit.Meter, newPosition, oldPosition);
                                // if(kDebugMode){
                                //   log("distance b/w $oldPosition and $newPosition = $distance");
                                // }
                                if(distance >= 0){
                                  if(distance <= allowedRadius){
                                    // if(kDebugMode){
                                    //   log("distance in allowed Radius $allowedRadius");
                                    // }
                                    final placemarks = await placemarkFromCoordinates(
                                      point.latitude,
                                      point.longitude,
                                    );

                                    // if(kDebugMode){
                                    //   log("before state update");
                                    //   log("$markerPosition");
                                    //   log(currentAddress);
                                    // }
                                    setState(() {
                                      markerPosition = LatLng(point.latitude, point.longitude);
                                      currentAddress =
                                      '${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea} - ${placemarks.first.postalCode}, ${placemarks.first.country}.';
                                    });
                                    // if(kDebugMode){
                                    //   log("after state update");
                                    //   log("$markerPosition");
                                    //   log("$currentAddress");
                                    // }
                                    widget.onMapTap(point);

                                  }
                                }else{
                                  var absoluteDistance = 0 - distance;
                                  if(absoluteDistance <= allowedRadius){

                                  }
                                }
                              }else{
                                // if(kDebugMode){
                                //   log("Placement at same location");
                                // }
                                  // Optional: Show a message if the tapped point is outside the radius
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Point is outside the allowed radius."),
                                    ),
                                  );
                              }
                            },
                            interactionOptions: InteractionOptions(
                              enableMultiFingerGestureRace: true,
                              pinchMoveWinGestures: 0,
                              rotationWinGestures: 0,
                              // debugMultiFingerGestureWinner: true,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: //_isSatellite ? "http://ecn.t{switch:a,b,c}.tiles.virtualearth.net/tiles/a{quadkey}.jpeg?g=1":
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              // "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              // subdomains: ['0', '1', '2', '3'],
                              userAgentPackageName: "com.example.myprofile",
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: markerPosition,
                                  width: 50.0,
                                  height: 50.0,
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                            CircleLayer(
                              circles: [
                                // CircleMarker(
                                //   point: markerPosition,
                                //   // Circle follows marker
                                //   radius: 100,
                                //   // Optional visual radius for the marker
                                //   useRadiusInMeter: true,
                                //   color: Colors.blue.withOpacity(0.2),
                                //   borderColor: Colors.blue,
                                //   borderStrokeWidth: 1.5,
                                // ),
                                CircleMarker(
                                  point: initialPosition,
                                  // Original center
                                  radius: allowedRadius,
                                  useRadiusInMeter: true,
                                  color: Colors.blue.withOpacity(0.09),
                                  borderColor: Colors.black,
                                  borderStrokeWidth: 0.5,
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

  void loadLatLongDataOnInit() {
    try {
      // Safely parse latitude and longitude
      final double lat = double.parse(widget.latitude?.toString() ?? '') ?? 0.0;
      final double lng =
          double.parse(widget.longitude?.toString() ?? '') ?? 0.0;
      setState(() {
        // Set the marker position if values are valid
        markerPosition = LatLng(lat, lng);
        currentAddress = widget.initialAddress;
        initialPosition = LatLng(lat, lng);
      });

      debugPrint("markerPosition: $markerPosition");
      if(kDebugMode){
        log("Initial Marker Position $initialPosition");
      }
    } catch (e) {
      // Handle parsing error
      debugPrint("Error parsing latitude or longitude: $e");
      markerPosition = LatLng(0.0, 0.0); // Default to (0,0) if parsing fails
    }
  }
}
