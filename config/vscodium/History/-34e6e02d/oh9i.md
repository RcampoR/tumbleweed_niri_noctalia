# Ficha técnica del sistema
## openSUSE Tumbleweed + Niri + Noctalia

**Última actualización:** 28 de julio de 2026

---

# Filosofía del sistema

## Objetivos

- Sistema moderno basado completamente en Wayland.
- Rolling Release (openSUSE Tumbleweed).
- Escritorio extremadamente ligero.
- Enfoque científico y de productividad.
- Apariencia sobria inspirada en materiales naturales.
- Bajo mantenimiento.
- Evitar efectos visuales innecesarios.
- Mantener coherencia visual entre todos los componentes.

La estética buscada puede resumirse como:

> **Organic Tech · Basalt · Slate Paper**

Inspirada en:

- papel mate
- cartón prensado
- pizarra
- aluminio anodizado
- vidrio esmerilado
- colores azul grisáceo poco saturados

No busca una apariencia "gamer", RGB o cyberpunk.

---

# Hardware

## Equipo

ASUS VivoBook M1603QA

## CPU

AMD Ryzen 5 5600H

- 6 núcleos
- 12 hilos

## GPU

AMD Radeon Vega integrada

## RAM

16 GB

## Pantalla

- 16"
- 1920×1200
- 60 Hz

## Almacenamiento

SSD NVMe

## Sistema de archivos

BTRFS

---

# Sistema operativo

## Distribución

openSUSE Tumbleweed

## Kernel

Linux 7.1.4

## Shell

bash

## Sesión

Wayland

## Compositor

Niri 26.04

---

# Arquitectura del escritorio

## Inicio de sesión

- greetd

## Gestor de sesión

- UWSM (Universal Wayland Session Manager)

## Compositor

- Niri

## Shell gráfico

- Noctalia 5.0.0-beta5

## Componentes principales

- Launcher
- Panel
- Dock
- Control Center
- Session Menu
- Notifications
- Wallpaper
- Lockscreen

## Terminal

kitty

## Navegador

Zen Browser (Flatpak)

## Gestor de archivos

Thunar

## Capturas

Niri Screenshot

## GTK

Actualmente

- Adwaita

## Iconos

Actualmente

- Adwaita

## Cursores

Actualmente

- Adwaita

---

# Configuración actual de Niri

## Layout

Columnas

## Gaps

16 px

## Esquinas

20 px

## Blur

Activado

## Focus Ring

Activado

Color

```text
#7fc8ff
```

## Bordes

Desactivados

---

# Estado actual

## Funcionando correctamente

- greetd
- UWSM
- Niri
- Noctalia
- Blur
- Launcher
- Dock
- Barra
- Control Center
- Calendario
- Menú de sesión
- Historial del portapapeles
- Notificaciones
- Wallpaper
- Focus Ring
- Scroll por columnas

---

# Investigación técnica

## Problema de interacción por teclado en Noctalia

Se realizó una investigación completa utilizando las herramientas IPC de Niri.

### Conclusiones

Los paneles utilizan layer-shell.

Niri concede correctamente:

```text
Keyboard interactivity: exclusive
```

### Namespaces identificados

Launcher

```text
noctalia-panel
```

Control Center

```text
noctalia-attached-panel
```

### Resultado

No se encontró ningún problema en la configuración de Niri.

El fallo fue provocado por un estado inconsistente del daemon de Noctalia.

### Solución

```bash
pkill noctalia
sleep 1
noctalia --daemon
```

### Alias de mantenimiento

```bash
alias noctalia-r='pkill noctalia && sleep 1 && noctalia --daemon'
```

### Estado

**Resuelto.**

---

# Aprendizajes

## Arquitectura IPC de Noctalia

Uno de los descubrimientos más importantes durante la migración fue comprender la arquitectura de control de Noctalia.

Toda la interfaz del shell se controla mediante un único punto de entrada:

```bash
noctalia msg ...
```

Los paneles utilizan la forma general:

```bash
noctalia msg panel-toggle <panel>
```

Ejemplos:

