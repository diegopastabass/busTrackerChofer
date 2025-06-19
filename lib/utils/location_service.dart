import 'dart:async'; // Importar para usar Timer

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importar Supabase

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  LocationPermission? _permissionStatus;
  StreamSubscription<Position>?
      _positionStreamSubscription; // Cambiado a StreamSubscription
  Timer? _locationUploadTimer; // Temporizador para subir la ubicación

  // Supabase client instance
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Position? get currentPosition => _currentPosition;
  LocationPermission? get permissionStatus => _permissionStatus;

  // Propiedades para almacenar el busId y routeId que se están rastreando
  String? _trackingBusId;
  String? _trackingRouteId; // Añadir para asociar la ubicación a la ruta

  LocationService() {
    _checkPermissionAndGetLocation();
    _listenToLocationUpdates();
  }

  // Método para iniciar el seguimiento y la carga de ubicación
  void startLocationTracking(String busId, String routeId) {
    _trackingBusId = busId;
    _trackingRouteId = routeId;
    _startLocationUploadTimer();
  }

  // Método para detener el seguimiento y la carga de ubicación
  void stopLocationTracking() {
    _trackingBusId = null;
    _trackingRouteId = null;
    _locationUploadTimer?.cancel();
    _locationUploadTimer = null;
  }

  // Verifica el estado de los permisos de ubicación y obtiene la ubicación actual
  Future<void> _checkPermissionAndGetLocation() async {
    _permissionStatus = await Geolocator.checkPermission();
    if (_permissionStatus == LocationPermission.denied) {
      _permissionStatus = await Geolocator.requestPermission();
      if (_permissionStatus == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (_permissionStatus == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación fueron denegados permanentemente. Por favor, habilítalos desde la configuración de la aplicación.');
    }

    if (_permissionStatus == LocationPermission.whileInUse ||
        _permissionStatus == LocationPermission.always) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        notifyListeners();
      } catch (e) {
        throw Exception(
            'Error al obtener la ubicación actual: ${e.toString()}');
      }
    }
  }

  // Escucha las actualizaciones de ubicación en tiempo real
  void _listenToLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Actualiza cada 1 metro de cambio
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
      _currentPosition = position;
      notifyListeners();
    }, onError: (e) {
      throw Exception('Error en el stream de ubicación: ${e.toString()}');
    });
  }

  // 1. Crea un servicio que tome la ubicación actual del dispositivo lat y lng
  // y la mande a la tabla bus_location.
  Future<void> _uploadCurrentLocation() async {
    if (_currentPosition != null &&
        _trackingBusId != null &&
        _trackingRouteId != null) {
      try {
        await _supabaseClient.from('bus_location').insert({
          'bus_id': _trackingBusId,
          'route_id':
              _trackingRouteId, // Asegúrate de tener esta columna en tu tabla bus_location
          'lat': _currentPosition!.latitude,
          'lng': _currentPosition!.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        throw Exception(
            'Error al subir la ubicación a Supabase: ${e.toString()}');
      }
    } else {
      throw Exception(
          'No se puede subir la ubicación: currentPosition es null, o trackingBusId/RouteId no están configurados.');
    }
  }

  // 3. La ubicación se debe enviar cada 20 segundos a la bd.
  void _startLocationUploadTimer() {
    // Cancela cualquier temporizador existente para evitar duplicados
    _locationUploadTimer?.cancel();
    _locationUploadTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _uploadCurrentLocation();
    });
  }

  // Limpiar recursos cuando el servicio ya no sea necesario
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationUploadTimer?.cancel();
    super.dispose();
  }

  // Obtiene la última ubicación conocida
  Future<LatLng?> getLastKnownLocation() async {
    final Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }
}
