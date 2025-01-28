# title.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

show_window_title() {
    if [ "$TERM" = "screen" ]; then
        chpwd() { echo -n "_`dirs`\\" }
        preexec() {
            emulate -L zsh
            local -a cmd; cmd=(${(z)2})
            case $cmd[1] in
                fg)
                    if (( $#cmd == 1 )); then
                        cmd=(builtin jobs -l %+)
                    else
                        cmd=(builtin jobs -l $cmd[2])
                    fi
                    ;;
                %*)
                    cmd=(builtin jobs -l $cmd[1])
                    ;;
                cd)
                    if (( $#cmd == 2 )); then
                        cmd[1]=$cmd[2]
                    fi
                    ;;
                ls|gls|clear)
                    echo -n "k$ZSH_NAME\\"
                    return
                    ;;
                screen|pwd)
                    return
                    ;;
                *)
                    echo -n "k$cmd[1]:t\\"
                    return
                    ;;
            esac
            local -A jt; jt=(${(kv)jobtexts})
            $cmd >>(read num rest
                    cmd=(${(z)${(e):-\$jt$num}})
                    echo -n "k$cmd[1]:t\\") 2>/dev/null
        }
        chpwd
    fi
}

show_window_title
unset show_window_title
