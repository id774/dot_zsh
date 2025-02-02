# load.zsh
# Last Change: 02-Feb-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

[ -z "$ZSH_ROOT" ] && return

call_screen() {
    [ -f "$ZSH_ROOT/lib/screen.zsh" ] && . "$ZSH_ROOT/lib/screen.zsh"
}

load_plugins() {
    if [ -d "$ZSH_ROOT/plugins" ]; then
        for ZSH_PLUGIN in "$ZSH_ROOT/plugins"/*.zsh; do
            [ -f "$ZSH_PLUGIN" ] && . "$ZSH_PLUGIN"
        done
    fi
}

load_base() {
    [ -f "$ZSH_ROOT/lib/base.zsh" ] && . "$ZSH_ROOT/lib/base.zsh"
}

load_main() {
    load_base
    load_plugins
    [ -f "$HOME/.run_screen_on_startup" ] && call_screen
}

load_main "$@"

unset ZSH_PLUGIN
unset -f call_screen
unset -f load_plugins
unset -f load_base
unset -f load_main
