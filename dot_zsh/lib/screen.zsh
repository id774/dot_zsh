# screen.zsh
# Last Change: 13-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

call_exec_screen() {
    if [ -z "${STY-}" ] && (( $+commands[screen] )); then
        exec screen -U -D -RR
    fi
}

call_exec_screen
unset -f call_exec_screen
