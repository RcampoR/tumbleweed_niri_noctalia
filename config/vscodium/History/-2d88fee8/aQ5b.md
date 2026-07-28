# Ficha técnica definitiva del escritorio Sway

**Fecha:** Julio 2026 (actualizada el 17 de julio de 2026)
**Distribución:** openSUSE Tumbleweed
**Compositor:** Sway (Wayland)

---

# Estado general

El escritorio quedó estable y listo para uso diario.

Se priorizó:

* apariencia moderna;
* transparencia discreta;
* consistencia visual;
* funcionamiento nativo Wayland;
* pocos procesos residentes;
* configuración sencilla de mantener.

Actualmente no existen cambios críticos pendientes.

---

# Componentes instalados

| Componente | Estado               |
| ---------- | -------------------- |
| Sway       | ✔ Configurado        |
| uwsm       | ✔ Configurado (17/07/2026) |
| Waybar     | ✔ Personalizada      |
| Wofi       | ✔ Personalizado      |
| Wlogout    | ✔ Personalizado      |
| swaylock   | ✔ Configurado        |
| swaync     | ✔ Configurado        |
| wob        | ✔ Funcionando        |
| cliphist   | ✔ Funcionando        |
| grim       | ✔ Funcionando        |
| slurp      | ✔ Funcionando        |
| swappy     | ✔ Funcionando        |
| kitty      | ✔ Terminal principal |

---

# Integración con systemd (uwsm)

Estado:

✔ Implementada y funcionando (17 de julio de 2026).

## Problema original

Spotify (Flatpak) no lograba abrir enlaces en el navegador (Zen, también Flatpak). El síntoma visible era solo la punta del problema: la sesión de Sway, iniciada históricamente escribiendo `sway` a secas desde una TTY, nunca quedaba correctamente integrada con `systemd --user`. Esto significaba que `graphical-session.target` nunca se alcanzaba, lo cual dejaba caído en cascada a `xdg-desktop-portal.service` — el servicio del que dependen **todos** los Flatpaks para abrir URLs, seleccionar archivos, compartir pantalla, etc., no solo Spotify.

Causa raíz identificada:

1. Al lanzar Sway manualmente desde la TTY (sin display manager ni gestor de sesión), systemd nunca recibía la señal de "sesión gráfica lista".
2. Un `exec_always` duplicado en la config de Sway lanzaba `swaync` en paralelo al `swaync.service` ya gestionado por systemd, provocando choques ("instance already running") que agotaban el límite de reintentos (`start-limit-hit`) y arrastraban al target de sesión completo.
3. Al introducir `uwsm` para resolver la integración, la primera línea usada (`dbus-update-activation-environment --systemd WAYLAND_DISPLAY ...`) no exportaba la variable `SWAYSOCK`, que `uwsm` exige antes de dar la sesión por lista — causando que la sesión completa muriera por timeout a los ~30 segundos de cada arranque.

## Solución implementada

**a) Se eliminó el arranque duplicado de swaync.**
En `~/.config/sway/config`, se comentó la línea que lanzaba swaync manualmente:

```
#exec_always sh -c 'pkill -x swaync; exec swaync -c ~/.config/swaync/config.json -s ~/.config/swaync/style.css'
```

swaync ahora se gestiona **exclusivamente** vía `swaync.service` (systemd --user), sin ningún cambio en su configuración, tema o apariencia.

**b) Se instaló `uwsm` (Universal Wayland Session Manager)** para realizar la integración correcta entre Sway y `systemd --user`, sustituyendo la exportación manual de variables por el mecanismo nativo de la herramienta:

```
exec uwsm finalize
```

Esta línea reemplazó al intento manual anterior (`dbus-update-activation-environment`) en `~/.config/sway/config`.

**c) Se automatizó el arranque de la sesión gráfica** añadiendo el siguiente bloque al final de `~/.profile`:

```bash
# Auto-iniciar Sway vía uwsm en tty1 (solo si no hay sesión gráfica ya activa)
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec uwsm start sway.desktop
fi
```

