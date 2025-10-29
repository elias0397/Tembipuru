# Pruebas y configuraciones de red

Carpeta para scripts de prueba y utilidades de red para el proyecto Rembipuru.

Advertencias:
- Algunos comandos pueden requerir privilegios (sudo).
- Las acciones destructivas o que reinician servicios requieren confirmación explícita.

Scripts incluidos:
- `test_ping.sh` : Realiza un ping seguro a un destino (por defecto 8.8.8.8).
  Uso: `./test_ping.sh [host] [count]`

- `config_network.sh` : Submenú para mostrar interfaces, rutas, DNS y opcionalmente reiniciar NetworkManager.
  Uso: `./config_network.sh`

Cómo contribuir:
- Agrega más pruebas o utilidades dentro de esta carpeta siguiendo el patrón de "no ejecutar cambios sin confirmación".
