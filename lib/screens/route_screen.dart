// lib/screens/route_screen.dart
import 'package:flutter/material.dart';
import 'package:bus_tracker_chofer/utils/supabase_service.dart';
import 'package:bus_tracker_chofer/screens/map_screen.dart';

class RouteScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String companyId;
  final String busId;
  final String busBrand;
  final String busPatent;

  const RouteScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.companyId,
    required this.busId,
    required this.busBrand,
    required this.busPatent,
  });

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Gruvbox Dark Palette
  static const Color gruvboxDarkFg = Color(0xFFebdbb2); // Light grey for text
  static const Color gruvboxDarkRed = Color(0xaaFB4934); // Red for accents
  static const Color gruvboxDarkBlue =
      Color(0xFF458588); // Light blue for routes
  static const Color gruvboxDarkLightGrey =
      Color(0xaa3c3836); // Light grey for buttons

  String? _selectedRouteId;
  String? _selectedRouteName;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _fetchRoutesAndDriverId();
  }

  Future<void> _fetchRoutesAndDriverId() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _driverId =
          await _supabaseService.fetchDriverIdByUserCompanyId(widget.userId);

      if (_driverId == null) {
        setState(() {
          _errorMessage =
              'No se pudo encontrar el ID del chofer asociado a tu cuenta.';
        });
        return;
      }

      final fetchedRoutes =
          await _supabaseService.fetchRoutesByCompanyId(widget.companyId);
      setState(() {
        _routes = fetchedRoutes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las rutas: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectRoute(Map<String, dynamic> route) {
    setState(() {
      _selectedRouteId = route['id'];
      _selectedRouteName = route['name'];
    });
  }

  Future<void> _navigateToMapScreen() async {
    if (_selectedRouteId != null && _driverId != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _supabaseService.assignRouteToBusAndDriver(
          routeId: _selectedRouteId!,
          busId: widget.busId,
          driverId: _driverId!,
        );

        final selectedRoute =
            _routes.firstWhere((r) => r['id'] == _selectedRouteId);
        final Map<String, dynamic>? routeJsonData = selectedRoute['route_json'];

        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MapScreen(
              userId: widget.userId,
              username: widget.username,
              busId: widget.busId,
              busBrand: widget.busBrand,
              busPatent: widget.busPatent,
              routeId: _selectedRouteId!,
              routeName: _selectedRouteName!,
              routeGeoJson: routeJsonData,
            ),
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _errorMessage ?? 'Error al asignar la ruta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una ruta antes de continuar.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ruta'),
        backgroundColor: gruvboxDarkBlue,
        foregroundColor: gruvboxDarkFg,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: gruvboxDarkRed, size: 48),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, color: gruvboxDarkRed),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchRoutesAndDriverId,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Selecciona una ruta para el bus "${widget.busBrand} - ${widget.busPatent}":',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: _routes.isEmpty
                          ? const Center(
                              child: Text(
                                  'No hay rutas disponibles para tu compañía.'),
                            )
                          : ListView.builder(
                              itemCount: _routes.length,
                              itemBuilder: (context, index) {
                                final route = _routes[index];
                                final isSelected =
                                    _selectedRouteId == route['id'];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  elevation: isSelected ? 8 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isSelected
                                        ? const BorderSide(
                                            color: gruvboxDarkBlue, width: 2)
                                        : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    title: Text(
                                      route['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? gruvboxDarkBlue
                                            : gruvboxDarkFg,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle,
                                            color: gruvboxDarkLightGrey,
                                            size: 28)
                                        : null,
                                    onTap: () => _selectRoute(route),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _selectedRouteId != null && _driverId != null
                            ? _navigateToMapScreen
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gruvboxDarkBlue,
                          foregroundColor: gruvboxDarkFg,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: gruvboxDarkFg)
                            : const Text(
                                'Continuar al Mapa',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
