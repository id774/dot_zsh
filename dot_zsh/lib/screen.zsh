# screen.zsh
# Last Change: 09-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

call_exec_screen() {
    case "${TERM-}" in
        linux|xterm-256color)
            return
            ;;
    esac

    if [ -z "${STY-}" ] && (( $+commands[screen] )); then
        exec screen -U -D -RR
    fi
}

call_exec_screen
unset -f call_exec_screen
