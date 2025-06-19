// lib/screens/bus_screen.dart
import 'package:flutter/material.dart';
import 'package:bus_tracker_chofer/utils/supabase_service.dart';
// import 'package:bus_tracker_chofer/screens/map_screen.dart'; // Ya no se navega directamente aquí
import 'package:bus_tracker_chofer/screens/route_screen.dart'; // Importa la nueva pantalla de rutas

class BusScreen extends StatefulWidget {
  final String userId;
  final String username;

  const BusScreen({super.key, required this.userId, required this.username});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  String? _companyId;
  String? _companyName;
  List<Map<String, dynamic>> _buses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Gruvbox Dark Palette

  static const Color gruvboxDarkFg = Color(0xFFebdbb2); // Light grey for text
  static const Color gruvboxDarkRed = Color(0xaaFB4934); // Red for accents
  static const Color gruvboxDarkBlue =
      Color(0xFF458588); // Light blue for routes
  static const Color gruvboxDarkDarkBlue =
      Color(0xFF357578); // Dark blue for busstops
  static const Color gruvboxDarkAppBar =
      Color(0xaa32202f); // Light black for app bars

  // Variables para almacenar los datos del bus seleccionado
  String? _selectedBusId;
  String? _selectedBusBrand;
  String? _selectedBusPatent;

  @override
  void initState() {
    super.initState();
    _fetchCompanyAndBuses();
  }

  Future<void> _fetchCompanyAndBuses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final companyInfo =
          await _supabaseService.fetchCompanyInfoByUserId(widget.userId);

      if (companyInfo != null) {
        _companyId = companyInfo['id'];
        _companyName = companyInfo['name'];
        if (_companyId != null) {
          final fetchedBuses =
              await _supabaseService.fetchBusByCompanyId(_companyId!);
          setState(() {
            _buses = fetchedBuses;
          });
        } else {
          setState(() {
            _errorMessage =
                'No se encontró un ID de compañía para este usuario.';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'No se encontró información de la compañía para este usuario.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectBus(Map<String, dynamic> bus) {
    setState(() {
      _selectedBusId = bus['id'];
      _selectedBusBrand = bus['brand'];
      _selectedBusPatent = bus['patent'];
    });
  }

  void _navigateToRouteScreen() {
    if (_selectedBusId != null && _companyId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RouteScreen(
            userId: widget.userId,
            username: widget.username,
            companyId: _companyId!,
            busId: _selectedBusId!,
            busBrand: _selectedBusBrand!,
            busPatent: _selectedBusPatent!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un bus antes de continuar.'),
          backgroundColor: gruvboxDarkAppBar,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Bus'),
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
                              fontSize: 16, color: gruvboxDarkFg),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchCompanyAndBuses,
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
                        _companyName != null
                            ? 'Buses de ${_companyName!}:'
                            : 'Selecciona un bus:',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: _buses.isEmpty
                          ? const Center(
                              child: Text(
                                  'No hay buses disponibles para tu compañía.'),
                            )
                          : ListView.builder(
                              itemCount: _buses.length,
                              itemBuilder: (context, index) {
                                final bus = _buses[index];
                                final isSelected = _selectedBusId == bus['id'];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  elevation: isSelected ? 8 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isSelected
                                        ? const BorderSide(
                                            color: gruvboxDarkDarkBlue,
                                            width: 2)
                                        : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    title: Text(
                                      '${bus['brand']} - ${bus['patent']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? gruvboxDarkDarkBlue
                                            : gruvboxDarkFg,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle,
                                            color: gruvboxDarkDarkBlue,
                                            size: 28)
                                        : null,
                                    onTap: () => _selectBus(bus),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _selectedBusId != null
                            ? _navigateToRouteScreen
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gruvboxDarkDarkBlue,
                          foregroundColor: gruvboxDarkFg,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Continuar a Rutas', // Texto cambiado
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
