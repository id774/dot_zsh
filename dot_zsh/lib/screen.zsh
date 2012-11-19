# screen.zsh
# Last Change: 19-Nov-2012.
# Maintainer:  id774 <idnanashi@gmail.com>

call_exec_screen() {
    if [ "$TERM" != "linux" ]; then
        if [ `ps ax | grep screen | grep -v grep | wc -l` = 0 ]; then
            which screen > /dev/null 2>&1 && \
                exec screen -U -D -RR
        fi

        case "${TERM}" in
          *xterm*|rxvt|(dt|k|E)term)
            which screen > /dev/null 2>&1 && \
                exec screen -U -D -RR
            ;;
        esac
    fi
}

call_exec_screen
