import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_geohash/dart_geohash.dart';

class CampItemMarker implements ClusterItem<CampItemMarker>{
  final String id;
  final String label;
  final LatLng latLng;

  CampItemMarker({
    required this.id,
    required this.label,
    required this.latLng,
  });

  @override
  LatLng get location => latLng;


  @override
  get item => this;

  @override
  // TODO: implement geohash

  String get geohash => GeoHasher().encode(latLng.latitude, latLng.longitude);
}