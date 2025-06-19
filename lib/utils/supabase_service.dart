// lib/utils/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_tracker_chofer/utils/password_hasher.dart';

class SupabaseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<Map<String, dynamic>?> authenticateUser(
      String email, String password) async {
    try {
      final response = await _supabaseClient
          .from('User')
          .select()
          .eq('email', email)
          .single();

      final storedHash = response['password_hash'] as String;
      if (PasswordHasher.verifyPassword(password, storedHash)) {
        return response;
      } else {
        throw Exception('Contraseña incorrecta.');
      }
    } catch (e) {
      throw Exception('Error de autenticación: ${e.toString()}');
    }
  }

  Future<void> createUser(
      {required String email,
      required String username,
      required String password}) async {
    try {
      final hashedPassword = PasswordHasher.hashPassword(password);
      await _supabaseClient.from('User').insert({
        'email': email,
        'user_name': username,
        'password_hash': hashedPassword,
      });
    } catch (e) {
      throw Exception('Error al crear cuenta: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> fetchCompanyInfoByUserId(String userId) async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('user_company')
          .select('Company:company_id(id, name)')
          .eq('user_id', userId);

      if (response.isNotEmpty && response.first['Company'] != null) {
        return {
          'id': response.first['Company']['id'].toString(),
          'name': response.first['Company']['name'] as String,
        };
      }
      return null;
    } catch (e) {
      throw Exception(
          'Error al obtener la información de la compañía: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBusByCompanyId(
      String companyId) async {
    try {
      final List<Map<String, dynamic>> buses = await _supabaseClient
          .from('Bus')
          .select('id, brand, patent')
          .eq('company_id', companyId);

      return buses
          .map((bus) => {
                'id': bus['id'].toString(),
                'brand': bus['brand'],
                'patent': bus['patent'],
              })
          .toList();
    } catch (e) {
      throw Exception('Error al cargar la lista de buses.');
    }
  }

  Future<String?> fetchDriverIdByUserCompanyId(String userCompanyId) async {
    try {
      final response = await _supabaseClient
          .from('Driver')
          .select('id')
          .eq('user_company_id', userCompanyId)
          .single();

      if (response['id'] != null) {
        return response['id'].toString();
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el ID del chofer: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRoutesByCompanyId(
      String companyId) async {
    try {
      final List<Map<String, dynamic>> routes = await _supabaseClient
          .from('Route')
          .select('id, name, route_json')
          .eq('company_id', companyId);

      return routes.map((route) {
        final String routeId = route['id']?.toString() ?? '';
        final String routeName = route['name']?.toString() ?? '';
        final Map<String, dynamic>? routeJson =
            route['route_json'] as Map<String, dynamic>?;

        return {
          'id': routeId,
          'name': routeName,
          'route_json': routeJson,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al cargar la lista de rutas: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> fetchBusStopsByRouteId(String routeId) async {
    try {
      final response = await _supabaseClient
          .from('bus_stops')
          .select('stops_json')
          .eq('route_id', routeId)
          .single();

      if (response['stops_json'] != null) {
        return response['stops_json'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception(
          'Error al obtener paradas de bus para la ruta ${routeId.toString()}: ${e.toString()}');
    }
  }

  Future<void> assignRouteToBusAndDriver({
    required String routeId,
    required String busId,
    required String driverId,
  }) async {
    try {
      await _supabaseClient.from('route_assignment').insert({
        'route_id': routeId,
        'bus_id': busId,
        'driver_id': driverId,
      });
    } catch (e) {
      throw Exception(
          'Error al asignar la ruta al bus y chofer. ${e.toString()}');
    }
  }
}
