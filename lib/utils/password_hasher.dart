// lib/utils/password_hasher.dart
import 'dart:convert';
import 'package:crypto/crypto.dart'; // Importa la librería crypto

class PasswordHasher {
  // ADVERTENCIA DE SEGURIDAD:
  // Este es un salt estático para propósitos de demostración.
  // En una aplicación de producción, DEBES usar un salt único y aleatorio para CADA usuario.
  // Además, SHA256 por sí solo no es suficiente para contraseñas. Deberías usar funciones
  // de derivación de claves (KDF) como bcrypt o Argon2id (provistas por Supabase Auth
  // internamente o librerías externas) que son resistentes a ataques de fuerza bruta y diccionarios.
  static const String _salt =
      'mi_salt_secreto_y_unico'; // Reemplaza con un salt más seguro si es posible

  static String hashPassword(String password) {
    // Combina la contraseña con el salt y luego hashea
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String storedHash) {
    // Hashea la contraseña ingresada con el mismo salt y compara
    final enteredHash = hashPassword(password);
    return enteredHash == storedHash;
  }
}
