import 'dart:async';
import 'package:camping_app/models/camp_item_marker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camping_app/models/camp_site.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campsitesProvider = StateProvider<List<CampSite>>((ref) => []);

final clusterItemsProvider = Provider<List<CampItemMarker>>((ref) {
  final camps = ref.watch(campsitesProvider);
  return camps
      .map((camp) => CampItemMarker(
            id: camp.id,
            label: camp.label,
            latLng: LatLng(camp.geoLocation.lat, camp.geoLocation.long),
          ))
      .toList();
});

class CampMapScreen extends ConsumerStatefulWidget {
  final List<CampSite> campsites;

  final CampSite selectedCampSite;


  CampMapScreen({
    super.key,
    required this.campsites,
    required this.selectedCampSite,
  });

  @override
  ConsumerState<CampMapScreen> createState() => _CampMapScreenState();
}

class _CampMapScreenState extends ConsumerState<CampMapScreen> {
  late Set<Marker> markers;
  final Completer<GoogleMapController> _completer = Completer();
  ClusterManager<CampItemMarker>? _clusterManager;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campsitesProvider.notifier).state = widget.campsites;
      _initCluster();
    });
  }

  void _initCluster() {
    final clusterItems = ref.read(clusterItemsProvider);

    _clusterManager = ClusterManager<CampItemMarker>(
      clusterItems,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      stopClusteringZoom: 17,
    );

  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      markers = markers;
    });
  }

  Future<Marker> _markerBuilder(Cluster<CampItemMarker> cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      infoWindow: cluster.isMultiple
          ? InfoWindow(title: 'تعداد کمپ‌ها: ${cluster.count}')
          : InfoWindow(title: cluster.items.first!.label),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Campsites Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onCameraMove: _clusterManager?.onCameraMove,
        onCameraIdle: _clusterManager?.updateMap,
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
    _completer.complete(controller);
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        if (kDebugMode) {
          print("Location permission denied");
        }
      }
    }
  }
}
