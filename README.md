# tumbleweed_niri_noctalia

Herramienta de respaldo, documentación e inventario reproducible para un
escritorio Linux basado en **openSUSE Tumbleweed + Niri + Noctalia**.

Esto **no es un repositorio de dotfiles**. Es una infraestructura versionada
con Git que convierte tu configuración de escritorio en un artefacto
reproducible, auditable y restaurable.

## ¿Qué hace?

`backup.sh`:

- Detecta automáticamente qué configuraciones existen en tu sistema y las
  sincroniza con `rsync` hacia `config/`.
- Ignora silenciosamente las configuraciones que no existan (sin errores).
- Exporta un inventario del sistema (`system/`): paquetes RPM, Flatpaks,
  repositorios, kernel, `hostnamectl`, variables de entorno Wayland.
- Inicializa un repositorio Git si no existe.
- Hace commit automáticamente **solo si hay cambios reales**.
- Sanea `.gitconfig` (elimina nombre y correo) antes de dejarlo en el repo.
- Escanea el contenido respaldado en busca de patrones típicos de secretos
  (tokens, claves privadas, certificados) antes de que tú decidas publicar.

## Qué NUNCA se copia

`~/.ssh`, `~/.gnupg`, `~/.cache`, `~/.local/share/keyrings`, `~/.mozilla`,
`~/.var`, `~/.config/gh`, `~/.config/github-copilot`, y cualquier archivo que
parezca un token, certificado o clave privada.

Estas exclusiones están implementadas en dos capas independientes: como
exclusión activa de `rsync` (nunca llegan al repo) y como red de seguridad en
`.gitignore` (por si algún día se añaden manualmente).

## Uso

```bash
./backup.sh              # Respaldo completo
./backup.sh --dry-run    # Simula el proceso sin copiar ni comprometer nada
./backup.sh --no-scan    # Omite el escaneo de secretos (no recomendado)
./backup.sh --help       # Ayuda
```

### Antes de tu primer `git push` a un repositorio público

1. Ejecuta `./backup.sh` (o `--dry-run` primero si quieres ver qué haría).
2. Revisa la salida del escaneo de patrones sospechosos.
3. Haz `git log -p` o revisa `config/` a mano si algo te genera duda.
4. Solo entonces, `git remote add origin ...` y `git push`.

El script te avisa si detecta algo sospechoso, pero **la responsabilidad
final de revisar antes de publicar es tuya**. Ninguna detección automática
sustituye una revisión humana en un repositorio público.

## Estructura

```text
tumbleweed_niri_noctalia/
├── backup.sh        # Script principal
├── README.md
├── LICENSE          # MIT
├── .gitignore
├── config/          # Configuraciones respaldadas (generado)
├── system/          # Inventario del sistema (generado)
├── docs/            # Documentación adicional
└── scripts/         # Utilidades futuras (restore.sh, diff.sh, etc.)
```

## Requisitos

- Bash ≥ 5
- `rsync`
- `git`
- `rpm` (nativo en openSUSE Tumbleweed)
- `hostnamectl` (systemd)
- `flatpak` (opcional; se detecta automáticamente)

## Roadmap

| Versión | Alcance |
|---|---|
| **v1.0** | Respaldo, documentación, inventario, Git automático |
| v1.1 | Restauración parcial (`restore.sh`) |
| v1.2 | Comparación entre snapshots |
| v2.0 | Reconstrucción automática del escritorio desde una instalación limpia |

Ver [docs/ROADMAP.md](docs/ROADMAP.md) para más detalle.

## Filosofía

Tratar el escritorio como un proyecto de software: versionado, auditable y
reproducible. El día que un disco falla o cambias de máquina, este
repositorio es la diferencia entre reconstruir tu entorno en minutos o
reconstruirlo de memoria.

## Licencia

MIT. Ver [LICENSE](LICENSE).
