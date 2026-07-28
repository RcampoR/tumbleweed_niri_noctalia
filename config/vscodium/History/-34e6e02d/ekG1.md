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

> Organic Tech / Basalt / Slate Paper

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

Equipo:

ASUS VivoBook M1603QA

CPU

AMD Ryzen 5 5600H
6 núcleos
12 hilos

GPU

AMD Radeon Vega integrada

RAM

16 GB

Pantalla

16"

1920×1200

60 Hz

SSD

NVMe
460 GB

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

- Noctalia

Launcher

- Noctalia Launcher

Barra

- Noctalia Panel

Bloqueo

- Noctalia Lock

Wallpaper

- swaybg

Terminal

- kitty

Notificaciones

- Noctalia

Capturas

- Niri

GTK

Actualmente:

Adwaita

Iconos

Actualmente:

Adwaita

Cursor

Actualmente:

Adwaita

---

# Configuración actual de Niri

Layout por columnas.

Gaps

16 px

Esquinas redondeadas

20 px

Blur global

Activado

Focus Ring

Activo

Color

#7fc8ff

Border

Desactivado

Wallpaper

swaybg

---

# Filosofía visual

Estado actual

★★★★★☆☆☆☆☆

Ya existe una identidad visual.

Predominan:

- azul
- gris oscuro
- negro suave

El wallpaper transmite descanso visual.

Todavía existen elementos con colores morados que rompen la coherencia.

---

# Objetivos estéticos pendientes

## Tema GTK

Pendiente

Evaluar:

- Graphite
- Colloid
- Orchis
- Fluent
- Nordic

---

## Cursores

Pendiente

Evaluar

- Bibata Modern Ice
- Bibata Classic

---

## Iconos

Pendiente

Buscar una familia coherente.

Posibles candidatos

- Nordic
- Colloid
- Tela
- MoreWaita
- Reversal

---

## Wallpapers

Pendiente construir una colección.

Estilo buscado

- Organic Minimalism
- Wabi-Sabi
- Material Design
- Paper Cut
- Slate
- Basalt
- Editorial
- Scandinavian
- Muted Blue
- Soft Industrial

---

# Personalización pendiente

## Waybar / Panel

Revisar

- color del fondo
- transparencia
- radios
- hover
- color de selección

---

## Launcher

Modificar

- colores secundarios
- color de selección
- borde
- hover

Eliminar tonos morados.

---

## Dock

Identificar componente exacto.

Modificar

- fondo
- transparencia
- color de selección

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

- simplificar
- eliminar duplicados
- mantener consistencia
- aprovechar el modelo por columnas de Niri

Se revisará completamente el bloque binds del archivo config.kdl.

---

# Problemas pendientes

## Prioridad alta

### Los paneles no aceptan navegación mediante teclado

Actualmente:

✔ Mouse funciona

✘ Teclado no funciona

Afecta:

- launcher
- gestor de energía
- portapapeles
- paneles de Noctalia

Debe investigarse:

- focus de layer-shell
- keyboard interactivity
- configuración propia de Noctalia
- soporte de Niri

---

### Revisar atajos

Especialmente

Launcher

Lock

Clipboard

Power Menu

Overview

Aplicaciones frecuentes

---

# Componentes a estudiar

Niri

- reglas
- focus
- animaciones
- layout
- workspaces

Noctalia

- panel
- css
- launcher
- servicios

GTK

- temas

Wayland

- layer-shell
- xdg-desktop-portal

---

# Componentes futuros

Posibles mejoras

- Bibata
- Nordic Icons
- Tema GTK nórdico
- Colección de wallpapers
- Revisión completa del CSS del panel
- Revisión de transparencias
- Revisión de colores secundarios

---

# Estado del proyecto

Base del sistema

███████████████░░░░░ 75%

Estética

██████████████░░░░░░ 70%

Atajos

█████████░░░░░░░░░░░ 45%

Integración visual

████████████░░░░░░░░ 65%

Productividad

█████████████████░░░ 85%

Mantenimiento

████████████████░░░░ 80%