Con esto, el login en `tty1` levanta Sway automáticamente de forma correctamente integrada, sin necesidad de escribir ningún comando manual y sin necesidad de un display manager gráfico (SDDM/GDM/greetd). Se evaluó instalar uno; se descartó por ahora ya que uwsm ya resuelve la integración funcional, y un DM solo añadiría una pantalla gráfica de login sin aportar nada más — ver sección de pendientes.

## Verificación (17/07/2026)

Tras el cambio, se confirmó en verde:

* `wayland-wm@sway.desktop.service` → `active (running)`
* `graphical-session.target` → `active`
* `xdg-desktop-portal.service` → `active (running)`
* `xdg-desktop-portal-gtk.service` → `active (running)`
* `swaync.service` → `active (running)`, sin bucle de reinicios
* `flatpak run --command=xdg-open com.spotify.Client "https://example.com"` → sin errores, portal responde correctamente
* Prueba real desde Spotify: enlace abierto correctamente en Zen

## Nota importante para el futuro

**El comando de login cambió.** Ya no se debe escribir `sway` a secas en la TTY — ahora es automático gracias al bloque en `~/.profile`. Si en algún punto se reinstala el sistema o se recrea el usuario, hay que recordar replicar:

1. El bloque de `~/.profile` (auto-arranque vía uwsm).
2. La línea `exec uwsm finalize` en `~/.config/sway/config`.
3. Confirmar que no exista ningún `exec_always` duplicado lanzando swaync (u otro servicio) por fuera de systemd.

---

# Fondo de escritorio

Wallpaper definitivo:

```
/home/rcampor/Imágenes/fondos/Debian_BlueSpace__3840x2160.png
```

Configurado desde:

```
~/.config/sway/config
```

mediante

```
output * bg /home/rcampor/Imágenes/fondos/Debian_BlueSpace__3840x2160.png fill
```

---

# Waybar

Estado:

✔ Definitivo.

Características:

* colores azul oscuro;
* integración con el tema;
* indicadores funcionales;
* transparencia ligera;
* inicio automático mediante:

```
exec_always "pkill -x waybar; exec waybar"
```

No se implementó ocultamiento automático al aproximar el ratón debido a limitaciones de Waybar. Se dejó visible por estabilidad.

---

# Wofi

Estado:

✔ Definitivo.

Características:

* tema oscuro;
* iconos;
* transparencia;
* búsqueda rápida;
* integrado con GTK.

Configuración:

```
~/.config/wofi/
```

Versión instalada:

```
wofi 1.5.3
```

No se consiguió una cuadrícula funcional (grid real). La versión incluida en openSUSE presenta limitaciones conocidas respecto a columnas y orientación horizontal.

Se restauró la configuración original tras las pruebas.

---

# Wlogout

Estado:

✔ Definitivo.

Configuración:

```
~/.config/wlogout/layout
~/.config/wlogout/style.css
```

Aspecto:

* transparencia;
* bordes redondeados;
* colores azules;
* iconos oficiales de wlogout;
* integración visual con Waybar.

Atajo:

```
Ctrl + KP_*
```

abre el menú de energía.

---

# swaylock

Estado:

✔ Funcional.

Configuración:

```
~/.config/swaylock/config
```

Características:

* colores consistentes;
* indicador circular;
* bloqueo automático mediante swayidle.

No fue posible mostrar el texto personalizado ("Digite contraseña"). La compilación incluida en openSUSE no parece soportar correctamente dicha característica.

---

# swayidle

Configurado mediante:

```
exec_always "pkill -x swayidle; exec swayidle -w timeout 120 'swaylock -f' timeout 600 'systemctl suspend' before-sleep 'swaylock -f'"
```

Comportamiento:

120 segundos

→ bloquear pantalla

600 segundos

→ suspender equipo

Antes de suspender:

→ bloquear pantalla.

---

# wob

Estado:

✔ Funcionando.

Utilizado para mostrar:

* brillo;
* volumen.

