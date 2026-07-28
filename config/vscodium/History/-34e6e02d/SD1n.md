# Ficha técnica del sistema
## openSUSE Tumbleweed + Niri + Noctalia

**Última actualización:** 27 de julio de 2026

---

# Filosofía del sistema

Objetivos:

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

No busca una apariencia "gamer" ni "cyberpunk".

---

# Hardware

Equipo

ASUS VivoBook M1603QA

CPU

AMD Ryzen 5 5600H

- 6 núcleos
- 12 hilos

GPU

AMD Radeon Vega integrada

RAM

16 GB

Pantalla

- 16"
- 1920×1200
- 60 Hz

Almacenamiento

SSD NVMe

Sistema de archivos

BTRFS

---

# Sistema operativo

Distribución

openSUSE Tumbleweed

Kernel

Linux 7.1.4

Shell

bash

Sesión

Wayland

Compositor

Niri 26.04

---

# Arquitectura del escritorio

Login

- greetd

Gestor de sesión

- UWSM (Universal Wayland Session Manager)

Compositor

- Niri

Tema principal

- Noctalia 5.0.0-beta5

Launcher

- Noctalia Launcher

Panel

- Noctalia Panel

Dock

- Noctalia Dock

Bloqueo

- Noctalia Lock

Notificaciones

- Noctalia Notifications

Wallpaper

- Noctalia Wallpaper

Terminal

- kitty

Capturas

- Niri Screenshot

GTK

Actualmente

- Adwaita

Iconos

Actualmente

- Adwaita

Cursores

Actualmente

- Adwaita

---

# Configuración actual de Niri

Layout

- Columnas

Gaps

- 16 px

Esquinas redondeadas

- 20 px

Blur

- Activado

Focus Ring

- Activado

Color

```text
#7fc8ff
```

Bordes

- Desactivados

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
- Notificaciones
- Wallpaper
- Focus Ring
- Scroll por columnas

---

# Investigación técnica

## Problema de interacción por teclado en Noctalia

Se realizó una investigación completa utilizando las herramientas IPC de Niri.

Conclusiones

- Los paneles utilizan layer-shell.
- Niri concede correctamente:

```text
Keyboard interactivity: exclusive
```

Namespaces identificados

Launcher

```text
noctalia-panel
```

Control Center

```text
noctalia-attached-panel
```

Resultado

No se encontró ningún problema en la configuración de Niri.

El fallo fue provocado por un estado inconsistente del daemon de Noctalia.

Solución

```bash
pkill noctalia
sleep 1
noctalia --daemon
```

Alias de mantenimiento

```bash
alias noctalia-r='pkill noctalia && sleep 1 && noctalia --daemon'
```

Estado

**Resuelto.**

---

# Objetivos estéticos pendientes

## Tema GTK

Evaluar

- Nordic
- Graphite
- Colloid
- Orchis
- Fluent

---

## Cursores

Evaluar

- Bibata Modern Ice
- Bibata Classic

---

## Iconos

Evaluar

- Nordic
- Colloid
- Tela
- MoreWaita
- Reversal

---

## Wallpapers

Construir una colección basada en

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

Revisar

- CSS
- transparencia
- radios
- hover
- colores secundarios
- selección

Eliminar completamente los tonos morados.

---

## Launcher

Modificar

- colores secundarios
- hover
- selección
- bordes

---

## Dock

Identificar el componente exacto.

Personalizar

- fondo
- blur
- hover
- selección

---

## GTK

Buscar una paleta basada en

- azul grisáceo
- carbón
- grafito
- pizarra

---

# Atajos

Pendiente reorganización completa.

Objetivos

- eliminar duplicados
- simplificar
- mantener consistencia
- aprovechar mejor el modelo por columnas

---

# Componentes a estudiar

## Niri

- reglas
- IPC
- overview
- workspaces
- animaciones

## Noctalia

- daemon
- panel
- launcher
- dock
- CSS
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

Pendiente

- revisar integración entre greetd y gnome-keyring
- desbloqueo automático del keyring
- eliminar el aviso al iniciar sesión
- verificar compatibilidad con Electron, Git y navegadores

---

### Wallpaper

Actualmente el wallpaper es gestionado por **Noctalia**.

Existe un `spawn` heredado de:

```text
swaybg
```

en `~/.config/niri/config.kdl`.

Pendiente

- eliminar completamente la ejecución de `swaybg`
- dejar a Noctalia como único gestor del fondo de pantalla

---

### Documentación

Documentar completamente

- greetd
- UWSM
- Noctalia
- Niri
- estructura de configuración

---

# Estado del proyecto

Base del sistema

```
█████████████████░░░ 85%
```

Estética

```
██████████████░░░░░░ 70%
```

Atajos

```
██████████░░░░░░░░░░ 50%
```

Integración visual

```
█████████████░░░░░░░ 72%
```

Productividad

```
██████████████████░░ 90%
```

Mantenimiento

```
█████████████████░░░ 85%
```