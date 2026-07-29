# Ficha técnica del sistema

## openSUSE Tumbleweed + Niri + Noctalia

**Última actualización:** 28 de julio de 2026

---

# Filosofía del sistema

## Objetivos

* Sistema moderno basado completamente en Wayland.
* Rolling Release (openSUSE Tumbleweed).
* Escritorio extremadamente ligero.
* Enfoque científico y de productividad.
* Bajo mantenimiento.
* Máxima estabilidad posible.
* Configuración reproducible y fácil de respaldar.
* Mantener una separación clara entre responsabilidades de cada componente.
* Apariencia sobria inspirada en materiales naturales.
* Evitar efectos visuales innecesarios.
* Mantener coherencia visual entre todos los componentes.
* Animaciones fluidas y gratificantes, sin perder seriedad.

La estética buscada puede resumirse como:

> **Organic Tech · Basalt · Slate Paper**

Inspirada en:

* papel mate
* cartón prensado
* pizarra
* basalto
* aluminio anodizado
* vidrio esmerilado
* azules grisáceos poco saturados
* negros suaves
* grises cálidos

No busca una apariencia:

* gamer
* RGB
* cyberpunk
* futurista exagerada

Debe transmitir sensación de:

* laboratorio
* escritorio científico
* descanso visual
* materiales naturales
* tecnología silenciosa

---

# Hardware

## Equipo

ASUS VivoBook M1603QA

## CPU

AMD Ryzen 5 5600H

* 6 núcleos
* 12 hilos

## GPU

AMD Radeon Vega integrada

## RAM

16 GB

## Pantalla

* 16"
* 1920×1200
* 60 Hz

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

* greetd

## Gestor de sesión

* UWSM (Universal Wayland Session Manager)

## Compositor

* Niri

## Shell gráfico

* Noctalia 5.0.0-beta5

## Componentes principales

* Launcher
* Panel
* Dock
* Control Center
* Session Menu
* Notifications
* Wallpaper
* Lockscreen

## Terminal

kitty

## Navegador

Zen Browser (Flatpak)

## Gestor de archivos

Thunar

## Capturas

Niri Screenshot

---

# Filosofía de tematización

El sistema adopta una arquitectura donde existe **un único responsable de la apariencia visual**.

```text
                Aplicaciones
                      │
        ┌─────────────┴─────────────┐
        │                           │
      GTK3                      GTK4/libadwaita
        │                           │
        └────────── adw-gtk3 ───────┘
                     │
              Noctalia Templates
                     │
              CSS · Paleta · Colores
                     │
                 Noctalia Shell
                     │
                   Niri
```

## Responsabilidades

### Niri

Responsable únicamente de:

* composición
* ventanas
* columnas
* animaciones
* reglas
* blur
* focus ring
* workspaces

### Noctalia

Responsable de:

* panel
* launcher
* dock
* control center
* notificaciones
* lockscreen
* wallpaper
* CSS
* paleta de colores
* tematización GTK
* tematización Qt

### GTK

Utiliza un tema neutro.

Tema base:

```text
adw-gtk3-dark
```

No se emplean temas decorativos (Graphite, Colloid, Orchis...) como base del sistema.

---

# Estado actual de GTK

## Tema

```
adw-gtk3-dark
```

## Iconos

```
Adwaita
```

## Cursores

```
Adwaita
```

## Configuración

GTK3 se configura mediante:

```
nwg-look
```

GTK4 permanece bajo control exclusivo de Noctalia.

La opción

```
~/.config/gtk-4.0/*
```

permanece desactivada en `nwg-look` para evitar sobrescribir la configuración generada por Noctalia.

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

## Animaciones

Modelo físico de resorte (*spring*), afinado para lograr un rebote sutil y agradable únicamente en las transiciones donde aporta sensación de fluidez.

### Criterio de ajuste

* `window-open`
* `window-movement`

rebote perceptible

(`damping-ratio` ≈ 0.78–0.80)

---

* `window-close`
* `window-resize`
* `horizontal-view-movement`

rebote mínimo

(`damping-ratio` ≈ 0.90–0.98)

---

`epsilon`

ligeramente elevado

(≈ 0.0003–0.0006)

para evitar oscilaciones finales.

Pendiente validar con **Elastic**.

---

# Rutas importantes