```bash
noctalia msg panel-toggle launcher
noctalia msg panel-toggle clipboard
noctalia msg panel-toggle control-center
noctalia msg panel-toggle wallpaper
noctalia msg panel-toggle session
```

Las acciones del sistema utilizan comandos propios:

```bash
noctalia msg session lock
noctalia msg volume-up
noctalia msg brightness-up
noctalia msg notification-dnd-toggle
```

Esta lógica simplifica enormemente la integración con Niri, ya que basta con lanzar los comandos IPC oficiales desde cualquier atajo del compositor.

---

# Atajos personalizados

Se adoptó una organización clara de las teclas modificadoras.

## Super

Reservada para:

- gestión de ventanas
- columnas
- workspaces
- funciones propias de Niri

## Alt

Reservada para:

- aplicaciones
- paneles de Noctalia
- herramientas del sistema

Actualmente:

| Atajo | Acción |
|--------|--------|
| Alt + Z | Zen Browser |
| Alt + E | Thunar |
| Alt + Esc | btop |
| Alt + V | Historial del portapapeles |
| Alt + H | Control Center |
| Alt + C | Calendario |
| Alt + KP_* | Menú de energía |
| Alt + KP_/ | Bloquear sesión |

---

# Portapapeles

El sistema utiliza el gestor de portapapeles nativo de Noctalia.

Abrir historial:

```bash
noctalia msg panel-toggle clipboard
```

Limpiar historial:

```bash
noctalia msg clipboard-clear
```

No se utilizan gestores externos como:

- cliphist
- fuzzel
- rofi
- wofi
- walker
- tofi

---

# Objetivos estéticos pendientes

## Tema GTK

Evaluar:

- Nordic
- Graphite
- Colloid
- Orchis
- Fluent

---

## Cursores

Evaluar:

- Bibata Modern Ice
- Bibata Classic

---

## Iconos

Evaluar:

- Nordic
- Colloid
- Tela
- MoreWaita
- Reversal

---

## Wallpapers

Construir una colección basada en:

- Organic Minimalism
- Wabi-Sabi
- Basalt
- Slate
- Scandinavian
- Editorial
- Soft Industrial

---

# Personalización pendiente

## Panel

Revisar:

- CSS
- transparencia
- radios
- hover
- colores secundarios
- selección

Eliminar completamente los tonos morados.

---

## Launcher

Modificar:

- colores secundarios
- hover
- selección
- bordes

---

## Dock

Personalizar:

- fondo
- blur
- hover
- selección

---

## GTK

Buscar una paleta basada en:

- azul grisáceo
- grafito
- carbón
- pizarra

---

# Componentes a estudiar

## Niri

- reglas
- IPC
- overview
- workspaces
- animaciones

## Noctalia

- CSS
- panel
- dock
- launcher
- plugins

## GTK

- temas
- iconos
- cursores

## Wayland

- layer-shell
- xdg-desktop-portal

---

# Deuda técnica

## Alta prioridad

### GNOME Keyring

Actualmente aparece un aviso al iniciar sesión o abrir VSCodium indicando que debe crearse o desbloquearse un keyring.

Pendiente:

- revisar integración entre greetd y gnome-keyring
- desbloqueo automático del keyring
- eliminar el aviso al iniciar sesión
- verificar compatibilidad con Electron, Git y navegadores

---

### Configuración heredada

Todavía existen algunos elementos heredados de la etapa con Sway que deben limpiarse.

Pendiente:

- eliminar definitivamente `swaybg` del archivo `config.kdl` (ya no se utiliza porque Noctalia gestiona el fondo de pantalla)
- revisar configuraciones heredadas que ya no tengan utilidad

---

# Documentación pendiente

Completar documentación técnica de:

- greetd
- UWSM
- Noctalia
- Niri
- estructura de configuración
- flujo completo de inicio de sesión Wayland

---

# Estado del proyecto

## Base del sistema

```text
██████████████████░░ 90%
```

## Estética

```text
███████████████░░░░░ 75%
```

## Atajos

```text
████████████████░░░░ 80%
```

## Integración visual

```text
████████████████░░░░ 80%
```

## Productividad

```text
███████████████████░ 95%
```

## Mantenimiento

```text
█████████████████░░░ 85%
```