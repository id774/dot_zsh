# title.zsh
# Last Change: 25-Mar-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

show_window_title() {
    case "$TERM" in
        screen*|tmux*)
            print -n "\ekzsh\e\\"
            chpwd() { echo -n "_$(dirs)\\" }
            preexec() {
                emulate -L zsh
                local -a cmd
                cmd=(${=2})

                case "$cmd[1]" in
                    fg)
                        if (( $#cmd == 1 )); then
                            cmd=(builtin jobs -l %+)
                        else
                            cmd=(builtin jobs -l "$cmd[2]")
                        fi
                        ;;
                    %*)
                        cmd=(builtin jobs -l "$cmd[1]")
                        ;;
                    cd)
                        if (( $#cmd == 2 )); then
                            cmd[1]="$cmd[2]"
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
                        echo -n "k${cmd[1]:t}\\"
                        return
                        ;;
                esac

                typeset -A jt
                for key in ${(k)jobtexts}; do
                    jt[$key]="${jobtexts[$key]}"
                done

                $cmd >>(read num rest
                        cmd=(${=jt[$num]})
                        echo -n "k${cmd[1]:t}\\") 2>/dev/null
            }
            chpwd
            ;;
    esac
}

show_window_title
unset -f show_window_title
