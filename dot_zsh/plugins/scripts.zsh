# scripts.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

set_scripts_path() {
    if [ -d "$1" ]; then
        export SCRIPTS="$1"
        export PATH="$PATH:$1"
    fi
}

set_private_path() {
    if [ -d "$1" ]; then
        export PRIVATE="$1"
        export PATH="$PATH:$1"
    fi
}

set_private_path "$HOME/private/scripts"
set_scripts_path "$HOME/scripts"

unset set_scripts_path
unset set_private_path
