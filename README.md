# Tembipuru
# Tembipuru (English below)

Suite avanzada de utilidades Bash para administración de sistemas GNU/Linux (proximamente tambien Windows). Herramientas listas para usuarios desde un menú CLI ordenado, en español, altamente configurable y adaptable.

---

## ¿Qué incluye Tembipuru?

- **Menú principal interactivo:** Accede fácilmente a cada utilidad.
- **Gestión de discos y utilidades** (scripts en `.Discos_y_utilidades`):
  - Listado de discos montados
  - Análisis rápido de espacio en disco
  - Reparación o formateo seguro de discos (con advertencias)
- **Pruebas y configuraciones de red** (scripts en `.Pruebas_y_configuraciones_red`):
  - Estado de servicios de red
  - Test de ping
  - Consulta DNS
  - Traceroute
  - Escaneo rápido de puertos con Nmap (*requiere tenerlo instalado*)
  - Comprobación de puertos abiertos vía netstat
  - **Gestión avanzada de firewall** (con UFW, firewalld o iptables)
- **Integración sencilla**: Añade tus propios scripts siguiendo la estructura del menú.

---

## Ejecución rápida

```bash
bash tembipuru.sh
```

---

## Scripts destacados

### Gestión avanzada de Firewall

Accede desde el menú de red o ejecuta:

```bash
bash .Pruebas_y_configuraciones_red/manage_firewall.sh
```

- El script detecta y utiliza automáticamente el firewall disponible (`ufw`, `firewalld`, `iptables`).
- Acciones desde un menú: activar/desactivar, permitir/bloquear/eliminar reglas y puertos.
- Mensajes claros y seguros; ideal para principiantes y avanzados.
- Soporta Ubuntu, Debian, Fedora, Arch, CentOS y más.

---

## Personalización y colaboración

- Para modificar o añadir scripts, sigue la nomenclatura y los comentarios ya existentes.
- ¡Esperamos tus PRs para nuevas herramientas, mejoras o traducciones!

---

## Requisitos

- Bash 4+
- Dependencias estándar de red y disco según utilidad usada (los scripts avisan e instalan en caso necesario).

---

## Seguridad

- Muchas acciones requieren privilegios de superusuario (`sudo`).
- Los scripts destructivos SIEMPRE piden confirmación.
- No almacena datos personales ni configura nada sin tu consentimiento explícito.

---

## Créditos y contacto

Autor principal: Elias Araujo  
Colaboraciones y mejoras por la comunidad.

---

¿Dudas, sugerencias o mejoras?  
¡Abre un Issue o Pull Request!



# Tembipuru

Advanced Bash tools suite for GNU/Linux systems administration (Windows support coming soon). Ready-to-use tools from an organized CLI menu, in Spanish and English, highly configurable and user-friendly for everyone.

---

## What's included in Tembipuru?

- **Interactive main menu:** Easily access each utility.
- **Disk management and utilities** (scripts in `.Discos_y_utilidades`):
  - List mounted disks
  - Quick disk space analysis
  - Safe disk repair or formatting (with warnings)
- **Network tests and configurations** (scripts in `.Pruebas_y_configuraciones_red`):
  - Network service status
  - Ping test
  - DNS lookup
  - Traceroute
  - Fast port scanning with Nmap (*must be installed*)
  - Open port check via netstat
  - **Advanced firewall management** (with UFW, firewalld or iptables)
- **Easy integration:** Add your own scripts following the menu structure.

---

## Quick start

```bash
bash tembipuru.sh
```

---

## Featured Scripts

### Advanced Firewall Management

Access from the network menu or run directly:

```bash
bash .Pruebas_y_configuraciones_red/manage_firewall.sh
```

- Automatically detects and uses the available firewall (`ufw`, `firewalld`, `iptables`).
- Actions via menu: enable/disable, allow/block/delete rules and ports.
- Clear and safe messages; ideal for beginners and advanced users.
- Supports Ubuntu, Debian, Fedora, Arch, CentOS, and more.

---

## Customization and contributing

- To modify or add scripts, follow the existing naming and comments style.
- Pull Requests for new tools, improvements or translations are welcome!

---

## Requirements

- Bash 4+
- Standard disk and network dependencies as used by each utility (the scripts will warn and install if needed).

---

## Security

- Many actions require superuser privileges (`sudo`).
- Destructive scripts ALWAYS request confirmation.
- No personal data is stored and nothing is configured without your explicit consent.

---

## Credits & Contact

Main author: Elias Araujo  
Community collaborations and improvements welcome.

---

Questions, suggestions or improvements?  
Open an Issue or Pull Request!
