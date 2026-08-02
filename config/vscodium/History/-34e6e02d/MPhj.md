# Ficha técnica del sistema

> **openSUSE Tumbleweed + Niri + Noctalia**

| Campo | Valor |
|-------|-------|
| Versión del documento | **1.2 (Workspaces KISS y gestión inteligente de batería)** |
| Última actualización | **1 de agosto de 2026** |

---

## Filosofía

Este escritorio fue diseñado con cinco objetivos principales:

- Estabilidad
- Bajo mantenimiento
- Reproducibilidad
- Descanso visual
- Productividad científica

No busca imitar macOS, Windows ni un escritorio "gamer". La intención es construir un entorno silencioso, donde la interfaz desaparezca y el contenido sea el protagonista.

La inspiración estética proviene de:

- Papel mate
- Cartón prensado
- Roca basáltica
- Aluminio anodizado
- Vidrio esmerilado
- Laboratorios
- Instrumentos científicos

> No se utilizan negros absolutos ni colores excesivamente saturados.

---

## Hardware

| Componente | Valor |
|------------|-------|
| Equipo | ASUS VivoBook M1603QA |
| CPU | Ryzen 5 5600H |
| GPU | Radeon Vega integrada |
| RAM | 16 GB |
| Pantalla | IPS 16" 1920×1200 60 Hz |
| SSD | NVMe |
| Sistema de archivos | BTRFS |

---

## Sistema base

| Capa | Software | Integración de Transparencia |
|------|----------|------------------------------|
| Distribución | openSUSE Tumbleweed | Base del sistema |
| Kernel | Linux 7.1.4 | Soporte de hardware |
| Login | greetd | Display manager |
| Session Manager | UWSM | Gestión de sesión Wayland |
| Compositor | Niri 26.04 | Blur global + Reglas de opacidad |
| Shell gráfico | Noctalia 5 beta | Generación de paleta (`#242A30`) |
| Terminal | Kitty | Nativo (Misma paleta Noctalia) |
| Navegador | Zen Browser (Flatpak) | `userChrome.css` (Canal alfa directo) |
| Editor | VSCodium (Nativo) | `settings.json` + Opacidad en Niri (0.88) |
| Explorador | Thunar (GTK3) | `gtk.css` (Sin fondos opacos en widgets) |
| Shell CLI | Bash | Entorno interactivo |

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
    ├──────── Blur Global / Effect
    ├──────── Animaciones (Spring)
    ├──────── Layout / Focus
    ├──────── Reglas por App (app-id)
    │
    ▼
Noctalia
    │
    ├──────── Paleta Central (`mSurface: #242A30`)
    ├──────── Barra / Dock / Shell
    ├──────── CSS / GTK Generation
    │
    ▼
Estrategias de Cliente
    │
    ├──────── GTK3 (Thunar): "Perforación" de widgets en gtk.css
    ├──────── Gecko (Zen): userChrome.css con RGBA + .browserContainer sólido
    └──────── Electron (VSCodium): Tema JSON + Opacidad Niri (0.88)

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
* Blur y sombras
* Focus ring
* Reglas de opacidad global para aplicaciones con lienzo opaco (Electron)

**No define la identidad visual.**

### Noctalia

Es el responsable **absoluto** de la apariencia.

Define:

* Colores (Origen único del tono base `#242A30` / `rgba(36, 42, 48, α)`)
* CSS
* Paneles / Launcher / Dock / Lockscreen
* Wallpapers
* Iconografía de la shell
* Integración GTK

> Toda modificación estética debe comenzar aquí.

### GTK

Solo proporciona compatibilidad. **No debe competir con Noctalia.**

Se utiliza `adw-gtk3-dark` como base, anulando mediante CSS de usuario únicamente los fondos sólidos de widgets secundarios para permitir el traspaso del blur.

---

## Identidad visual definitiva

| Elemento | Valor |
| --- | --- |
| Tema GTK | `adw-gtk3-dark` |
| Iconos | Papirus-Dark |
| Cursor | Bibata Modern Classic (38 px, configurado desde Niri) |

### Paleta oficial (`mSurface: #242A30`)

La referencia conceptual es **Slate Paper** (papel reciclado, pizarra y vidrio mate).

* **Fondo base (`mSurface`):** `#242A30` / `rgba(36, 42, 48, α)`
* **Superficie variante (`mSurfaceVariant`):** `#2E353D`
* **Texto principal (`mOnSurface`):** `#D8DEE6`
* **Acento (`mPrimary`):** `#6E8FAF`
* **Bordes (`mOutline`):** `#56616D`

