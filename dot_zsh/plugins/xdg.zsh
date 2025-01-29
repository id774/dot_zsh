# xdg.zsh
# Last Change: 30-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export PATH="$XDG_DATA_HOME/bin:$PATH"
export HISTFILE="$XDG_CACHE_HOME/history"
export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

append_to_path_if_exists() {
    [ -d "$1" ] && export PATH="$1:$PATH"
}

if [ "$(id -u)" -ne 0 ]; then
    append_to_path_if_exists "$HOME/.local/bin"
fi

unset -f append_to_path_if_exists