## Configuraciones respaldadas

| Componente | Ruta                       |
| ---------- | -------------------------- |
| Niri       | `~/.config/niri/`          |
| Noctalia   | `~/.config/noctalia/`      |
| GTK3       | `~/.config/gtk-3.0/`       |
| GTK4       | `~/.config/gtk-4.0/`       |
| Kitty      | `~/.config/kitty/`         |
| Thunar     | `~/.config/Thunar/`        |
| Bash       | `~/.bashrc`                |
| mimeapps   | `~/.config/mimeapps.list`  |
| VSCodium   | `~/.config/VSCodium/User/` |

## Proyecto de respaldo

```
~/Respaldos/tumbleweed_niri_noctalia/
```

## Alias

```
noctalia-r
```

---

# Estado actual

## Funcionando correctamente

* greetd
* UWSM
* Niri
* Noctalia
* Blur
* Launcher
* Dock
* Barra
* Control Center
* Calendario
* Menú de sesión
* Historial del portapapeles
* Notificaciones
* Wallpaper
* Focus Ring
* Scroll por columnas
* Animaciones ajustadas
* adw-gtk3-dark
* nwg-look

---

# Investigación técnica

## Problema de interacción por teclado

Se investigó utilizando el IPC de Niri.

### Resultado

Los paneles reciben correctamente

```text
Keyboard interactivity: exclusive
```

El problema provenía de un estado inconsistente del daemon de Noctalia.

### Solución

```bash
pkill noctalia
sleep 1
noctalia --daemon
```

Alias permanente

```bash
alias noctalia-r='pkill noctalia && sleep 1 && noctalia --daemon'
```

Estado

**Resuelto.**

---

# Aprendizajes

## Arquitectura IPC de Noctalia

Toda la interfaz se controla mediante

```bash
noctalia msg ...
```

Ejemplos

```bash
noctalia msg panel-toggle launcher
noctalia msg panel-toggle clipboard
noctalia msg panel-toggle control-center
noctalia msg panel-toggle wallpaper
noctalia msg panel-toggle session
```

Acciones del sistema

```bash
noctalia msg session lock
noctalia msg volume-up
noctalia msg brightness-up
noctalia msg notification-dnd-toggle
```

---

## Tematización moderna

Uno de los descubrimientos más importantes fue comprender la diferencia entre un **tema GTK** y un **motor de tematización**.

### Graphite

Se evaluó Graphite como posible tema principal.

Resultado:

* excelente tema GTK
* no se integra con la filosofía de Noctalia
* sustituye la identidad visual del sistema

### adw-gtk3

Se adopta finalmente:

```text
adw-gtk3-dark
```

No pretende modificar la apariencia del escritorio.

Su función consiste en proporcionar una base homogénea entre GTK3 y GTK4 para que Noctalia aplique posteriormente la paleta del sistema.

### Arquitectura final

```text
adw-gtk3-dark
        │
Noctalia Templates
        │
gtk.css
        │
Aplicaciones GTK
```

### Conclusiones

* un único responsable de la apariencia
* menos conflictos
* menos mantenimiento
* mayor coherencia visual

---

## nwg-look

Se incorpora únicamente como herramienta de configuración inicial.

Configuración adoptada

* exportar GTK3
* exportar GTK2
* exportar iconos
* exportar cursores

No exportar

```
GTK4
```

GTK4 queda reservado para Noctalia.

---

# Atajos personalizados

## Super

Reservado para:

* ventanas
* columnas
* workspaces
* funciones propias de Niri

## Alt

Reservado para:

* aplicaciones
* paneles
* herramientas

| Atajo      | Acción          |
| ---------- | --------------- |
| Alt + Z    | Zen Browser     |
| Alt + E    | Thunar          |
| Alt + Esc  | btop            |
| Alt + V    | Portapapeles    |
| Alt + H    | Control Center  |
| Alt + C    | Calendario      |
| Alt + KP_* | Menú de energía |
| Alt + KP_/ | Bloquear sesión |

---

# Portapapeles

Administrador nativo de Noctalia.

Abrir

```bash
noctalia msg panel-toggle clipboard
```

Limpiar

```bash
noctalia msg clipboard-clear
```

No se utilizan:

* cliphist
* rofi
* wofi
* fuzzel
* walker
* tofi

