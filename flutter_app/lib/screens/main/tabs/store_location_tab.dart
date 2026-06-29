import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_app/core.dart';

class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  static const _mapboxToken =
      'pk.eyJ1IjoicXVhbmdnMTIiLCJhIjoiY21xODNxdGNuMDVxdTJycHFhaWh5b3MzayJ9.WmJKle4YZva6lQBPEZaJvw';
  static const _storeLocation = LatLng(10.77584, 106.70088);
  static const _fallbackUserLocation = LatLng(10.77221, 106.69812);

  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final Distance _distance = const Distance();

  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  double? _routeDistanceMeters;
  double? _routeDurationSeconds;
  bool _isLoadingLocation = false;
  bool _isLoadingRoute = false;
  bool _showRoute = false;
  bool _showStoreSheet = false;
  String? _mapMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRoute(from: _fallbackUserLocation, moveCamera: false));
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeStart = _userLocation ?? _fallbackUserLocation;

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _storeLocation,
                initialZoom: 15.5,
                minZoom: 4,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/512/{z}/{x}/{y}?access_token=$_mapboxToken',
                  tileDimension: 512,
                  zoomOffset: -1,
                  maxNativeZoom: 22,
                  additionalOptions: const {
                    'accessToken': _mapboxToken,
                    'id': 'mapbox.streets',
                  },
                  userAgentPackageName: 'com.example.flutter_app',
                  errorTileCallback: (tile, error, stackTrace) {
                    debugPrint('Mapbox tile error: $error');
                  },
                ),
                if (_showRoute && _routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: SportZoneTheme.electricLime,
                        strokeWidth: 6,
                      ),
                      Polyline(
                        points: _routePoints,
                        color: SportZoneTheme.primary,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: activeStart,
                      width: 46,
                      height: 46,
                      child: const _MapPin(
                        icon: Icons.my_location,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Marker(
                      point: _storeLocation,
                      width: 58,
                      height: 58,
                      child: GestureDetector(
                        onTap: _openStoreSheet,
                        child: const _MapPin(
                          icon: Icons.storefront,
                          color: SportZoneTheme.electricLime,
                          darkIcon: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 16,
            right: 16,
            child: _MapSearchHeader(
              message: _mapMessage,
              loading: _isLoadingRoute || _isLoadingLocation,
              onTap: _openStoreSheet,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 86,
            right: 16,
            child: Column(
              children: [
                _mapAction(icon: Icons.add, onTap: () => _zoomBy(1)),
                const SizedBox(height: 8),
                _mapAction(icon: Icons.remove, onTap: () => _zoomBy(-1)),
                const SizedBox(height: 8),
                _mapAction(
                  icon: Icons.my_location,
                  loading: _isLoadingLocation,
                  onTap: _useCurrentLocation,
                ),
                const SizedBox(height: 8),
                _mapAction(
                  icon: Icons.route_outlined,
                  selected: _showRoute,
                  loading: _isLoadingRoute,
                  onTap: () => _toggleRoute(activeStart),
                ),
              ],
            ),
          ),
          if (_showStoreSheet)
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.13) {
                  setState(() => _showStoreSheet = false);
                }
                return false;
              },
              child: DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.38,
                minChildSize: 0.12,
                maxChildSize: 0.58,
                snap: true,
                snapSizes: const [0.12, 0.38, 0.58],
                builder: (context, scrollController) {
                  return _StoreInfoSheet(
                    scrollController: scrollController,
                    distanceMeters: _routeDistanceMeters,
                    durationSeconds: _routeDurationSeconds,
                    routeVisible: _showRoute,
                    loadingRoute: _isLoadingRoute,
                    onDirections: () => _toggleRoute(activeStart),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _mapAction({
    required IconData icon,
    required VoidCallback onTap,
    bool loading = false,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? SportZoneTheme.primary : SportZoneTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SportZoneTheme.primary),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(13),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                icon,
                color: selected
                    ? SportZoneTheme.onPrimary
                    : SportZoneTheme.primary,
              ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _mapMessage = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _mapMessage = 'Bạn cần bật định vị để lấy vị trí.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _mapMessage = 'Ứng dụng chưa có quyền truy cập vị trí.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final location = LatLng(position.latitude, position.longitude);
      setState(() => _userLocation = location);
      await _loadRoute(from: location, moveCamera: _showRoute);
    } catch (e) {
      setState(() => _mapMessage = 'Không lấy được vị trí: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _toggleRoute(LatLng from) async {
    if (_showRoute) {
      setState(() => _showRoute = false);
      return;
    }
    if (_routePoints.isEmpty) {
      await _loadRoute(from: from, moveCamera: false);
    }
    setState(() => _showRoute = true);
    _fitRoute();
  }

  Future<void> _loadRoute({
    required LatLng from,
    required bool moveCamera,
  }) async {
    setState(() {
      _isLoadingRoute = true;
      _mapMessage = null;
    });

    try {
      final uri =
          Uri.parse(
            'https://api.mapbox.com/directions/v5/mapbox/driving/'
            '${from.longitude},${from.latitude};${_storeLocation.longitude},${_storeLocation.latitude}',
          ).replace(
            queryParameters: {
              'access_token': _mapboxToken,
              'geometries': 'geojson',
              'overview': 'full',
              'steps': 'true',
              'language': 'vi',
            },
          );

      final response = await http.get(uri).timeout(const Duration(seconds: 18));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>? ?? [];
      if (response.statusCode != 200 || routes.isEmpty) {
        setState(() => _mapMessage = 'Mapbox chưa tìm được tuyến đường.');
        return;
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>? ?? [];
      final points = coordinates
          .whereType<List<dynamic>>()
          .map(
            (item) => LatLng(
              (item[1] as num).toDouble(),
              (item[0] as num).toDouble(),
            ),
          )
          .toList();

      setState(() {
        _routePoints = points;
        _routeDistanceMeters =
            (route['distance'] as num?)?.toDouble() ??
            _distance.as(LengthUnit.Meter, from, _storeLocation);
        _routeDurationSeconds = (route['duration'] as num?)?.toDouble();
      });

      if (moveCamera) {
        _fitRoute();
      }
    } on TimeoutException {
      setState(() => _mapMessage = 'Mapbox phản hồi quá lâu, thử lại sau.');
    } catch (e) {
      setState(() => _mapMessage = 'Không tải được chỉ dẫn: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  void _openStoreSheet() {
    if (!_showStoreSheet) {
      setState(() => _showStoreSheet = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sheetController.isAttached) {
          unawaited(
            _sheetController.animateTo(
              0.38,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            ),
          );
        }
      });
    }
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + delta);
  }

  void _fitRoute() {
    final points = _routePoints.isNotEmpty
        ? _routePoints
        : [_userLocation ?? _fallbackUserLocation, _storeLocation];
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(56, 120, 56, 180),
      ),
    );
  }
}

class _MapSearchHeader extends StatelessWidget {
  final String? message;
  final bool loading;
  final VoidCallback onTap;

  const _MapSearchHeader({
    required this.message,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: SportZoneTheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.map_outlined, color: SportZoneTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message ?? 'SportZone Flagship Store',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreInfoSheet extends StatelessWidget {
  final ScrollController scrollController;
  final double? distanceMeters;
  final double? durationSeconds;
  final bool routeVisible;
  final bool loadingRoute;
  final VoidCallback onDirections;

  const _StoreInfoSheet({
    required this.scrollController,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.routeVisible,
    required this.loadingRoute,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          color: SportZoneTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: SportZoneTheme.primary, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 26,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SportZoneTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BadgeTag(text: 'MAPBOX', isAccent: true),
                      const SizedBox(height: 8),
                      Text(
                        'SportZone Flagship Store',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '123 Lê Lợi, Quận 1, TP.HCM',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SportZoneTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SportZoneTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: SportZoneTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StoreMetric(
                  icon: Icons.route_outlined,
                  label: 'QUÃNG ĐƯỜNG',
                  value: _distanceLabel(distanceMeters),
                ),
                const SizedBox(width: 10),
                _StoreMetric(
                  icon: Icons.schedule,
                  label: 'THỜI GIAN',
                  value: _durationLabel(durationSeconds),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: _StoreInfoTile(
                    icon: Icons.call_outlined,
                    label: 'HOTLINE',
                    value: '+84 28 3456 7890',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _StoreInfoTile(
                    icon: Icons.access_time,
                    label: 'MỞ CỬA',
                    value: '09:00 - 22:00',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: routeVisible
                      ? SportZoneTheme.electricLime
                      : SportZoneTheme.primary,
                  foregroundColor: routeVisible
                      ? SportZoneTheme.primary
                      : SportZoneTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: loadingRoute ? null : onDirections,
                icon: loadingRoute
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        routeVisible
                            ? Icons.visibility_off_outlined
                            : Icons.near_me_outlined,
                      ),
                label: Text(
                  routeVisible ? 'ẨN TUYẾN ĐƯỜNG' : 'HIỆN TUYẾN ĐƯỜNG',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceLabel(double? meters) {
    if (meters == null) return '--';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }

  String _durationLabel(double? seconds) {
    if (seconds == null) return '--';
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes phút';
    final hours = minutes ~/ 60;
    final remain = minutes % 60;
    return remain == 0 ? '$hours giờ' : '$hours giờ $remain phút';
  }
}

class _StoreMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StoreMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: SportZoneTheme.borderSubtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: SportZoneTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SportZoneTheme.secondary,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StoreInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SportZoneTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: SportZoneTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SportZoneTheme.secondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool darkIcon;

  const _MapPin({
    required this.icon,
    required this.color,
    this.darkIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: darkIcon ? SportZoneTheme.primary : Colors.white,
        size: 24,
      ),
    );
  }
}