---

## Estrategia de Transparencias y Blur (Lecciones Aprendidas)

Se han identificado **dos métodos diferenciados** para lograr que el blur de Niri funcione de forma óptima sin sacrificar legibilidad:

> **Aprendizaje clave:** La opacidad puede residir en los widgets del cliente o en la ventana del compositor. Tratar todas las aplicaciones por igual genera textos borrosos o fondos totalmente opacos.

### 1. Transparencia Nativa por Cliente (GTK3 y Gecko)

*Permite un fondo transparente con cristal/blur mientras que el texto y los iconos permanecen 100% opacos e hipernítidos.*

* **Thunar (GTK3):** No requiere opacidad por compositor. La razón de su opacidad original radicaba en las capas internas del tema (`GtkScrolledWindow`, `GtkTreeView`, `.sidebar`). Al despojar de fondo sólido a los widgets hijos mediante `~/.config/gtk-3.0/gtk.css`, el blur de Niri pasa a través del lienzo transparente de la ventana base.
* **Zen Browser (Gecko):** Se activa `toolkit.legacyUserProfileCustomizations.stylesheets` y se inyecta la paleta en `userChrome.css` mediante `rgba(36, 42, 48, 0.70)`. La capa `.browserContainer` se mantiene opaca (`#242A30`) para evitar cansancio visual al leer contenido web.

### 2. Transparencia por Compositor (Electron)

*Utilizada cuando el cliente dibuja sobre un lienzo interno completamente opaco.*

* **VSCodium (Electron):** Electron no expone canal alfa transparente directo en Linux de forma estable. La estrategia óptima es tematizar internamente el editor con la paleta exacta de Noctalia (`settings.json` → `workbench.colorCustomizations`) y aplicar una regla de **opacidad controlada en Niri (`opacity 0.88`)** junto con `background-effect { blur true }`.

---

## Configuración de Niri (Reglas clave)

```kdl
// Configuración general
gaps:              16 px
radio:             20 px
blur:              global (passes 3, offset 2.5, noise 0.015)
focus ring:        #7696B4
prefer-no-csd:     habilitado

// Reglas de ventana por App-ID
window-rule {
    match app-id="[Tt]hunar"
    opacity 0.88 // Opcional si se usa CSS nativo
    background-effect { blur true }
}

window-rule {
    match app-id="app.zen_browser.zen"
    opacity 0.88
    background-effect { blur true }
}

window-rule {
    match app-id=r#"(?i).*codium.*"#
    opacity 0.88
    background-effect { blur true }
}

```


---

# Organización de Workspaces (Filosofía KISS)

Tras varias iteraciones se adoptó una organización basada en **workspaces con nombre** (Named Workspaces) en lugar de depender de índices numéricos.

La filosofía es que el usuario piensa en tareas ("Web", "Trabajo", "Edición") y no en números arbitrarios.

## Workspaces oficiales

| Workspace | Propósito | Aplicaciones |
|-----------|-----------|--------------|
| **Web** | Navegación y literatura | Zen Browser, Zotero |
| **Trabajo** | Escritura y programación | VSCodium, ONLYOFFICE |
| **Edición** | SIG y multimedia | QGIS, GIMP, Kdenlive |
| **Vagancia** | Ocio | Spotify, Steam, Heroic, ProtonPlus |

Las aplicaciones se asignan mediante reglas de Niri:

```kdl
window-rule {
    match app-id="app.zen_browser.zen"
    open-on-workspace "Web"
}


---

## Organización de atajos

### `Super` — Control del compositor

*(Ventanas, columnas, workspaces, layouts — nunca abre aplicaciones).*

### `Alt` — Aplicaciones y Shell

* `Alt + E`: Thunar
* `Alt + Z`: Zen Browser
* `Alt + T` / `Mod + T`: Kitty
* `Alt + D`: Noctalia Launcher
* `Alt + H`: Control Center
* `Alt + V`: Clipboard
* `Alt + C`: Calendario
* `Alt + Escape`: System Monitor (btop)

---

# 4. Actualizar "Directorios y archivos de configuración clave"

Sustituir esa sección por:

````markdown
## Directorios y archivos de configuración clave

```text
~/.config/niri/config.kdl                              # Configuración global del compositor
~/.config/niri/reglas.kdl                             # Reglas de ventanas y workspaces
~/.config/niri/atajos.kdl                             # Atajos de teclado
~/.config/noctalia/                                   # Shell, paletas y módulos
~/.config/kitty/kitty.conf                            # Terminal
~/.config/gtk-3.0/gtk.css                             # Transparencias GTK3
~/.config/VSCodium/User/settings.json                 # Tema de VSCodium
~/.var/app/app.zen_browser.zen/.zen/<perfil>/chrome/  # userChrome.css
~/.local/bin/battery-limit                            # Script de gestión del límite de carga
~/.config/systemd/user/battery-limit.service          # Servicio de batería
~/.config/systemd/user/battery-limit.timer            # Temporizador de batería
~/.bashrc                                             # Alias y funciones del entorno

