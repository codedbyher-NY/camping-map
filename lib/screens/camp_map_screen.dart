import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:camping_app/models/camp_site.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class CampMapScreen extends StatefulWidget {
  final List<CampSite> campsites;
  final CampSite selectedCampSite;
  final Completer<GoogleMapController> _completer = Completer();

  CampMapScreen({
    super.key,
    required this.campsites,
    required this.selectedCampSite,
  });

  @override
  State<CampMapScreen> createState() => _CampMapScreenState();
}

class _CampMapScreenState extends State<CampMapScreen> {
  late Set<Marker> markers;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    print('campsites.length : ${widget.campsites.length}');
    print('selected camp : ${widget.selectedCampSite.geoLocation.lat}${widget.selectedCampSite.geoLocation.long}');
    markers = widget.campsites.map((camp) {
      return Marker(
        markerId: MarkerId(camp.label),
        position: LatLng(camp.geoLocation.lat, camp.geoLocation.long),
        infoWindow: InfoWindow(
          title: camp.label,
          snippet: 'Price: \$${camp.pricePerNight}',
        ),
      );
    }).toSet();
    print('markers length : ${markers.length}');

    return Scaffold(
      appBar: AppBar(title: const Text('Campsites Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.selectedCampSite.geoLocation.lat, widget.selectedCampSite.geoLocation.long),
          zoom: 14,
        ),
        markers: markers,
        mapType: MapType.normal,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    widget._completer.complete(controller);
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        print("Location permission denied");
      }
    }
  }
}
