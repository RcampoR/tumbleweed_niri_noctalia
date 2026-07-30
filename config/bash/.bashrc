
# DE USUARIO
alias ff="fastfetch"
alias act='sudo zypper refresh && sudo zypper dup && sudo zypper clean --all && flatpak update && flatpak uninstall --unused'
alias ap='sudo shutdown -h now'
alias re='sudo shutdown -r now'


# GESTIÓN BATERIA

# ~/.bashrc
alias bat-eco='powerprofilesctl set power-saver'
alias bat-bal='powerprofilesctl set balanced'
alias bat-per='powerprofilesctl set performance'
alias bat-status="powerprofilesctl get &&
cat /sys/class/power_supply/BAT0/charge_control_end_threshold"
alias noctalia-r='pkill noctalia && sleep 1 && noctalia --daemon'
bat-limit() { echo "$1" | tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null; }


# TERMINAL
export TERMINAL=kitty

# Fastfetch solo al abrir una terminal interactiva de Kitty
if [[ $- == *i* ]] && [[ -n "$KITTY_WINDOW_ID" ]]; then
    fastfetch
fi

# Alias para modelos de Ollama
alias IA7='ollama run qwen2.5-coder:7b'
alias IA1='ollama run qwen2.5-coder:1.5b'

