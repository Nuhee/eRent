import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/property.dart';

/// Default center (Sarajevo) when property has no valid coordinates.
const double _defaultLat = 43.8516;
const double _defaultLng = 18.3864;

class PropertyMapLocationScreen extends StatefulWidget {
  final Property property;

  const PropertyMapLocationScreen({super.key, required this.property});

  @override
  State<PropertyMapLocationScreen> createState() =>
      _PropertyMapLocationScreenState();
}

class _PropertyMapLocationScreenState extends State<PropertyMapLocationScreen> {
  late MapController _mapController;
  bool _isMapReady = false;
  late LatLng _propertyLocation;

  static const Color primaryColor = Color(0xFF5B9BD5);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final lat = widget.property.latitude;
    final lng = widget.property.longitude;
    _propertyLocation = (lat != 0.0 || lng != 0.0)
        ? LatLng(lat, lng)
        : const LatLng(_defaultLat, _defaultLng);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnLocation() {
    if (_isMapReady) {
      _mapController.move(_propertyLocation, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Property Location',
      showBackButton: true,
      child: Column(
        children: [
          // Property info card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title.isNotEmpty
                      ? widget.property.title
                      : 'Property',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.property.address != null &&
                                widget.property.address!.isNotEmpty
                            ? '${widget.property.address}, ${widget.property.cityName}'
                            : widget.property.cityName,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, size: 16, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        '${_propertyLocation.latitude.toStringAsFixed(6)}, ${_propertyLocation.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _propertyLocation,
                      initialZoom: 15,
                      onMapReady: () {
                        setState(() => _isMapReady = true);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.erent.desktop',
                        maxZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _propertyLocation,
                            width: 60,
                            height: 60,
                            child: const _PropertyLocationMarker(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    right: 16,
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
                        ),
                        const SizedBox(height: 12),
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
                        ),
                        const SizedBox(height: 12),
                        _MapControlButton(
                          icon: Icons.my_location,
                          onPressed: _centerOnLocation,
                          isPrimary: true,
                        ),
                      ],
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

class _PropertyLocationMarker extends StatelessWidget {
  const _PropertyLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 0,
          child: Container(
            width: 24,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5B9BD5), Color(0xFF7AB8CC)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B9BD5).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            Container(
              width: 5,
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF7AB8CC),
                    const Color(0xFF7AB8CC).withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(2.5),
                  bottomRight: Radius.circular(2.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? const Color(0xFF5B9BD5) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: isPrimary ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}
