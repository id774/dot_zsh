# load.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

call_screen() {
    if [ -f "$HOME/.zsh/lib/screen.zsh" ]; then
        . "$HOME/.zsh/lib/screen.zsh"
    elif [ -f "/usr/local/etc/zsh/lib/screen.zsh" ]; then
        . "/usr/local/etc/zsh/lib/screen.zsh"
    elif [ -f "/etc/zsh/lib/screen.zsh" ]; then
        . "/etc/zsh/lib/screen.zsh"
    fi
}

load_plugins() {
    if [ -d "$HOME/.zsh/plugins" ]; then
        for ZSH_PLUGIN in "$HOME/.zsh/plugins"/*.zsh; do
            [ -f "$ZSH_PLUGIN" ] && . "$ZSH_PLUGIN"
        done
    elif [ -d "/usr/local/etc/zsh/plugins" ]; then
        for ZSH_PLUGIN in "/usr/local/etc/zsh/plugins"/*.zsh; do
            [ -f "$ZSH_PLUGIN" ] && . "$ZSH_PLUGIN"
        done
    elif [ -d "/etc/zsh/plugins" ]; then
        for ZSH_PLUGIN in "/etc/zsh/plugins"/*.zsh; do
            [ -f "$ZSH_PLUGIN" ] && . "$ZSH_PLUGIN"
        done
    fi
}

load_base() {
    if [ -f "$HOME/.zsh/lib/base.zsh" ]; then
        . "$HOME/.zsh/lib/base.zsh"
    elif [ -f "/usr/local/etc/zsh/lib/base.zsh" ]; then
        . "/usr/local/etc/zsh/lib/base.zsh"
    elif [ -f "/etc/zsh/lib/base.zsh" ]; then
        . "/etc/zsh/lib/base.zsh"
    fi
}

load_main() {
    load_base
    load_plugins
    [ -f "$HOME/.run_screen_on_startup" ] && call_screen
}

load_main "$@"
unset ZSH_PLUGIN
