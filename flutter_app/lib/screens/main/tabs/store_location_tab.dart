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
  static const _storeName = 'SportZone High-Tech Store';
  static const _storeAddress =
      'Lô E2a-7, Đường D1, Khu Công nghệ cao, phường Long Thạnh Mỹ, TP. Thủ Đức.';
  static const _fallbackStoreLocation = LatLng(10.84118, 106.80986);
  static const _fallbackUserLocation = LatLng(10.77584, 106.70088);

  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final Distance _distance = const Distance();

  StreamSubscription<Position>? _positionSubscription;

  LatLng _storeLocation = _fallbackStoreLocation;
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  List<_RouteStep> _routeSteps = [];
  double? _routeDistanceMeters;
  double? _routeDurationSeconds;
  int _activeStepIndex = 0;
  bool _isLoadingLocation = false;
  bool _isLoadingRoute = false;
  bool _isGeocodingStore = false;
  bool _showRoute = false;
  bool _navigationActive = false;
  bool _showStoreSheet = false;
  String? _mapMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeMap());
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(_storeLocation, 15.5);
      }
    });
    await _geocodeStoreAddress();
    await _useCurrentLocation(moveCamera: false, refreshRoute: true);
  }

  @override
  Widget build(BuildContext context) {
    final activeStart = _userLocation ?? _fallbackUserLocation;
    final activeStep = _routeSteps.isNotEmpty
        ? _routeSteps[_activeStepIndex.clamp(0, _routeSteps.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
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
                        color: const Color(0xFF1D6CFF),
                        strokeWidth: 8,
                      ),
                      Polyline(
                        points: _routePoints,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: activeStart,
                      width: 54,
                      height: 54,
                      child: _MapPin(
                        icon: _navigationActive
                            ? Icons.navigation
                            : Icons.my_location,
                        color: const Color(0xFF1D6CFF),
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
              loading:
                  _isLoadingRoute || _isLoadingLocation || _isGeocodingStore,
              onTap: _openStoreSheet,
            ),
          ),
          if (_navigationActive && activeStep != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              left: 16,
              right: 88,
              child: _GuidanceBanner(step: activeStep),
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
                  onTap: () =>
                      _useCurrentLocation(moveCamera: true, refreshRoute: true),
                ),
                const SizedBox(height: 8),
                _mapAction(
                  icon: Icons.alt_route,
                  selected: _showRoute,
                  loading: _isLoadingRoute,
                  onTap: () => _toggleRoute(activeStart),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: _TripControlCard(
              distanceMeters: _routeDistanceMeters,
              durationSeconds: _routeDurationSeconds,
              navigationActive: _navigationActive,
              loading: _isLoadingRoute || _isLoadingLocation,
              onStartNavigation: _startNavigation,
              onStopNavigation: _stopNavigation,
              onDetails: _openStoreSheet,
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
                initialChildSize: 0.42,
                minChildSize: 0.12,
                maxChildSize: 0.72,
                snap: true,
                snapSizes: const [0.12, 0.42, 0.72],
                builder: (context, scrollController) {
                  return _StoreInfoSheet(
                    scrollController: scrollController,
                    address: _storeAddress,
                    distanceMeters: _routeDistanceMeters,
                    durationSeconds: _routeDurationSeconds,
                    routeSteps: _routeSteps,
                    navigationActive: _navigationActive,
                    loadingRoute: _isLoadingRoute,
                    onStartNavigation: _startNavigation,
                    onStopNavigation: _stopNavigation,
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

  Future<void> _geocodeStoreAddress() async {
    setState(() {
      _isGeocodingStore = true;
      _mapMessage = 'Đang định vị cửa hàng...';
    });

    try {
      final uri = Uri.parse('https://api.mapbox.com/search/geocode/v6/forward')
          .replace(
            queryParameters: {
              'q': _storeAddress,
              'country': 'vn',
              'limit': '1',
              'language': 'vi',
              'access_token': _mapboxToken,
            },
          );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      if (response.statusCode == 200 && features.isNotEmpty) {
        final feature = features.first as Map<String, dynamic>;
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;
        final location = LatLng(
          (coordinates[1] as num).toDouble(),
          (coordinates[0] as num).toDouble(),
        );
        final distanceFromExpected = _distance.as(
          LengthUnit.Meter,
          location,
          _fallbackStoreLocation,
        );
        if (distanceFromExpected > 3000) {
          setState(() {
            _storeLocation = _fallbackStoreLocation;
            _mapMessage = null;
          });
          return;
        }
        setState(() => _storeLocation = location);
        _mapController.move(location, 15.5);
      } else {
        setState(() => _mapMessage = 'Dùng tọa độ dự phòng của cửa hàng.');
      }
    } catch (e) {
      setState(() => _mapMessage = 'Không geocode được địa chỉ: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeocodingStore = false);
      }
    }
  }

  Future<void> _useCurrentLocation({
    required bool moveCamera,
    required bool refreshRoute,
  }) async {
    setState(() {
      _isLoadingLocation = true;
      _mapMessage = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _mapMessage = 'Bạn cần bật định vị để chỉ đường.');
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

      final position = await _resolveCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      setState(() => _userLocation = location);
      if (moveCamera) {
        _mapController.move(location, 16);
      }
      if (refreshRoute) {
        await _loadRoute(from: location, moveCamera: _showRoute);
      }
    } catch (e) {
      setState(() => _mapMessage = 'Không lấy được vị trí hiện tại: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<Position> _resolveCurrentPosition() async {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      unawaited(_refreshPrecisePosition());
      return lastKnown;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } on TimeoutException {
      return _fallbackPosition(
        'GPS phản hồi chậm, đang dùng vị trí gần nhất để chỉ đường.',
      );
    } catch (_) {
      return _fallbackPosition(
        'Không lấy được GPS, đang dùng vị trí gần nhất để chỉ đường.',
      );
    }
  }

  Future<void> _refreshPrecisePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 30),
        ),
      );
      if (!mounted) return;
      final location = LatLng(position.latitude, position.longitude);
      setState(() => _userLocation = location);
      if (_showRoute || _navigationActive) {
        await _loadRoute(from: location, moveCamera: false);
      }
    } catch (_) {
      // GPS can be slow on emulator startup; keep cached/fallback location.
    }
  }

  Position _fallbackPosition(String message) {
    final fallback = _userLocation ?? _fallbackUserLocation;
    if (mounted) {
      setState(() => _mapMessage = message);
    }
    return Position(
      longitude: fallback.longitude,
      latitude: fallback.latitude,
      timestamp: DateTime.now(),
      accuracy: 500,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      isMocked: true,
    );
  }

  Future<void> _toggleRoute(LatLng from) async {
    if (_showRoute) {
      _stopNavigation();
      setState(() => _showRoute = false);
      return;
    }

    final start = _userLocation ?? from;
    if (_userLocation == null) {
      await _useCurrentLocation(moveCamera: false, refreshRoute: false);
    }
    await _loadRoute(from: _userLocation ?? start, moveCamera: false);
    setState(() => _showRoute = true);
    _fitRoute();
  }

  Future<void> _startNavigation() async {
    await _useCurrentLocation(moveCamera: false, refreshRoute: false);
    final start = _userLocation;
    if (start == null) return;
    await _loadRoute(from: start, moveCamera: true);
    setState(() {
      _showRoute = true;
      _navigationActive = true;
    });
    _startPositionStream();
    _fitRoute();
  }

  void _stopNavigation() {
    unawaited(_positionSubscription?.cancel());
    _positionSubscription = null;
    setState(() => _navigationActive = false);
  }

  void _clearRouteWithMessage(String message) {
    unawaited(_positionSubscription?.cancel());
    _positionSubscription = null;
    setState(() {
      _navigationActive = false;
      _showRoute = false;
      _routePoints = [];
      _routeSteps = [];
      _routeDistanceMeters = null;
      _routeDurationSeconds = null;
      _activeStepIndex = 0;
      _mapMessage = message;
    });
  }

  void _startPositionStream() {
    unawaited(_positionSubscription?.cancel());
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 20,
          ),
        ).listen((position) {
          final location = LatLng(position.latitude, position.longitude);
          setState(() {
            _userLocation = location;
            _activeStepIndex = _nearestUpcomingStepIndex(location);
          });
        });
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
      final data =
          await _requestDirections('mapbox/driving-traffic', from) ??
          await _requestDirections('mapbox/driving', from);
      if (data == null) {
        _clearRouteWithMessage('Mapbox chưa tìm được tuyến đường.');
        return;
      }

      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) {
        _clearRouteWithMessage('Mapbox chưa tìm được tuyến đường.');
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

      final legs = route['legs'] as List<dynamic>? ?? [];
      final rawSteps = legs.isNotEmpty
          ? ((legs.first as Map<String, dynamic>)['steps'] as List<dynamic>? ??
                [])
          : <dynamic>[];
      final steps = rawSteps
          .whereType<Map<String, dynamic>>()
          .map(_RouteStep.fromJson)
          .where((step) => step.instruction.isNotEmpty)
          .toList();

      setState(() {
        _routePoints = points;
        _routeSteps = steps;
        _activeStepIndex = 0;
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

  Future<Map<String, dynamic>?> _requestDirections(
    String profile,
    LatLng from,
  ) async {
    final uri =
        Uri.parse(
          'https://api.mapbox.com/directions/v5/$profile/'
          '${from.longitude},${from.latitude};${_storeLocation.longitude},${_storeLocation.latitude}',
        ).replace(
          queryParameters: {
            'access_token': _mapboxToken,
            'geometries': 'geojson',
            'overview': 'full',
            'steps': 'true',
            'banner_instructions': 'true',
            'voice_instructions': 'true',
            'voice_units': 'metric',
            'language': 'vi',
            'alternatives': 'false',
          },
        );

    final response = await http.get(uri).timeout(const Duration(seconds: 18));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  int _nearestUpcomingStepIndex(LatLng location) {
    if (_routeSteps.isEmpty) return 0;
    var nearestIndex = _activeStepIndex;
    var nearestDistance = double.infinity;
    for (var i = _activeStepIndex; i < _routeSteps.length; i++) {
      final step = _routeSteps[i];
      if (step.location == null) continue;
      final distance = _distance.as(LengthUnit.Meter, location, step.location!);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }
    if (nearestDistance < 35 && nearestIndex < _routeSteps.length - 1) {
      return nearestIndex + 1;
    }
    return nearestIndex;
  }

  void _openStoreSheet() {
    if (!_showStoreSheet) {
      setState(() => _showStoreSheet = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sheetController.isAttached) {
          unawaited(
            _sheetController.animateTo(
              0.42,
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
        padding: const EdgeInsets.fromLTRB(56, 120, 56, 220),
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
                message ?? _StoreLocationScreenState._storeName,
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

class _GuidanceBanner extends StatelessWidget {
  final _RouteStep step;

  const _GuidanceBanner({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: SportZoneTheme.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_maneuverIcon(step), color: SportZoneTheme.onPrimary, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _distanceLabel(step.distanceMeters),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SportZoneTheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.instruction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SportZoneTheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _maneuverIcon(_RouteStep step) {
    final type = step.type;
    final modifier = step.modifier;
    if (type == 'arrive') return Icons.flag;
    if (type == 'depart') return Icons.navigation;
    if (type == 'roundabout') return Icons.roundabout_right;
    if (modifier.contains('left')) return Icons.turn_left;
    if (modifier.contains('right')) return Icons.turn_right;
    if (modifier.contains('uturn')) return Icons.u_turn_left;
    return Icons.straight;
  }

  String _distanceLabel(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }
}

class _TripControlCard extends StatelessWidget {
  final double? distanceMeters;
  final double? durationSeconds;
  final bool navigationActive;
  final bool loading;
  final VoidCallback onStartNavigation;
  final VoidCallback onStopNavigation;
  final VoidCallback onDetails;

  const _TripControlCard({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.navigationActive,
    required this.loading,
    required this.onStartNavigation,
    required this.onStopNavigation,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SportZoneTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _distanceLabel(distanceMeters),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_durationLabel(durationSeconds)} tới cửa hàng',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SportZoneTheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onDetails, icon: const Icon(Icons.expand_less)),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: navigationActive
                    ? SportZoneTheme.error
                    : const Color(0xFF1D6CFF),
                foregroundColor: SportZoneTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: loading
                  ? null
                  : (navigationActive ? onStopNavigation : onStartNavigation),
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SportZoneTheme.onPrimary,
                      ),
                    )
                  : Icon(navigationActive ? Icons.close : Icons.near_me),
              label: Text(
                navigationActive ? 'Dừng' : 'Chỉ đường',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
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

class _StoreInfoSheet extends StatelessWidget {
  final ScrollController scrollController;
  final String address;
  final double? distanceMeters;
  final double? durationSeconds;
  final List<_RouteStep> routeSteps;
  final bool navigationActive;
  final bool loadingRoute;
  final VoidCallback onStartNavigation;
  final VoidCallback onStopNavigation;

  const _StoreInfoSheet({
    required this.scrollController,
    required this.address,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.routeSteps,
    required this.navigationActive,
    required this.loadingRoute,
    required this.onStartNavigation,
    required this.onStopNavigation,
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
                        _StoreLocationScreenState._storeName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
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
                  backgroundColor: navigationActive
                      ? SportZoneTheme.error
                      : const Color(0xFF1D6CFF),
                  foregroundColor: SportZoneTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: loadingRoute
                    ? null
                    : (navigationActive ? onStopNavigation : onStartNavigation),
                icon: loadingRoute
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(navigationActive ? Icons.close : Icons.near_me),
                label: Text(
                  navigationActive ? 'DỪNG CHỈ ĐƯỜNG' : 'CHỈ ĐƯỜNG TỚI SHOP',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            if (routeSteps.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Các bước di chuyển',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...routeSteps
                  .take(6)
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _StepTile(step: step),
                    ),
                  ),
            ],
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

class _StepTile extends StatelessWidget {
  final _RouteStep step;

  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: SportZoneTheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.navigation, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.instruction,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                _distanceLabel(step.distanceMeters),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SportZoneTheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _distanceLabel(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
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

class _RouteStep {
  final String instruction;
  final double distanceMeters;
  final String type;
  final String modifier;
  final LatLng? location;

  const _RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.type,
    required this.modifier,
    required this.location,
  });

  factory _RouteStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final banner = (json['bannerInstructions'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .firstOrNull;
    final primary = banner?['primary'] as Map<String, dynamic>?;
    final bannerText = primary?['text']?.toString();
    final maneuverText = maneuver['instruction']?.toString() ?? '';
    final rawLocation = maneuver['location'] as List<dynamic>?;

    return _RouteStep(
      instruction: bannerText?.isNotEmpty == true ? bannerText! : maneuverText,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      type: maneuver['type']?.toString() ?? '',
      modifier: maneuver['modifier']?.toString() ?? '',
      location: rawLocation == null || rawLocation.length < 2
          ? null
          : LatLng(
              (rawLocation[1] as num).toDouble(),
              (rawLocation[0] as num).toDouble(),
            ),
    );
  }
}
