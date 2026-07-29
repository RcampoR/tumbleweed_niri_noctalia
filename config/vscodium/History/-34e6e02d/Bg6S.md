# Ficha técnica del sistema

**openSUSE Tumbleweed + Niri + Noctalia**
Última actualización: 28 de julio de 2026

> Nota histórica: el sistema usaba previamente Sway y la mayoría de sus herramientas; fueron reemplazadas por el stack actual (Niri + Noctalia).

---

## 1. Filosofía

**Objetivos:** Wayland puro, rolling release, escritorio ligero, bajo mantenimiento, máxima estabilidad, configuración reproducible/respaldable, responsabilidades separadas por componente, coherencia visual, animaciones sutiles sin perder seriedad.

**Estética — Organic Tech · Basalt · Slate Paper**
Inspiración: papel mate, cartón prensado, pizarra, basalto, aluminio anodizado, vidrio esmerilado, azules grisáceos poco saturados, negros suaves, grises cálidos.
Evitar: estética gamer, RGB, cyberpunk, futurista exagerada.
Sensación buscada: laboratorio, escritorio científico, descanso visual, tecnología silenciosa.

---

## 2. Hardware

| Componente | Detalle |
|---|---|
| Equipo | ASUS VivoBook M1603QA |
| CPU | AMD Ryzen 5 5600H (6C/12T) |
| GPU | AMD Radeon Vega integrada |
| RAM | 16 GB |
| Pantalla | 16", 1920×1200, 60 Hz |
| Almacenamiento | SSD NVMe |
| Filesystem | BTRFS |

---

## 3. Sistema base

| Capa | Elección |
|---|---|
| Distribución | openSUSE Tumbleweed |
| Kernel | Linux 7.1.4 |
| Shell (CLI) | bash |
| Sesión | Wayland |
| Login manager | greetd |
| Gestor de sesión | UWSM |
| Compositor | Niri 26.04 |
| Shell gráfico | Noctalia 5.0.0-beta5 |
| Terminal | kitty |
| Navegador | Zen Browser (Flatpak) |
| Gestor de archivos | Thunar |
| Capturas | Niri Screenshot |

---

## 4. Arquitectura de tematización (definitiva)

Un único responsable de la identidad visual: **Noctalia**. Niri solo compone; GTK es capa de compatibilidad.

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
          Templates + CSS + Paleta
                       │
                  Noctalia Shell
                       │
                      Niri
