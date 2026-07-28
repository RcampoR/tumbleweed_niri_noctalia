#!/usr/bin/env bash
#
# backup.sh — Respaldo reproducible del escritorio (openSUSE Tumbleweed + Niri + Noctalia)
#
# Proyecto: tumbleweed_niri_noctalia
# Licencia: MIT
#
# Este script NO es un gestor de dotfiles. Es una herramienta de ingeniería
# que convierte tu configuración de escritorio en un repositorio Git
# versionado, auditable y reproducible.
#
# Uso:
#   ./backup.sh              Ejecuta el respaldo completo
#   ./backup.sh --dry-run    Muestra qué haría, sin copiar ni hacer commit
#   ./backup.sh --no-scan    Omite el escaneo de patrones sospechosos (no recomendado)
#   ./backup.sh --help       Muestra esta ayuda
#
set -euo pipefail
IFS=$'\n\t'

# ──────────────────────────────────────────────────────────────────────────
# Configuración general
# ──────────────────────────────────────────────────────────────────────────

# Directorio raíz del proyecto (donde vive este script)
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="${PROJECT_ROOT}/config"
readonly SYSTEM_DIR="${PROJECT_ROOT}/system"
readonly LOG_FILE="${PROJECT_ROOT}/.backup.log"

# Directorio personal del usuario que ejecuta el script
readonly HOME_DIR="${HOME}"

# Modo de ejecución (se ajustan al parsear argumentos)
DRY_RUN=false
SKIP_SCAN=false

# Fecha y hora para mensajes de commit y logs
readonly TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
readonly DATE_ONLY="$(date '+%Y-%m-%d')"

# ──────────────────────────────────────────────────────────────────────────
# Mapa de configuraciones a respaldar: "nombre_legible:ruta_origen:destino"
# Si la ruta origen no existe, se ignora automáticamente sin error.
# Añadir nuevas entradas aquí es la única acción necesaria para ampliar
# la cobertura del respaldo.
# ──────────────────────────────────────────────────────────────────────────
readonly CONFIG_TARGETS=(
    "Niri:${HOME_DIR}/.config/niri:niri"
    "Noctalia:${HOME_DIR}/.config/noctalia:noctalia"
    "Kitty:${HOME_DIR}/.config/kitty:kitty"
    "GTK3:${HOME_DIR}/.config/gtk-3.0:gtk-3.0"
    "GTK4:${HOME_DIR}/.config/gtk-4.0:gtk-4.0"
    "Thunar:${HOME_DIR}/.config/Thunar:thunar"
    "VSCodium:${HOME_DIR}/.config/VSCodium/User:vscodium"
    "Bash:${HOME_DIR}/.bashrc:bash/.bashrc"
    "Bash profile:${HOME_DIR}/.bash_profile:bash/.bash_profile"
    "Git config:${HOME_DIR}/.gitconfig:git/.gitconfig"
    "mimeapps:${HOME_DIR}/.config/mimeapps.list:mimeapps.list"
)

# Rutas que NUNCA deben copiarse, bajo ninguna circunstancia.
# Se usan tanto como exclusión de rsync como para el .gitignore generado.
readonly NEVER_COPY=(
    ".ssh"
    ".gnupg"
    ".cache"
    ".local/share/keyrings"
    ".mozilla"
    ".var"
    ".config/gh"
    ".config/github-copilot"
)

# Patrones de contenido sospechoso (tokens, claves, certificados) usados
# en el escaneo previo a publicar. Se buscan dentro de config/ tras el
# respaldo, nunca fuera del repo del proyecto.
readonly SUSPICIOUS_PATTERNS=(
    '-----BEGIN [A-Z ]*PRIVATE KEY-----'
    '-----BEGIN CERTIFICATE-----'
    'ghp_[A-Za-z0-9]{30,}'
    'gho_[A-Za-z0-9]{30,}'
    'sk-[A-Za-z0-9]{20,}'
    'AKIA[0-9A-Z]{16}'
    'xox[baprs]-[A-Za-z0-9-]{10,}'
)

# ──────────────────────────────────────────────────────────────────────────
# Utilidades de salida
# ──────────────────────────────────────────────────────────────────────────

