import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A widget that allows users to pick a location on a map.
/// Defaults to Sarajevo, Bosnia and Herzegovina.
class MapLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<LatLng>? onLocationChanged;
  final double height;
  final bool showCoordinatesInput;
  final bool readOnly;

  // Default coordinates for Sarajevo, Bosnia
  static const double defaultLatitude = 43.8563;
  static const double defaultLongitude = 18.4131;

  const MapLocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationChanged,
    this.height = 300,
    this.showCoordinatesInput = true,
    this.readOnly = false,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = LatLng(
      widget.initialLatitude ?? MapLocationPicker.defaultLatitude,
      widget.initialLongitude ?? MapLocationPicker.defaultLongitude,
    );
    _latController = TextEditingController(text: _selectedLocation.latitude.toStringAsFixed(6));
    _lngController = TextEditingController(text: _selectedLocation.longitude.toStringAsFixed(6));
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (widget.readOnly) return;
    
    setState(() {
      _selectedLocation = point;
      _latController.text = point.latitude.toStringAsFixed(6);
      _lngController.text = point.longitude.toStringAsFixed(6);
    });
    widget.onLocationChanged?.call(point);
  }

  void _updateLocationFromInput() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    
    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      final newLocation = LatLng(lat, lng);
      setState(() {
        _selectedLocation = newLocation;
      });
      if (_isMapReady) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      }
      widget.onLocationChanged?.call(newLocation);
    }
  }

  void _centerOnLocation() {
    if (_isMapReady) {
      _mapController.move(_selectedLocation, 15);
    }
  }

  void _resetToDefault() {
    final defaultLocation = LatLng(
      MapLocationPicker.defaultLatitude,
      MapLocationPicker.defaultLongitude,
    );
    setState(() {
      _selectedLocation = defaultLocation;
      _latController.text = defaultLocation.latitude.toStringAsFixed(6);
      _lngController.text = defaultLocation.longitude.toStringAsFixed(6);
    });
    if (_isMapReady) {
      _mapController.move(defaultLocation, 13);
    }
    widget.onLocationChanged?.call(defaultLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map container
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 13,
                    onTap: _onMapTap,
                    onMapReady: () {
                      setState(() {
                        _isMapReady = true;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.erent.landlord',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 50,
                          height: 50,
                          child: const _LocationMarker(),
                        ),
                      ],
                    ),
                  ],
                ),
                // Map controls overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      _MapControlButton(
                        icon: Icons.add,
                        onPressed: () {
                          if (_isMapReady) {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          }
                        },
                        tooltip: 'Zoom in',
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.remove,
                        onPressed: () {
                          if (_isMapReady) {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          }
                        },
                        tooltip: 'Zoom out',
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.my_location,
                        onPressed: _centerOnLocation,
                        tooltip: 'Center on marker',
                      ),
                      if (!widget.readOnly) ...[
                        const SizedBox(height: 8),
                        _MapControlButton(
                          icon: Icons.restart_alt,
                          onPressed: _resetToDefault,
                          tooltip: 'Reset to Sarajevo',
                        ),
                      ],
                    ],
                  ),
                ),
                // Location info overlay
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFFFB84D),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Instruction overlay
                if (!widget.readOnly)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB84D).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Tap to set location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Coordinate inputs
        if (widget.showCoordinatesInput) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CoordinateInput(
                  controller: _latController,
                  label: 'Latitude',
                  hint: '43.8563',
                  readOnly: widget.readOnly,
                  onChanged: (_) => _updateLocationFromInput(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final lat = double.tryParse(value);
                    if (lat == null || lat < -90 || lat > 90) return 'Invalid (-90 to 90)';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CoordinateInput(
                  controller: _lngController,
                  label: 'Longitude',
                  hint: '18.4131',
                  readOnly: widget.readOnly,
                  onChanged: (_) => _updateLocationFromInput(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final lng = double.tryParse(value);
                    if (lng == null || lng < -180 || lng > 180) return 'Invalid (-180 to 180)';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Custom location marker widget
class _LocationMarker extends StatelessWidget {
  const _LocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        Positioned(
          bottom: 0,
          child: Container(
            width: 20,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Pin
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFB84D), Color(0xFFF97316)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB84D).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            Container(
              width: 4,
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF97316),
                    const Color(0xFFF97316).withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Map control button widget
class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: const Color(0xFF1F2937)),
          ),
        ),
      ),
    );
  }
}

/// Coordinate input field widget
class _CoordinateInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _CoordinateInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.readOnly = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          label == 'Latitude' ? Icons.swap_vert : Icons.swap_horiz,
          color: const Color(0xFFFFB84D),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFB84D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.withOpacity(0.1) : null,
      ),
    );
  }
}

/// Dialog to pick a location on a map
/// Returns the selected LatLng or null if cancelled
Future<LatLng?> showMapLocationPickerDialog({
  required BuildContext context,
  double? initialLatitude,
  double? initialLongitude,
  String title = 'Select Location',
}) async {
  LatLng? selectedLocation;
  
  return showDialog<LatLng>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB84D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFFFB84D),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: MapLocationPicker(
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          onLocationChanged: (location) {
            selectedLocation = location;
          },
          height: 400,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              selectedLocation ??
                  LatLng(
                    initialLatitude ?? MapLocationPicker.defaultLatitude,
                    initialLongitude ?? MapLocationPicker.defaultLongitude,
                  ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB84D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Confirm'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
