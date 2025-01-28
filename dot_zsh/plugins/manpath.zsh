# manpath.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

set_manpath() {
    export MANPATH="/usr/share/man"

    if [ -d "/usr/local/share/man" ]; then
        export MANPATH="/usr/local/share/man:$MANPATH"
    fi
    if [ -d "/opt/homebrew/share/man" ]; then
        export MANPATH="/opt/homebrew/share/man:$MANPATH"
    fi
}

case $OSTYPE in
    *darwin*)
        set_manpath
        ;;
esac

unset -f set_manpath
