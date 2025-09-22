import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/location_permission_service.dart';
import '../widgets/map_widgets/map_widgets.dart';

class LocationPickerPage extends StatefulWidget {
  final String? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialLocation != null &&
          widget.initialLocation!.isNotEmpty) {
        await _geocodeAddress(widget.initialLocation!);
      } else {
        await _getCurrentLocation();
      }
    } catch (e) {
      print('Error initializing location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedLocation = latLng;
          _selectedAddress = address;
          _isLoading = false;
        });

        _updateMarkers();
        _moveCamera(latLng);
      }
    } catch (e) {
      print('Error geocoding address: $e');
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permissionService = const LocationPermissionService();
      final serviceEnabled = await permissionService.isServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location services are disabled'),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () {
                  permissionService.openLocationSettings();
                },
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final hasPermission = await permissionService.ensureLocationPermission();
      if (!hasPermission) {
        final permanentlyDenied = await permissionService.isPermanentlyDenied();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(permanentlyDenied
                  ? 'Location permission is permanently denied'
                  : 'Location permission is required'),
              action: permanentlyDenied
                  ? SnackBarAction(
                      label: 'Open Settings',
                      onPressed: () {
                        permissionService.openAppSettings();
                      },
                    )
                  : null,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String address = '';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address =
            '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}'
                .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
      }

      setState(() {
        _selectedLocation = latLng;
        _selectedAddress = address;
        _isLoading = false;
      });

      _updateMarkers();
      _moveCamera(latLng);
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onMapTap(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);

      String address = '';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address =
            '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}'
                .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
      }

      setState(() {
        _selectedLocation = location;
        _selectedAddress = address;
      });

      _updateMarkers();
    } catch (e) {
      print('Error getting address for tapped location: $e');
      setState(() {
        _selectedLocation = location;
        _selectedAddress = 'Unknown location';
      });
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    if (_selectedLocation != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId("selectedLocation"),
            position: _selectedLocation!,
            infoWindow: InfoWindow(
              title: _selectedAddress.isNotEmpty
                  ? 'Selected Location'
                  : 'Current Location',
              snippet: _selectedAddress.isNotEmpty
                  ? _selectedAddress
                  : 'Tap to select a location',
            ),
          ),
        };
      });
    }
  }

  void _moveCamera(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }

  Future<void> _zoomIn() async {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedAddress);
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);

        String address = query;
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address =
              '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}'
                  .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
        }

        setState(() {
          _selectedLocation = latLng;
          _selectedAddress = address;
          _isSearching = false;
        });

        _updateMarkers();
        _moveCamera(latLng);
      }
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location "$query" not found'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Location'),
        centerTitle: true,
      ),
      body: _isLoading || _selectedLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  mapToolbarEnabled: true,
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: SearchInput(
                    controller: _searchController,
                    isLoading: _isSearching,
                    onSubmitted: _searchLocation,
                    onChanged: (_) => setState(() {}),
                    onCleared: () => setState(() {}),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 100,
                  child: ZoomControls(
                    onZoomIn: () => _zoomIn(),
                    onZoomOut: () => _zoomOut(),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: SelectedLocationCard(
                    address: _selectedAddress,
                    onConfirm: _confirmLocation,
                    enabled: true,
                  ),
                ),
              ],
            ),
    );
  }
}