Inicializado automáticamente mediante FIFO.

---

# swaync

Estado:

✔ Funcionando.

Configuración:

```
~/.config/swaync/
```

Características:

* notificaciones modernas;
* colores coherentes con el tema;
* transparencia.

**Importante (actualizado 17/07/2026):** swaync ya **no** se lanza mediante `exec_always` en la config de Sway. Se gestiona exclusivamente vía `swaync.service` (systemd --user), como parte de la corrección de integración con `graphical-session.target`. Ver sección "Integración con systemd (uwsm)" para el detalle completo.

---

# Capturas de pantalla

Configuradas:

Pantalla completa

```
Print
```

Selección

```
Shift + Print
```

Pantalla completa al portapapeles

```
Ctrl + Print
```

Selección al portapapeles

```
Ctrl + Shift + Print
```

Editar inmediatamente

```
Alt + Print
```

Todas las capturas se almacenan automáticamente en

```
~/Imágenes/Capturas
```

---

# Audio

Volumen mediante

```
~/.local/bin/volume.sh
```

OSD mediante wob.

Atajos multimedia:

* F1
* F2
* F3
* teclas multimedia XF86.

---

# Brillo

Controlado mediante

```
~/.local/bin/brightness.sh
```

Visualización mediante wob.

---

# Portapapeles

Historial implementado con

```
cliphist
```

Atajo:

```
Ctrl + ñ
```

abre el historial utilizando Wofi.

---

# Atajos personalizados

## Aplicaciones

```
Super + Enter
```

Kitty.

```
Super + D
```

Wofi.

---

## Energía

```
Ctrl + KP_*
```

Wlogout.

---

## Bloqueo

```
Ctrl + KP_/
```

Swaylock.

---

## Capturas

```
Print
Shift + Print
Ctrl + Print
Ctrl + Shift + Print
Alt + Print
```

---

# Configuración principal

```
~/.config/sway/
```

---

# Copia de seguridad automatizada del HOME

Estado:

✔ Implementada y funcionando (17 de julio de 2026).

## Objetivo

Respaldar semanalmente las carpetas de trabajo del HOME en un único archivo `.zip`, sin acumular versiones antiguas ni dejar residuos temporales.

## Carpetas respaldadas

```
Documentos
Imágenes
Plantillas
Proyectos
Utilidades
Vídeos
Zotero
```

## Script

```
~/.local/bin/copia-seguridad
```

Permisos:

```
-rwx------ (700, solo el propietario puede ejecutarlo/editarlo)
```

Comportamiento del script:

1. Copia las carpetas anteriores a un directorio temporal oculto dentro del HOME (`~/.copia_seguridad_tmp.XXXXXX`, vía `mktemp -d`).
2. Comprime ese temporal en

```
~/Copia_Seguridad_home_YYYY-MM-DD_HH-MM.zip
```

3. Elimina cualquier `.zip` de copias de seguridad anteriores (queda solo la más reciente).
4. Elimina el directorio temporal automáticamente (`trap` en `EXIT`), incluso si el proceso falla a mitad de camino.

Primera ejecución de prueba, exitosa:

```
Archivo: /home/rcampor/Copia_Seguridad_home_2026-07-17_10-16.zip
Tamaño:  4,9G
```

## Automatización semanal (systemd, usuario)

Unidades creadas:

```
~/.config/systemd/user/copia-seguridad.service
~/.config/systemd/user/copia-seguridad.timer
```

El `.timer` está configurado para ejecutarse:

```
Cada domingo a las 20:00
```

con `Persistent=true`, de modo que si el equipo está apagado el domingo, el respaldo se ejecuta automáticamente al iniciar sesión más adelante (no se pierde ninguna semana).

Activado mediante:

```
systemctl --user daemon-reload
systemctl --user enable --now copia-seguridad.timer
```

Para que el timer funcione aunque no haya sesión gráfica activa a esa hora, se habilitó *lingering* para el usuario:

```
loginctl enable-linger rcampor
```

Verificación del estado del timer:

