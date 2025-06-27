## Bus Tracker App Chofer

Como parte de una solución de software que busca acercar la tecnología de geolocalización al transporte público rural, una rama del transporte público chileno que muchas veces es dejado de lado, la App de Chofer es un componente esencial.
Esta App permite a los choferes gestionar los recorridos que hagan durante un día normal de trabajo.


# Ruta de uso de la aplicación


![rutaDeUsoAppchofer](https://github.com/user-attachments/assets/7733974a-70a4-4f6f-b1da-5bca90b2cee8)


# Diagrama de Interacción entre Componentes


![mvc](https://github.com/user-attachments/assets/88e6a707-dcfc-40a3-824a-738038dae9b7)


# Guía de Instalación de App Chofer


Para instalar BusTrackerChofer se necesita tener instalado en el equipo el framework flutter, y todo el paquete de desarrollo asociado a aplicaciones móviles android. Conoce como instalar flutter [aquí](https://flutter.dev/?utm_source=google&utm_medium=cpc&utm_campaign=pmax_gads_brand&utm_content=latam_latam&gclsrc=aw.ds&gad_source=1&gad_campaignid=19926981051&gclid=CjwKCAjw3_PCBhA2EiwAkH_j4gdNFBFy55I0VGvmcsPPALeOUs3HnNfCdOg01QePvzwyfi9tpYk8aBoCnysQAvD_BwE)

1.- Clonar repositorio al equipo de compilación:

` bash
$ git clone https://github.com/diegopastabass/busTrackerChofer
$ cd busTrackerChofer
`

2.- Instalar dependencias

` bash
$ flutter pub get
`

3.- Compilar aplicación en dispositivo android

` bash
$ flutter devices
$ flutter run <device-id>
`