log() {
    local level="$1"; shift
    local color reset="\033[0m"
    case "$level" in
        INFO)  color="\033[0;36m" ;;
        OK)    color="\033[0;32m" ;;
        WARN)  color="\033[0;33m" ;;
        ERROR) color="\033[0;31m" ;;
        *)     color="" ;;
    esac
    printf "%b[%s]%b %s\n" "$color" "$level" "$reset" "$*"
    printf "[%s] [%s] %s\n" "$TIMESTAMP" "$level" "$*" >> "$LOG_FILE"
}

log_info()  { log INFO  "$@"; }
log_ok()    { log OK    "$@"; }
log_warn()  { log WARN  "$@"; }
log_error() { log ERROR "$@"; }

die() { log_error "$@"; exit 1; }

print_header() {
    echo
    echo "════════════════════════════════════════════════════════════"
    echo "  tumbleweed_niri_noctalia — respaldo de escritorio"
    echo "  $TIMESTAMP"
    echo "════════════════════════════════════════════════════════════"
    echo
}

print_help() {
    sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# ──────────────────────────────────────────────────────────────────────────
# Comprobaciones previas
# ──────────────────────────────────────────────────────────────────────────

check_dependencies() {
    local missing=()
    for cmd in rsync git rpm hostnamectl; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if ((${#missing[@]} > 0)); then
        die "Faltan dependencias requeridas: ${missing[*]}"
    fi
}

# ──────────────────────────────────────────────────────────────────────────
# Inicialización del repositorio Git
# ──────────────────────────────────────────────────────────────────────────

init_repo() {
    if [[ -d "${PROJECT_ROOT}/.git" ]]; then
        log_info "Repositorio Git ya inicializado."
        return
    fi

    if $DRY_RUN; then
        log_info "[dry-run] Se inicializaría un repositorio Git en ${PROJECT_ROOT}"
        return
    fi

    (cd "$PROJECT_ROOT" && git init -q)
    log_ok "Repositorio Git inicializado en ${PROJECT_ROOT}"
}

# ──────────────────────────────────────────────────────────────────────────
# Respaldo de configuraciones (rsync)
# ──────────────────────────────────────────────────────────────────────────

build_rsync_excludes() {
    local -a args=()
    local item
    for item in "${NEVER_COPY[@]}"; do
        args+=(--exclude="$item")
    done
    printf '%s\n' "${args[@]}"
}

backup_configs() {
    log_info "Respaldando configuraciones detectadas…"
    mkdir -p "$CONFIG_DIR"

    local entry name src dest full_dest found=0 skipped=0
    local -a rsync_excludes
    mapfile -t rsync_excludes < <(build_rsync_excludes)

    for entry in "${CONFIG_TARGETS[@]}"; do
        IFS=':' read -r name src dest <<< "$entry"

        if [[ ! -e "$src" ]]; then
            log_warn "Omitido (no existe): ${name} → ${src}"
            ((skipped++)) || true
            continue
        fi

        full_dest="${CONFIG_DIR}/${dest}"

        if $DRY_RUN; then
            log_info "[dry-run] Copiaría ${name}: ${src} → ${full_dest}"
            ((found++)) || true
            continue
        fi

        if [[ -d "$src" ]]; then
            mkdir -p "$full_dest"
            rsync -a --delete "${rsync_excludes[@]}" "${src}/" "${full_dest}/"
        else
            mkdir -p "$(dirname "$full_dest")"
            rsync -a "${rsync_excludes[@]}" "$src" "$full_dest"
        fi

        log_ok "Respaldado: ${name}"
        ((found++)) || true
    done

    log_info "Configuraciones respaldadas: ${found} · omitidas: ${skipped}"
    sanitize_gitconfig
}

# Elimina nombre y correo de la copia respaldada de .gitconfig antes de
# publicar. El .gitconfig ORIGINAL del usuario nunca se modifica; solo
# se sanea la copia dentro del repositorio.
sanitize_gitconfig() {
    local copy="${CONFIG_DIR}/git/.gitconfig"
    [[ -f "$copy" ]] || return 0

    if $DRY_RUN; then
        log_info "[dry-run] Se sanearía nombre/correo en ${copy}"
        return
    fi

    sed -i \
        -e '/^\s*name\s*=/d' \
        -e '/^\s*email\s*=/d' \
        "$copy"

    log_ok "Datos personales eliminados de la copia de .gitconfig"
}

# ──────────────────────────────────────────────────────────────────────────
# Exportación de información del sistema
# ──────────────────────────────────────────────────────────────────────────

export_system_info() {
    log_info "Exportando inventario del sistema…"
    mkdir -p "$SYSTEM_DIR"

    if $DRY_RUN; then
        log_info "[dry-run] Se generarían los archivos de inventario en ${SYSTEM_DIR}"
        return
    fi

    rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' 2>/dev/null | sort \
        > "${SYSTEM_DIR}/packages_rpm.txt"

    if command -v flatpak >/dev/null 2>&1; then
        flatpak list --app --columns=application,version,branch 2>/dev/null | sort \
            > "${SYSTEM_DIR}/packages_flatpak.txt"
    else
        echo "flatpak no está instalado en este sistema." \
            > "${SYSTEM_DIR}/packages_flatpak.txt"
    fi

    zypper lr -d 2>/dev/null > "${SYSTEM_DIR}/repositories.txt" \
        || echo "No se pudo leer la lista de repositorios (zypper)." \
            > "${SYSTEM_DIR}/repositories.txt"

    {
        echo "kernel: $(uname -r)"
        echo "arquitectura: $(uname -m)"
        echo "fecha_export: ${TIMESTAMP}"
    } > "${SYSTEM_DIR}/kernel.txt"

    hostnamectl 2>/dev/null > "${SYSTEM_DIR}/hostnamectl.txt" \
        || echo "hostnamectl no disponible." > "${SYSTEM_DIR}/hostnamectl.txt"

    {
        echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-desconocido}"
        echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-desconocido}"
        echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-desconocido}"
        echo "XDG_SESSION_DESKTOP=${XDG_SESSION_DESKTOP:-desconocido}"
        echo "NIRI_SOCKET=${NIRI_SOCKET:-desconocido}"
    } > "${SYSTEM_DIR}/wayland_env.txt"

    log_ok "Inventario del sistema exportado."
}

# ──────────────────────────────────────────────────────────────────────────
# Escaneo de patrones sospechosos antes de comprometer cambios
# ──────────────────────────────────────────────────────────────────────────

scan_for_secrets() {
    if $SKIP_SCAN; then
        log_warn "Escaneo de patrones sospechosos omitido (--no-scan)."
        return
    fi

    log_info "Escaneando config/ en busca de patrones sospechosos…"
    local pattern hits_total=0
    local -a hits=()

    for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
        if hits=$(grep -RlE "$pattern" "$CONFIG_DIR" 2>/dev/null); then
            while IFS= read -r file; do
                [[ -n "$file" ]] || continue
                log_warn "Coincidencia sospechosa en: ${file}"
                ((hits_total++)) || true
            done <<< "$hits"
        fi
    done

    if ((hits_total > 0)); then
        log_error "Se detectaron ${hits_total} archivo(s) con posibles secretos."
        log_error "Revísalos manualmente ANTES de hacer 'git push' a un repositorio público."
    else
        log_ok "Sin coincidencias sospechosas detectadas."
    fi
}

# ──────────────────────────────────────────────────────────────────────────
# Commit automático
# ──────────────────────────────────────────────────────────────────────────

commit_changes() {
    if $DRY_RUN; then
        log_info "[dry-run] Se evaluarían cambios para commit (sin ejecutar)."
        return
    fi

    cd "$PROJECT_ROOT"

    git add -A

    if git diff --cached --quiet; then
        log_info "Sin cambios detectados. No se genera commit."
        return
    fi

    local msg="Respaldo automático — ${DATE_ONLY}"
    git commit -q -m "$msg"
    log_ok "Commit creado: \"${msg}\""
}

# ──────────────────────────────────────────────────────────────────────────
# Punto de entrada
# ──────────────────────────────────────────────────────────────────────────

parse_args() {
    while (($# > 0)); do
        case "$1" in
            --dry-run) DRY_RUN=true ;;
            --no-scan) SKIP_SCAN=true ;;
            --help|-h) print_help; exit 0 ;;
            *) die "Argumento desconocido: $1 (usa --help)" ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"
    print_header
    $DRY_RUN && log_warn "Modo dry-run activo: no se copiará ni comprometerá nada."

    check_dependencies
    init_repo
    backup_configs
    export_system_info
    scan_for_secrets
    commit_changes

    echo
    log_ok "Proceso de respaldo finalizado."
    echo
}

main "$@"
