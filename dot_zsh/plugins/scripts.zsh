# scripts.zsh
# Last Change: 30-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

append_to_path_if_exists() {
    [ -d "$1" ] && export PATH="$1:$PATH"
}

set_private_path() {
    export PRIVATE="$1"
    append_to_path_if_exists "$1"
}

set_scripts_path() {
    export SCRIPTS="$1"
    append_to_path_if_exists "$1"
}

if [ "$(id -u)" -ne 0 ]; then
    set_scripts_path "$HOME/scripts"
    set_private_path "$HOME/private/scripts"
    append_to_path_if_exists "$HOME/bin"
fi

unset -f append_to_path_if_exists
unset -f set_private_path
unset -f set_scripts_path
