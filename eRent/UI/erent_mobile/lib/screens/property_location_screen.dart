import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PropertyLocationScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String propertyTitle;
  final String? address;
  final String cityName;

  const PropertyLocationScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.propertyTitle,
    this.address,
    required this.cityName,
  });

  @override
  State<PropertyLocationScreen> createState() => _PropertyLocationScreenState();
}

class _PropertyLocationScreenState extends State<PropertyLocationScreen> {
  late MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnLocation() {
    if (_isMapReady) {
      _mapController.move(
        LatLng(widget.latitude, widget.longitude),
        15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Property Location',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Property Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  widget.propertyTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.address != null
                            ? '${widget.address}, ${widget.cityName}'
                            : widget.cityName,
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
                    color: const Color(0xFF5B9BD5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, size: 16, color: const Color(0xFF5B9BD5)),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5B9BD5),
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
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: propertyLocation,
                      initialZoom: 15,
                      onMapReady: () {
                        setState(() {
                          _isMapReady = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.erent.mobile',
                        maxZoom: 19,
                        subdomains: const ['a', 'b', 'c'],
                        tileProvider: NetworkTileProvider(
                          headers: {
                            'User-Agent': 'eRent Mobile App/1.0 (com.erent.mobile)',
                          },
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: propertyLocation,
                            width: 60,
                            height: 60,
                            child: const _PropertyLocationMarker(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Map Controls
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

/// Custom property location marker widget
class _PropertyLocationMarker extends StatelessWidget {
  const _PropertyLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
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
        // Pin
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

/// Map control button widget
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
