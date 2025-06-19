import 'package:bus_tracker_chofer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:bus_tracker_chofer/utils/location_service.dart';
import 'package:bus_tracker_chofer/utils/supabase_service.dart';
import 'package:bus_tracker_chofer/screens/bus_screen.dart'; // Importa BusScreen para la navegación
import 'package:bus_tracker_chofer/screens/settings_screen.dart'; // Importa SettingsScreen

class MapScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String busId;
  final String busBrand;
  final String busPatent;
  final String routeId;
  final String routeName;
  final Map<String, dynamic>? routeGeoJson;

  const MapScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.busId,
    required this.busBrand,
    required this.busPatent,
    required this.routeId,
    required this.routeName,
    this.routeGeoJson,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final SupabaseService _supabaseService = SupabaseService();
  String? _companyName;
  // ignore: unused_field
  bool _isFetchingUserInfo = false;
  // ignore: unused_field
  Map<String, dynamic>? _busStopsGeoJson;
  List<LatLng> _routePolylinePoints = [];
  List<Marker> _busStopMarkers = [];

  // Gruvbox Dark Palette
  static const Color gruvboxDarkFg = Color(0xFFebdbb2); // Light grey for text
  static const Color gruvboxDarkBlue =
      Color(0xFF458588); // Light blue for routes
  static const Color gruvboxDarkDarkBlue =
      Color(0xFF357578); // Dark blue for bus stops
  static const Color gruvboxDarkGrey = Color(0xFF32302f); // Dark grey for cards
  static const Color gruvboxDarkLightGrey =
      Color(0xaa3c3836); // Light grey for buttons

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
    _loadRouteAndStopsData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      locationService.startLocationTracking(widget.busId, widget.routeId);
      _centerMapOnCurrentLocation(locationService);
    });
  }

  @override
  void dispose() {
    // Detener el seguimiento de ubicación cuando la pantalla se descarte
    Provider.of<LocationService>(context, listen: false).stopLocationTracking();
    super.dispose();
  }

  // Método para manejar la acción de detener la ruta
  void _stopRouteAssignment() {
    // Detener el servicio de ubicación inmediatamente
    Provider.of<LocationService>(context, listen: false).stopLocationTracking();

    // Navegar de regreso a la BusScreen y remover todas las rutas anteriores
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => BusScreen(
          userId: widget.userId,
          username: widget.username,
        ),
      ),
      (Route<dynamic> route) => false, // Elimina todas las rutas de la pila
    );
  }

  // Nuevo método para navegar a la pantalla de configuración
  void _navigateToSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  // ... (El resto de métodos como _loadRouteAndStopsData, _parseBusStopsGeoJson,
  // _centerMapOnCurrentLocation, _fetchCompanyInfo, _zoomIn, _zoomOut
  // y _buildControlButton se mantienen igual) ...

  Future<void> _loadRouteAndStopsData() async {
    if (widget.routeGeoJson != null &&
        widget.routeGeoJson!['features'] != null) {
      final features = widget.routeGeoJson!['features'] as List<dynamic>;
      for (var feature in features) {
        if (feature['geometry'] != null &&
            feature['geometry']['type'] == 'LineString') {
          final coordinates =
              feature['geometry']['coordinates'] as List<dynamic>;
          setState(() {
            _routePolylinePoints = coordinates.map((coord) {
              return LatLng(coord[1] as double, coord[0] as double);
            }).toList();
          });
          break;
        }
      }
    }

    final stopsData =
        await _supabaseService.fetchBusStopsByRouteId(widget.routeId);
    if (stopsData != null && stopsData['features'] != null) {
      setState(() {
        _busStopsGeoJson = stopsData;
        _busStopMarkers = _parseBusStopsGeoJson(stopsData);
      });
    }
  }

  List<Marker> _parseBusStopsGeoJson(Map<String, dynamic> geoJson) {
    List<Marker> markers = [];
    if (geoJson['features'] is List) {
      for (var feature in geoJson['features']) {
        if (feature['geometry'] != null &&
            feature['geometry']['type'] == 'Point') {
          final coordinates =
              feature['geometry']['coordinates'] as List<dynamic>;
          if (coordinates.length == 2) {
            markers.add(
              Marker(
                width: 40.0,
                height: 40.0,
                point:
                    LatLng(coordinates[1] as double, coordinates[0] as double),
                child: const Icon(
                  Icons.location_on,
                  color: gruvboxDarkBlue,
                  size: 30.0,
                ),
              ),
            );
          }
        }
      }
    }
    return markers;
  }

  void _centerMapOnCurrentLocation(LocationService locationService) {
    if (locationService.currentPosition != null) {
      _mapController.move(
        LatLng(locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude),
        15.0,
      );
    } else if (_routePolylinePoints.isNotEmpty) {
      _mapController.move(_routePolylinePoints.first, 14.0);
    }
  }

  Future<void> _fetchCompanyInfo() async {
    setState(() {
      _isFetchingUserInfo = true;
    });
    try {
      final companyInfo =
          await _supabaseService.fetchCompanyInfoByUserId(widget.userId);
      if (companyInfo != null) {
        setState(() {
          _companyName = companyInfo['name'];
        });
      }
    } catch (e) {
      throw Exception(
          'Error al obtener la información de la compañía: ${e.toString()}');
    } finally {
      setState(() {
        _isFetchingUserInfo = false;
      });
    }
  }

  void _zoomIn() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(
        _mapController.camera.center, _mapController.camera.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Detener Ruta'),
              content: const Text(
                  '¿Estás seguro de que quieres detener la asignación de ruta y volver a la selección de bus?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Detener'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    _stopRouteAssignment(); // Llama a la función para detener
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seguimiento'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          automaticallyImplyLeading: false,
          actions: [
            // Botón para detener la ruta
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: _stopRouteAssignment,
                icon: const Icon(Icons.stop, color: gruvboxDarkFg),
                label: const Text('Detener Ruta',
                    style: TextStyle(color: gruvboxDarkFg)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gruvboxDarkDarkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            // Botón para ir a la configuración
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettingsScreen,
              color: Theme.of(context)
                  .appBarTheme
                  .foregroundColor, // Asegura que el color se adapte al tema
            ),
          ],
        ),
        body: Consumer<LocationService>(
          builder: (context, locationService, child) {
            if (locationService.currentPosition != null &&
                (_mapController.camera.center.latitude == 0.0 &&
                    _mapController.camera.center.longitude == 0.0)) {
              _centerMapOnCurrentLocation(locationService);
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: locationService.currentPosition != null
                        ? LatLng(locationService.currentPosition!.latitude,
                            locationService.currentPosition!.longitude)
                        : (_routePolylinePoints.isNotEmpty
                            ? _routePolylinePoints.first
                            : const LatLng(-33.4489, -70.6693)),
                    initialZoom: 15.0,
                    onPositionChanged: (position, hasGesture) {},
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    if (_routePolylinePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePolylinePoints,
                            strokeWidth: 5.0,
                            color: gruvboxDarkDarkBlue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (locationService.currentPosition != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: LatLng(
                                locationService.currentPosition!.latitude,
                                locationService.currentPosition!.longitude),
                            child: const Icon(
                              Icons.directions_bus,
                              color: gruvboxDarkAqua,
                              size: 40.0,
                            ),
                          ),
                        ..._busStopMarkers,
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chofer: ${widget.username}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (_companyName != null)
                            Text(
                              'Compañía: $_companyName',
                              style: const TextStyle(
                                  fontSize: 14, color: gruvboxDarkFg),
                            ),
                          const Divider(),
                          Text(
                            'Bus: ${widget.busBrand} - ${widget.busPatent}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ruta Actual: ${widget.routeName}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: gruvboxDarkBlue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        _buildControlButton(
                          icon: Icons.add,
                          label: '',
                          onPressed: _zoomIn,
                        ),
                        const SizedBox(height: 10),
                        _buildControlButton(
                          icon: Icons.remove,
                          label: '',
                          onPressed: _zoomOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: gruvboxDarkFg),
      label: Text(label, style: const TextStyle(color: gruvboxDarkFg)),
      style: ElevatedButton.styleFrom(
        backgroundColor: gruvboxDarkGrey,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: gruvboxDarkLightGrey, width: 1),
        ),
        elevation: 3,
      ),
    );
  }
}
