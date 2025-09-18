import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
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
            backgroundColor: Colors.red,
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
        backgroundColor: Colors.white,
        elevation: 0,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a location...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _searchLocation,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                // Custom zoom controls
                Positioned(
                  right: 20,
                  top: 100,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _zoomIn,
                          icon: const Icon(Icons.add, color: Colors.black54),
                          iconSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _zoomOut,
                          icon: const Icon(Icons.remove, color: Colors.black54),
                          iconSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Location:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedAddress.isNotEmpty
                              ? _selectedAddress
                              : 'Tap on the map to select a location',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedAddress.isNotEmpty
                                ? _confirmLocation
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Confirm Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