```

**Responsabilidades:**
- **Niri:** composición, ventanas, columnas, animaciones, reglas, blur, focus ring, workspaces.
- **Noctalia:** panel, launcher, dock, control center, notificaciones, lockscreen, wallpaper, CSS, paleta, tematización GTK/Qt.
- **adw-gtk3-dark:** base neutra de compatibilidad GTK3/GTK4 (no define identidad visual).
- **MoreWaita:** iconografía (baja saturación, buena integración Flatpak).
- **Bibata Modern Classic:** cursores, configurados directamente desde Niri (no depende de GTK):

```kdl
cursor {
    xcursor-theme "Bibata-Modern-Classic"
    xcursor-size 38
}
```

**Descartados como base y por qué:**
- *Graphite* → buen tema GTK pero impone identidad propia, compite con Noctalia.
- *Adwaita-Colors* → duplica responsabilidades con Noctalia, mantenimiento innecesario. Se conserva solo como referencia.

`nwg-look` se usa únicamente para GTK2/GTK3 (tema, iconos, cursor). La exportación de `~/.config/gtk-4.0/*` queda **desactivada** para no pisar lo que genera Noctalia.

---

## 5. Configuración actual de Niri

| Parámetro | Valor |
|---|---|
| Layout | Columnas |
| Gaps | 16 px |
| Esquinas | 20 px |
| Blur | Activado |
| Bordes | Desactivados |
| Focus ring | Activado, color `#7fc8ff` |

**Animaciones (modelo spring):**
- `window-open`, `window-movement`: rebote perceptible (`damping-ratio` ≈ 0.78–0.80)
- `window-close`, `window-resize`, `horizontal-view-movement`: rebote mínimo (`damping-ratio` ≈ 0.90–0.98)
- `epsilon` ligeramente elevado (≈ 0.0003–0.0006) para evitar oscilaciones finales
- Pendiente validar con **Elastic**

---

## 6. Rutas de configuración a respaldar

| Componente | Ruta |
|---|---|
| Niri | `~/.config/niri/` |
| Noctalia | `~/.config/noctalia/` |
| GTK3 | `~/.config/gtk-3.0/` |
| GTK4 | `~/.config/gtk-4.0/` |
| Kitty | `~/.config/kitty/` |
| Thunar | `~/.config/Thunar/` |
| Bash | `~/.bashrc` |
| mimeapps | `~/.config/mimeapps.list` |
| VSCodium | `~/.config/VSCodium/User/` |

Proyecto de respaldo: `~/Respaldos/tumbleweed_niri_noctalia/`

---

## 7. Atajos personalizados

**Super** → reservado para ventanas, columnas, workspaces y funciones propias de Niri.
**Alt** → reservado para aplicaciones, paneles y herramientas.

| Atajo | Acción |
|---|---|
| Alt + Z | Zen Browser |
| Alt + E | Thunar |
| Alt + Esc | btop |
| Alt + V | Portapapeles |
| Alt + H | Control Center |
| Alt + C | Calendario |
| Alt + KP_* | Menú de energía |
| Alt + KP_/ | Bloquear sesión |

---

## 8. Portapapeles

Administrador **nativo de Noctalia** (no se usan cliphist, rofi, wofi, fuzzel, walker ni tofi).

```bash
noctalia msg panel-toggle clipboard   # abrir
noctalia msg clipboard-clear          # limpiar
```

---

## 9. IPC de Noctalia — comandos útiles

Toda la interfaz se controla vía `noctalia msg ...`:

```bash
noctalia msg panel-toggle launcher
noctalia msg panel-toggle clipboard
noctalia msg panel-toggle control-center
noctalia msg panel-toggle wallpaper
noctalia msg panel-toggle session
noctalia msg session lock
noctalia msg volume-up
noctalia msg brightness-up
noctalia msg notification-dnd-toggle
```

---

## 10. Problemas conocidos y soluciones (para recrear el sistema)

### Paneles no reciben interactividad de teclado
- **Diagnóstico:** vía IPC de Niri se confirmó que los paneles sí reciben `Keyboard interactivity: exclusive` correctamente. El problema real era un **estado inconsistente del daemon de Noctalia**, no de Niri.
- **Solución / alias permanente:**
```bash
alias noctalia-r='pkill noctalia && sleep 1 && noctalia --daemon'
```
- **Estado:** resuelto. Si vuelve a ocurrir tras actualizar Noctalia o Niri, este es el primer paso de troubleshooting.

### GTK4 sobrescrito por nwg-look
- **Causa:** exportar `~/.config/gtk-4.0/*` desde nwg-look pisa la configuración generada por Noctalia.
- **Prevención:** mantener esa opción **desactivada** siempre en nwg-look.


---

## 11. Decisiones consolidadas

| Componente | Decisión |
|---|---|
| Distribución | openSUSE Tumbleweed |
| Sistema gráfico | Wayland |
| Gestor de sesión | UWSM |
| Login manager | greetd |
| Compositor | Niri |
| Shell | Noctalia |
| Terminal | kitty |
| Navegador | Zen Browser |
| Gestor de archivos | Thunar |
| Tema GTK | adw-gtk3-dark |
| Iconos | MoreWaita |
| Cursor | Bibata Modern Classic |

---

## 12. Estado del proyecto

| Área | % |
|---|---|
| Base técnica | 98% |
| Integración Wayland | 100% |
| Atajos | 95% |
| Integración visual | 90% |
| Estética | 88% |
| Productividad | 97% |
| Mantenimiento | 95% |

**Funcionando correctamente:** greetd, UWSM, Niri, Noctalia, blur, launcher, dock, barra, control center, calendario, menú de sesión, historial de portapapeles, notificaciones, wallpaper, focus ring, animaciones personalizadas, scroll natural, adw-gtk3-dark, MoreWaita, Bibata Modern Classic, nwg-look, kitty, Zen Browser, Thunar.

---

## 13. Pendientes

**Identidad visual**
- Definir paleta definitiva de Noctalia (basalto, grafito, pizarra, papel reciclado, azul petróleo, azul grisáceo, carbón — evitar negro absoluto, blanco puro, colores saturados).
- Ajustar CSS: panel, launcher, dock, control center.
- Afinar blur y transparencias (objetivo: vidrio esmerilado muy sutil).
- Seleccionar wallpapers coherentes con la filosofía del proyecto.

**Integración**
- Revisar tematización de aplicaciones Qt.
- Verificar comportamiento de Flatpak tras definir la paleta definitiva.



---

## 14. Filosofía de cierre

> Un escritorio científico debe desaparecer mientras se trabaja. La interfaz no busca llamar la atención, sino reducir la fatiga visual y ofrecer un entorno consistente, silencioso y mantenible: Niri gestiona el espacio, Noctalia define la identidad visual, GTK actúa solo como base de compatibilidad.