---

## Problemas conocidos y soluciones

### Nombres con caracteres especiales en Flatpak

Al gestionar perfiles dentro de `~/.var/app/`, las rutas pueden contener espacios y paréntesis (ej. `6gw4whrr.Default (release)`). Es imprescindible acotar las rutas entre comillas simples/dobles en Bash o scripts de mantenimiento.

### Identificación de `app-id` en Wayland

Aplicaciones nativas o empaquetadas de forma heterogénea pueden registrar nombres variables (`codium`, `VSCodium`, `codium-url-handler`). Se debe priorizar el uso de expresiones regulares insensibles a mayúsculas (`r#"(?i).*app.*"#`) en las reglas de Niri.

### Keyring en VSCodium

Si solicita crear un nuevo keyring en entornos sin GNOME Keyring completo, se puede desactivar la sincronización de contraseñas o configurar un almacenamiento de claves simple sin afectar el funcionamiento del editor.


---

# 3. Añadir una sección nueva antes de "Respaldo"

```markdown
---

# Gestión de batería (KISS)

La gestión del límite de carga sigue el mismo principio del escritorio: una única responsabilidad por componente.

## Arquitectura

```text
systemd --user
        │
        ▼
battery-limit.timer
        │
        │ (2 minutos)
        ▼
battery-limit.service
        │
        ▼
~/.local/bin/battery-limit
        │
        ▼
BAT0/charge_control_end_threshold


El sistema aprovecha que el usuario pertenece al grupo power, que posee permisos de escritura sobre:

/sys/class/power_supply/BAT0/charge_control_end_threshold

Por ello la solución funciona completamente desde systemd --user, sin privilegios adicionales.

---

## Respaldo

### Backup del escritorio

Script de copia exclusiva para reconstrucción rápida en entorno limpio:

```bash
#!/bin/bash
DEST=~/Backups/desktop_config_$(date +%Y%m%m_%H%M%S)
mkdir -p "$DEST"

cp -r ~/.config/niri "$DEST/"
cp -r ~/.config/noctalia "$DEST/"
cp -r ~/.config/kitty "$DEST/"
cp -r ~/.config/gtk-3.0 "$DEST/"
cp -r ~/.config/VSCodium/User/settings.json "$DEST/codium-settings.json"
cp ~/.bashrc "$DEST/"

# Respaldo de CSS de Zen (detectando carpeta Flatpak)
ZEN_CHROME=$(find ~/.var/app/app.zen_browser.zen/ -type d -name "chrome" 2>/dev/null)
if [ -n "$ZEN_CHROME" ]; then
    cp -r "$ZEN_CHROME" "$DEST/zen-chrome"
fi

tar -czf "$DEST.tar.gz" -C "$DEST" .
rm -rf "$DEST"
echo "Respaldo del entorno completado en $DEST.tar.gz"

```

---

## Estado del proyecto

| Área | Estado |
| --- | --- |
| Base del sistema | ✅ Finalizado |
| Wayland / Niri | ✅ Finalizado |
| Noctalia Shell | ✅ Finalizado |
| Kitty Terminal | ✅ Finalizado |
| Thunar (GTK3 Blur) | ✅ Finalizado |
| Zen Browser (Transparencia CSS) | ✅ Finalizado |
| VSCodium (Tema + Blur Electron) | ✅ Finalizado |
| Identidad visual / Paleta | ✅ Finalizado |
| Atajos de teclado | ✅ Finalizado |
| Documentación | ✅ Finalizado |

---

## Filosofía final

> Un escritorio bien diseñado no intenta impresionar. Reduce la carga cognitiva, desaparece mientras trabajas y permanece suficientemente documentado para que incluso tu yo de dentro de cinco años pueda reconstruirlo sin depender de la memoria. Cada componente tiene un único propósito, cada decisión es deliberada y cada configuración puede explicarse.

```

```