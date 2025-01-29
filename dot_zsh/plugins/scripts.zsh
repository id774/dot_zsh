# scripts.zsh
# Last Change: 29-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

append_to_path_if_exists() {
    [ -d "$1" ] && export PATH="$PATH:$1"
}

set_private_path() {
    export PRIVATE="$1"
    append_to_path_if_exists "$1"
}

set_scripts_path() {
    export SCRIPTS="$1"
    append_to_path_if_exists "$1"
}

set_private_path "$HOME/private/scripts"
set_scripts_path "$HOME/scripts"
append_to_path_if_exists "$HOME/.local/bin"
append_to_path_if_exists "$HOME/bin"

unset -f append_to_path_if_exists
unset -f set_private_path
unset -f set_scripts_path
