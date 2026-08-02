
---

# Ficha técnica del sistema

> **openSUSE Tumbleweed + Niri + Noctalia**

| Campo | Valor |
| --- | --- |
| Versión del documento | 1.1 (Ajuste de Workspaces nombrados) |
| Última actualización | 29 de julio de 2026 |

---

## Filosofía

Este escritorio fue diseñado con cinco objetivos principales:

* Estabilidad
* Bajo mantenimiento
* Reproducibilidad
* Descanso visual
* Productividad científica

No busca imitar macOS, Windows ni un escritorio "gamer". La intención es construir un entorno silencioso, donde la interfaz desaparezca y el contenido sea el protagonista.

La inspiración estética proviene de:

* Papel mate
* Cartón prensado
* Roca basáltica
* Aluminio anodizado
* Vidrio esmerilado
* Laboratorios
* Instrumentos científicos

> No se utilizan negros absolutos ni colores excesivamente saturados.

---

## Hardware

| Componente | Valor |
| --- | --- |
| Equipo | ASUS VivoBook M1603QA |
| CPU | Ryzen 5 5600H |
| GPU | Radeon Vega integrada |
| RAM | 16 GB |
| Pantalla | IPS 16" 1920×1200 60 Hz |
| SSD | NVMe |
| Sistema de archivos | BTRFS |

---

## Sistema base

| Capa | Software |
| --- | --- |
| Distribución | openSUSE Tumbleweed |
| Kernel | Linux 7.1.4 |
| Login | greetd |
| Session Manager | UWSM |
| Compositor | Niri 26.04 |
| Shell gráfico | Noctalia 5 beta |
| Terminal | Kitty |
| Navegador | Zen Browser |
| Explorador | Thunar |
| Shell CLI | Bash |

---

## Arquitectura general

```text
greetd
    │
    ▼
UWSM
    │
    ▼
Niri
    │
    ├──────── Blur
    ├──────── Animaciones
    ├──────── Layout
    ├──────── Focus
    ├──────── Workspaces (Nombrados 1-4)
    │
    ▼
Noctalia
    │
    ├──────── Barra
    ├──────── Dock
    ├──────── Launcher
    ├──────── Control Center
    ├──────── Lockscreen
    ├──────── CSS
    ├──────── Paleta
    │
    ▼
GTK
    │
    ▼
Aplicaciones

```

---

## Filosofía de responsabilidades

> Cada componente tiene un único trabajo.

### Niri

Responsable **únicamente** de:

* Ventanas
* Composición
* Columnas
* Animaciones
* Blur
* Sombras
* Focus ring
* Reglas
* Gestión de escritorios (*workspaces*)

**No define la identidad visual.**

### Noctalia

Es el responsable **absoluto** de la apariencia.

Define:

* Colores
* CSS
* Paneles
* Launcher
* Dock
* Wallpapers
* Iconografía de la shell
* Integración GTK

> Toda modificación estética debe comenzar aquí.

### GTK

Solo proporciona compatibilidad. **No debe competir con Noctalia.**

Se utiliza `adw-gtk3-dark` únicamente como base.

---

## Identidad visual definitiva

| Elemento | Valor |
| --- | --- |
| Tema GTK | `adw-gtk3-dark` |
| Iconos | Papirus-Dark |
| Cursor | Bibata Modern Classic (38 px, configurado desde Niri) |

**Motivos de Papirus-Dark:**

* Excelente cobertura
* Estética profesional
* Azules sobrios
* Baja saturación
* Integración excelente con Wayland

### Paleta oficial

La identidad cromática del escritorio sigue cuatro principios:

* Azules grisáceos
* Negros suaves
* Grises cálidos
* Contraste moderado

**No se utilizan:**

* Negro puro
* Blanco puro
* Azules eléctricos
* Colores fluorescentes

> La referencia conceptual es: **Slate Paper** — una mezcla entre papel reciclado, pizarra y vidrio mate.

---

## Configuración visual

### Blur

* Activado
* Dos pasadas
* Ruido muy bajo
* Saturación neutra

> El objetivo no es llamar la atención sino reducir el contraste del fondo.

### Transparencias

* Ligeras
* Nunca superiores a lo necesario

> Se busca el efecto de cristal esmerilado, no vidrio.

### Animaciones

Se mantienen las animaciones tipo *spring*.

El rebote únicamente aparece en:

* Apertura
* Reorganización de ventanas

Todo lo demás utiliza amortiguamiento elevado.

> El escritorio transmite inercia física sin parecer un juguete.

---

## Configuración de Niri

```text
gaps:              16 px
radio:             20 px
blur:              global
focus ring:        azul grisáceo
prefer-no-csd:     habilitado
bordes:            desactivados
sombras:           suaves
workspaces:        nombrados ("1", "2", "3", "4")

```

### Gestión de escritorios (Workspaces)