---

# Objetivos estéticos

## Prioridad alta

### Cursores

Instalar

* Bibata Modern Classic

Objetivo

* mayor precisión
* mejor contraste
* estética moderna

---

### Iconos

Evaluar

* MoreWaita
* Papirus
* Tela
* Reversal
* Colloid

Criterios

* baja saturación
* buena integración con GTK
* aspecto limpio
* excelente soporte para Flatpak

---

### Paleta definitiva de Noctalia

Inspiración

* basalto
* grafito
* pizarra
* papel reciclado
* azul petróleo
* azul grisáceo
* carbón

Evitar

* negro absoluto
* blanco puro
* colores saturados

---

### CSS

Personalizar

Panel

* radios
* hover
* transparencia
* espaciado

Launcher

* selección
* fondo
* búsqueda

Dock

* blur
* hover
* radios

Control Center

* tarjetas
* sliders
* interruptores

---

### Blur

Afinar

* intensidad
* opacidad
* contraste

Objetivo

Vidrio esmerilado muy sutil.

---

# Componentes a estudiar

## Niri

* reglas
* overview
* IPC
* animaciones
* workspaces

## Noctalia

* CSS
* Templates
* Plugins
* Paletas

## GTK

* integración con Noctalia

## Qt

* Templates

## Wayland

* layer-shell
* xdg-desktop-portal

---

# Deuda técnica

## Documentación

Pendiente documentar

* greetd
* UWSM
* flujo completo de inicio Wayland
* flujo completo de tematización
* integración GTK
* integración Qt
* plantillas de Noctalia
* configuración de `nwg-look`

---

# Pendientes inmediatos

1. Instalar **Bibata Modern Classic**.
2. Elegir un tema de iconos definitivo.
3. Diseñar la paleta definitiva de Noctalia.
4. Ajustar el CSS del panel, launcher, dock y Control Center.
5. Afinar blur y transparencias para lograr el efecto **Organic Tech · Basalt · Slate Paper**.
6. Verificar la integración de Flatpak con `adw-gtk3`.
7. Eliminar el repositorio de pruebas de Graphite, ya descartado como base del sistema.

---

# Estado del proyecto

## Base del sistema

```text
███████████████████░ 95%
```

## Estética

```text
████████████████░░░░ 80%
```

## Atajos

```text
████████████████░░░░ 80%
```

## Integración visual

```text
█████████████████░░░ 85%
```

## Productividad

```text
███████████████████░ 95%
```

## Mantenimiento

```text
██████████████████░░ 90%
```

## Filosofía del proyecto

> Un escritorio científico debe desaparecer mientras se trabaja. La interfaz no busca llamar la atención, sino reducir la fatiga visual y ofrecer un entorno consistente, silencioso y mantenible donde Niri gestione el espacio, Noctalia defina la identidad visual y GTK actúe únicamente como una base de compatibilidad.


---

# Estado actual de GTK

## Tema GTK

```
adw-gtk3-dark
```

Se adopta como capa de compatibilidad entre aplicaciones GTK3 y GTK4.

No constituye la identidad visual del sistema, sino una base neutra sobre la cual Noctalia aplica su propia tematización.

---

## Iconos

```
MoreWaita
```

Estado: **Implementado.**

### Motivos de elección

* Mantiene la identidad visual de Adwaita.
* Excelente cobertura para aplicaciones modernas.
* Muy buena integración con Flatpak.
* Baja saturación.
* Apariencia limpia y consistente.
* Compatible con la filosofía "Organic Tech".

---

## Cursores

```
Bibata-Modern-Classic
```

Estado: **Implementado.**

La configuración del cursor ya no depende exclusivamente de GTK.

Se establece directamente desde Niri mediante:

```kdl
cursor {
    xcursor-theme "Bibata-Modern-Classic"
    xcursor-size 38
}
```

De esta forma Niri exporta automáticamente las variables:

```
XCURSOR_THEME
XCURSOR_SIZE
```

garantizando una configuración consistente para aplicaciones Wayland.

---

## Configuración

GTK2 y GTK3 continúan administrándose mediante:

```
nwg-look
```

Configuración utilizada:

* Tema GTK
* Iconos
* Cursor

La exportación de GTK4 permanece deshabilitada para evitar sobrescribir la configuración generada por Noctalia.

