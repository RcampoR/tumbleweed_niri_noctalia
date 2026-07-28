# Roadmap

## v1.0 — Respaldo e inventario (actual)

- [x] `backup.sh` con detección automática de configuraciones existentes.
- [x] Exclusión activa de rutas sensibles vía `rsync`.
- [x] Saneado de `.gitconfig` (nombre/correo).
- [x] Exportación de inventario del sistema (RPM, Flatpak, repos, kernel,
      `hostnamectl`, entorno Wayland).
- [x] Inicialización y commits automáticos de Git.
- [x] Escaneo de patrones sospechosos antes de publicar.
- [x] Modo `--dry-run`.

## v1.1 — Restauración parcial

- [ ] `scripts/restore.sh`: restaurar una configuración individual
      (por ejemplo, solo Niri) desde el repositorio al `$HOME` real.
- [ ] Confirmación explícita antes de sobrescribir archivos existentes.
- [ ] Copia de seguridad automática del archivo que se va a sobrescribir.

## v1.2 — Comparación entre snapshots

- [ ] `scripts/diff.sh`: comparar dos commits o etiquetas del repositorio
      y mostrar qué cambió en cada configuración.
- [ ] Generación de un informe legible (Markdown) por snapshot.

## v2.0 — Reconstrucción automática

- [ ] `scripts/provision.sh`: instalar paquetes RPM y Flatpaks listados en
      `system/` sobre una instalación limpia de openSUSE Tumbleweed.
- [ ] Aplicar automáticamente las configuraciones respaldadas.
- [ ] Verificación post-instalación (checklist de componentes activos).

Cada versión se apoya en la arquitectura de v1.0 sin necesidad de
reescrituras: `config/` y `system/` ya están estructurados para soportar
restauración, comparación y aprovisionamiento futuros.
