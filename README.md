# 🚌 Bus Tracker Chofer

> *“Porque incluso el bus rural merece GPS de primera.”*  

**Bus Tracker Chofer** es la aplicación móvil que permite a los conductores del transporte público rural chileno compartir y gestionar en tiempo real la ubicación de su bus y su recorrido diario.  
Forma parte de un ecosistema mayor de monitoreo que incluye una app para pasajeros y un panel web de operaciones.

---

## 🚦 Flujo de uso

| Paso | Acción | Pantalla |
|------|--------|----------|
| 1 | Iniciar sesión / crear cuenta | `login_screen` / `create_account_screen` |
| 2 | Seleccionar bus asignado | `bus_screen` |
| 3 | Seleccionar ruta | `route_screen` |
| 4 | Compartir ubicación en vivo y controlar el mapa | `map_screen` |
| 5 | Ajustes de tema y preferencias | `settings_screen` |

![rutaDeUsoAppchofer](https://github.com/user-attachments/assets/7733974a-70a4-4f6f-b1da-5bca90b2cee8)

---

## 🗺️ Arquitectura de componentes

El proyecto sigue un patrón **MVC ligero**:

![mvc](https://github.com/user-attachments/assets/88e6a707-dcfc-40a3-824a-738038dae9b7)

- **Vistas** (`*_screen`) → UI y UX en Flutter.  
- **Servicios** (`*_service`, `*_provider`) → lógica de negocio y acceso a plataforma.  
- **Variables de entorno** (credenciales) → parámetros externos inyectados en tiempo de compilación.  
- **`main.dart`** → punto de arranque; configura Supabase y decide la primera pantalla.

---

## ⚙️ Requisitos previos

| Herramienta | Versión recomendada |
|-------------|--------------------|
| Flutter SDK | >= 3.22.0 |
| Dart | Empaquetado con Flutter |
| Android SDK | API 33 (Android 13) o superior |
| Supabase CLI (opcional) | >= 1.0.0 |
| Dispositivo físico o emulador Android | Con servicios de Google Play |

> **Nota:** iOS aún no está soportado oficialmente (pull-requests bienvenidos).

### Dependencias principales del proyecto

| Paquete | Uso |
|---------|-----|
| `flutter_map: ^6.2.1` | Renderizado de mapas offline/online |
| `latlong2` | Manipulación de coordenadas geográficas |
| `supabase_flutter` | Autenticación y base de datos en Supabase |
| `geolocator` | Acceso a servicios GPS |
| `provider` | Gestión ligera de estado (tema, sesión) |

Consulta `pubspec.yaml` para la lista completa.

---

## 🔧 Instalación y ejecución

1.- Clonar repositorio

```bash
$ git clone https://github.com/diegopastabass/busTrackerChofer
$ cd busTrackerChofer
```

2.- Instalar dependencias

` bash
$ flutter pub get
`

3.- Compilar aplicación en dispositivo android

` bash
$ flutter devices
$ flutter run <device-id>
`

---

## ❓ FAQ
1.- "Flutter no detecta mi dispositivo"


Asegurate de tener activado el modo desarrollador y debbuging via usb


2.- "La aplicación no muestra la ubicación en tiempo real"


Asegurate de aceptar los permisos de ubicación solicitados.


3.- "El mapa se queda en blanco"

La aplicación depende de un servicio de mapa externo `OpenStreetMap` por lo que debe tener conexión a internet.