* **Declaración raíz:** Los escritorios nombrados (`workspace "1"`, `workspace "2"`, etc.) se declaran en el nivel principal del archivo de configuración para permitir que las reglas de ventana (`open-on-workspace`) enruten las aplicaciones a su destino correcto.
* **Distribución por entorno predeterminado:**
* **`"1"` — Investigación y Web:** Zen Browser, Zotero.
* **`"2"` — Desarrollo y Documentos:** VSCodium, ONLYOFFICE.
* **`"3"` — Edición y GIS:** QGIS, Kdenlive, GIMP.
* **`"4"` — Multimedia y Entretenimiento:** Spotify, Steam, Heroic, ProtonPlus.


* **Navegación explícita:** Los atajos de teclado hacen referencia directa por cadena de texto (`focus-workspace "1"`) para garantizar saltos directos al espacio asignado independientemente de cuántos escritorios estén activos en el momento.

---

## Configuración de Kitty

Kitty utiliza **exactamente la misma identidad cromática** que Noctalia.

No existen dos temas distintos. La terminal es una extensión del escritorio.

---

## Organización de atajos

### `Super` — Control del compositor

Nunca abre aplicaciones. Incluye:

* Ventanas
* Columnas
* Workspaces por nombre explícito (`Mod+1` a `"1"`, `Mod+2` a `"2"`, etc.)
* Layout

### `Alt` — Aplicaciones

Incluye:

* Zen
* Thunar
* Noctalia
* Control Center
* Clipboard
* Calendario
* btop

> La separación evita conflictos y facilita la memorización.

---

## Directorios importantes

```text
~/.config/niri/
~/.config/noctalia/
~/.config/kitty/
~/.config/gtk-3.0/
~/.config/gtk-4.0/
~/.config/Thunar/
~/.config/VSCodium/
~/.bashrc

```

---

## Problemas conocidos

### GTK4

No permitir que `nwg-look` exporte la configuración GTK4. **Noctalia debe mantener el control.**

### Noctalia pierde teclado

Si ocurre:

```bash
pkill noctalia
sleep 1
noctalia --daemon

```

O bien:

```bash
noctalia-r

```

### Flatpak

Si alguna aplicación no sigue el tema:

1. Revisar variables GTK
2. Revisar permisos Flatpak
3. Reiniciar la aplicación

---

## Lógica del sistema

> La regla más importante del proyecto es: **cada responsabilidad debe existir en un único lugar.**

| Responsabilidad | Componente |
| --- | --- |
| Colores | Noctalia |
| Animaciones | Niri |
| Iconos | Papirus |
| Cursores | Niri |
| Mapeo de Workspaces | Niri (`reglas.kdl` + declaración `workspace`) |
| GTK | Compatibilidad |

**Nunca duplicar configuraciones.** Cuando dos componentes intentan hacer lo mismo aparecen inconsistencias difíciles de depurar.

---

## Respaldo

Se recomienda crear dos scripts independientes.

### 1. Backup del HOME

Debe incluir **únicamente** información importante:

* Documentos
* Proyectos
* Tesis
* Scripts
* Configuraciones personales

> No incluir cachés.

### 2. Backup del escritorio

Debe copiar exclusivamente:

```text
~/.config/niri/
~/.config/noctalia/
~/.config/kitty/
~/.config/gtk-3.0/
~/.config/gtk-4.0/
~/.config/Thunar/
~/.bashrc

```

Idealmente con fecha automática y compresión.

> Esto permite reconstruir el escritorio completo en pocos minutos tras una instalación limpia.

---

## Automatizaciones futuras

Cuando el sistema permanezca estable durante varios meses, merece la pena añadir utilidades propias.

**Prioridad sugerida:**

1. Script de respaldo del HOME.
2. Script de respaldo del entorno Niri + Noctalia.
3. Script de restauración completa desde un respaldo.
4. Script para sincronizar la configuración mediante Git.
5. Script para controlar los límites de carga de la batería (80 %, 85 %, 90 %, 100 %).
6. Script de actualización del sistema con limpieza automática de snapshots antiguos y cachés.
7. Script para exportar la paleta de Noctalia hacia Kitty y otras aplicaciones para mantener un único origen de colores.

---

## Estado del proyecto

| Área | Estado |
| --- | --- |
| Base del sistema | ✅ Finalizado |
| Wayland | ✅ Finalizado |
| Niri | ✅ Finalizado |
| Noctalia | ✅ Finalizado |
| Kitty | ✅ Finalizado |
| Blur | ✅ Finalizado |
| Animaciones | ✅ Finalizado |
| Identidad visual | ✅ Finalizado |
| Atajos | ✅ Finalizado |
| Productividad | ✅ Finalizado |
| Documentación | ✅ Finalizado |

---

## Filosofía final

> Un escritorio bien diseñado no intenta impresionar. Reduce la carga cognitiva, desaparece mientras trabajas y permanece suficientemente documentado para que incluso tu yo de dentro de cinco años pueda reconstruirlo sin depender de la memoria. Cada componente tiene un único propósito, cada decisión es deliberada y cada configuración puede explicarse.