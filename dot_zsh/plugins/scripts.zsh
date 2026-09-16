# scripts.zsh
# Last Change: 16-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

append_to_path_if_exists() {
    [ -d "$1" ] && export PATH="$1:$PATH"
}

set_private_path() {
    if [ -d "$1" ]; then
        export PRIVATE="$1"
        export PATH="$1:$PATH"
    fi
}

set_scripts_path() {
    if [ -d "$1" ]; then
        export SCRIPTS="$1"
        export PATH="$1:$PATH"
    fi
}

if (( EUID != 0 )); then
    set_scripts_path "$HOME/scripts"
    set_private_path "$HOME/private/scripts"
    append_to_path_if_exists "$HOME/.local/bin"
    append_to_path_if_exists "$HOME/bin"
fi

unset -f append_to_path_if_exists
unset -f set_private_path
unset -f set_scripts_path