---

# Decisiones de tematización

Durante el proceso se evaluaron varias alternativas.

## Graphite

Estado:

**Descartado.**

Aunque ofrece una excelente calidad visual, introduce una identidad propia demasiado marcada y compite con el sistema de tematización de Noctalia.

---

## Adwaita-Colors

Estado:

**Descartado como tema principal.**

Se evaluó por su capacidad de generar variantes coloreadas de Adwaita.

Sin embargo, finalmente se concluyó que:

* duplica responsabilidades con Noctalia;
* añade mantenimiento innecesario;
* dificulta mantener una única identidad visual.

Se conserva únicamente como referencia técnica.

---

## Arquitectura definitiva

```text
                 Aplicaciones
                       │
        ┌──────────────┴──────────────┐
        │                             │
      GTK3                       GTK4/libadwaita
        │                             │
        └────────── adw-gtk3 ─────────┘
                       │
                 MoreWaita Icons
                       │
               Bibata Modern Cursor
                       │
          Templates + CSS + Palette
                       │
                  Noctalia Shell
                       │
                      Niri
```

Esta arquitectura establece un único responsable de la identidad visual del escritorio:

* **Niri** administra composición y ventanas.
* **Noctalia** define completamente la apariencia.
* **adw-gtk3** aporta compatibilidad.
* **MoreWaita** proporciona la iconografía.
* **Bibata** unifica los cursores.

---

# Estado actual

## Funcionando correctamente

* greetd
* UWSM
* Niri
* Noctalia
* Blur
* Launcher
* Dock
* Barra
* Control Center
* Calendario
* Menú de sesión
* Historial del portapapeles
* Notificaciones
* Wallpaper
* Focus Ring
* Animaciones personalizadas
* Scroll natural
* adw-gtk3-dark
* MoreWaita
* Bibata Modern Classic
* nwg-look
* Kitty
* Zen Browser
* Thunar

---

# Pendientes inmediatos

## Identidad visual

- Definir la paleta definitiva de Noctalia.
- Ajustar el CSS del panel.
- Ajustar el CSS del launcher.
- Ajustar el CSS del dock.
- Ajustar el CSS del Control Center.
- Afinar blur y transparencias.
- Seleccionar wallpapers coherentes con la filosofía del proyecto.

## Integración

- Revisar la tematización de aplicaciones Qt.
- Verificar el comportamiento visual de Flatpak tras definir la paleta definitiva.

## Sistema

- Resolver definitivamente el aviso del GNOME Keyring al iniciar VSCodium.
- Documentar el flujo completo:
  - greetd
  - UWSM
  - Niri
  - Noctalia

---

# Registro de decisiones

## Decisiones consolidadas

| Componente | Decisión |
|------------|----------|
| Distribución | openSUSE Tumbleweed |
| Sistema gráfico | Wayland |
| Gestor de sesión | UWSM |
| Login Manager | greetd |
| Compositor | Niri |
| Shell | Noctalia |
| Terminal | kitty |
| Navegador | Zen Browser |
| Gestor de archivos | Thunar |
| Tema GTK | adw-gtk3-dark |
| Iconos | MoreWaita |
| Cursor | Bibata Modern Classic |

---

# Estado del proyecto

## Base técnica

```text
████████████████████ 98%
```

## Integración Wayland

```text
████████████████████ 100%
```

## Atajos

```text
███████████████████░ 95%
```

## Integración visual

```text
██████████████████░░ 90%
```

## Estética

```text
█████████████████░░░ 88%
```

## Productividad

```text
███████████████████░ 97%
```

## Mantenimiento

```text
███████████████████░ 95%
```

---

## Estado del proyecto

La infraestructura del escritorio puede considerarse prácticamente terminada.

Las decisiones arquitectónicas fundamentales ya fueron tomadas y documentadas. A partir de este punto, el trabajo restante se centra en el refinamiento visual: definición de la paleta cromática, ajustes del CSS de Noctalia, equilibrio entre desenfoque y transparencias, y consolidación de una identidad estética coherente con la filosofía **Organic Tech · Basalt · Slate Paper**.

El objetivo ya no es añadir componentes, sino perfeccionar la experiencia visual manteniendo un sistema ligero, reproducible y sencillo de mantener.