```
systemctl --user list-timers copia-seguridad.timer
```

Verificación de ejecuciones (logs):

```
journalctl --user -u copia-seguridad.service --since "3 days ago"
```

## Ejecución manual

Disponible en cualquier momento (por ejemplo, antes de un corte de energía o un viaje):

```
copia-seguridad
```

Requiere que `~/.local/bin` esté en el `PATH`, lo cual ya está confirmado para este usuario.

---

# Scripts personalizados

```
~/.local/bin/

brightness.sh
volume.sh
copia-seguridad
```

---

# Directorios importantes

```
~/.config/sway
~/.config/waybar
~/.config/wofi
~/.config/wlogout
~/.config/swaylock
~/.config/swaync
~/.config/systemd/user
~/.local/bin
~/Imágenes/fondos
~/Imágenes/Capturas
```

---

# Limpieza realizada

Eliminado:

* respaldo temporal de swaync;
* pruebas fallidas de Wlogout;
* respaldo temporal de Wofi;
* arranque duplicado de swaync vía `exec_always` (17/07/2026, ver sección "Integración con systemd").

Se conservaron únicamente las configuraciones utilizadas.

---

# Pendientes (no prioritarios)

## 1.

Actualizar Wofi a una versión futura que permita cuadrícula real.

Estado:

Pendiente.

Prioridad:

Baja.

---

## 2.

Evaluar Walker cuando llegue a los repositorios oficiales de openSUSE.

Estado:

Pendiente.

Prioridad:

Media.

---

## 3.

Explorar un tema GTK completo basado en Debian BlueSpace para unificar aplicaciones GTK4.

Estado:

Pendiente.

Prioridad:

Baja.

---

## 4.

Respaldar toda la configuración del escritorio en un repositorio Git privado.

Estado:

Pendiente (la copia de seguridad semanal en `.zip` cubre datos de trabajo, pero no reemplaza el versionado de la configuración de Sway/Waybar/Wofi/etc. en Git).

Prioridad:

Alta.

---

## 5.

Evaluar copiar la copia de seguridad semanal (`.zip`) hacia un destino externo (MEGA, disco externo, u otro equipo), ya que actualmente el respaldo vive en el mismo disco que el original.

Estado:

Pendiente.

Prioridad:

Alta.

---

## 6.

Evaluar instalación de un display manager gráfico (SDDM, GDM, greetd) si en el futuro se necesita selector visual de sesión o soporte multiusuario. No es necesario actualmente: uwsm ya resuelve toda la integración funcional con systemd, y el login por TTY + auto-arranque cubre el caso de uso actual sin procesos adicionales residentes.

Estado:

Pendiente.

Prioridad:

Baja.

---

# Estado final

El escritorio quedó moderno, ligero y consistente.

La estética se unificó alrededor de un esquema azul oscuro inspirado en Debian BlueSpace, con transparencias moderadas, iconografía coherente y aplicaciones integradas visualmente. Se evitó añadir componentes redundantes o soluciones experimentales que comprometieran la estabilidad.

Adicionalmente, quedó implementado un sistema de copia de seguridad semanal automatizado (script + systemd timer de usuario) que respalda las carpetas de trabajo en un único `.zip` fechado, sin acumular versiones antiguas ni dejar residuos.

Adicionalmente (17/07/2026), quedó resuelta la integración de Sway con `systemd --user` mediante `uwsm`, corrigiendo un problema de fondo que impedía que `xdg-desktop-portal` funcionara correctamente para cualquier aplicación Flatpak (no solo Spotify). El login por TTY ahora levanta la sesión gráfica completamente integrada de forma automática, sin necesidad de un display manager gráfico.

A partir de este punto, el tiempo invertido ofrece mucho más valor si se dedica al entorno de trabajo (R, Python, LaTeX, VS Code, Git, Zotero y herramientas de biología) que a seguir refinando la apariencia. El escritorio ya cumple su objetivo principal: ser una plataforma cómoda, rápida y fiable para trabajar.