#!/usr/bin/env bash
#
# backup-sway-config.sh
#
# Copia la configuración completa del entorno Sway y greetd hacia:
#   ~/Utilidades/NOTAS/5_Utilidades/GV_linux/sway
#
# Uso:
#   chmod +x backup-sway-config.sh
#   ./backup-sway-config.sh
#
# Es seguro ejecutarlo varias veces (idempotente). No borra nada fuera
# del directorio de destino.

set -euo pipefail

DEST="$HOME/Utilidades/NOTAS/5_Utilidades/GV_linux/sway"
mkdir -p "$DEST"

echo "==> Destino: $DEST"

# ---------------------------------------------------------------------
# 1. Directorios de configuración (~/.config/*)
# ---------------------------------------------------------------------
CONFIG_DIRS=(
  sway
  waybar
  wofi
  wlogout
  swaylock
  swaync
  kitty
)

mkdir -p "$DEST/config"
for d in "${CONFIG_DIRS[@]}"; do
  if [ -d "$HOME/.config/$d" ]; then
    rsync -a --delete "$HOME/.config/$d/" "$DEST/config/$d/"
    echo "OK  : .config/$d"
  else
    echo "AVISO: no existe ~/.config/$d, se omite"
  fi
done

# ---------------------------------------------------------------------
# 2. Unidades systemd --user relevantes (timer de copia de seguridad)
# ---------------------------------------------------------------------
mkdir -p "$DEST/config/systemd-user"
for f in copia-seguridad.service copia-seguridad.timer; do
  if [ -f "$HOME/.config/systemd/user/$f" ]; then
    cp "$HOME/.config/systemd/user/$f" "$DEST/config/systemd-user/"
    echo "OK  : systemd/user/$f"
  else
    echo "AVISO: no existe systemd/user/$f, se omite"
  fi
done

# ---------------------------------------------------------------------
# 3. Configuración del gestor de sesiones (greetd)
# ---------------------------------------------------------------------
mkdir -p "$DEST/greetd"
if [ -f "/etc/greetd/config.toml" ]; then
  # Requiere sudo para leer la config del sistema
  sudo cp /etc/greetd/config.toml "$DEST/greetd/"
  sudo chown -R "$USER:$USER" "$DEST/greetd"
  echo "OK  : /etc/greetd/config.toml"
else
  echo "AVISO: no se encontró /etc/greetd/config.toml"
fi

# ---------------------------------------------------------------------
# 4. Scripts personalizados (~/.local/bin/*)
# ---------------------------------------------------------------------
mkdir -p "$DEST/local-bin"
for f in brightness.sh volume.sh copia-seguridad; do
  if [ -f "$HOME/.local/bin/$f" ]; then
    cp "$HOME/.local/bin/$f" "$DEST/local-bin/"
    echo "OK  : .local/bin/$f"
  else
    echo "AVISO: no existe .local/bin/$f, se omite"
  fi
done

# ---------------------------------------------------------------------
# 5. ~/.profile completo
# ---------------------------------------------------------------------
if [ -f "$HOME/.profile" ]; then
  cp "$HOME/.profile" "$DEST/profile"
  echo "OK  : ~/.profile"
else
  echo "AVISO: no se encontró ~/.profile"
fi

# ---------------------------------------------------------------------
# 6. Wallpaper
# ---------------------------------------------------------------------
WALLPAPER="$HOME/Imágenes/fondos/Debian_BlueSpace__3840x2160.png"
if [ -f "$WALLPAPER" ]; then
  mkdir -p "$DEST/wallpaper"
  cp "$WALLPAPER" "$DEST/wallpaper/"
  echo "OK  : wallpaper Debian_BlueSpace"
fi

echo ""
echo "==> Backup de configuración Sway completado en:"
echo "    $DEST"