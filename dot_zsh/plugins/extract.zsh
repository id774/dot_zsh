# extract.zsh
# Last Change: 12-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

function extract() {
    if [ -z "${1-}" ] || [ ! -f "$1" ]; then
        echo "Usage: extract <filename>"
        return 1
    fi

    local solaris=0
    [[ $OSTYPE == solaris* ]] && solaris=1

    case "$1" in
        *.tar.gz|*.tgz)
            if (( solaris )); then
                gzip -dc "$1" | tar xf -
            else
                tar xzf "$1"
            fi
            ;;
        *.tar.xz)
            if (( solaris )); then
                xz -dc "$1" | tar xf -
            else
                tar Jxf "$1"
            fi
            ;;
        *.zip) unzip "$1";;
        *.lzh) lha e "$1";;
        *.tar.bz2|*.tbz)
            if (( solaris )); then
                bzip2 -dc "$1" | tar xf -
            else
                tar xjf "$1"
            fi
            ;;
        *.tar.Z)
            if (( solaris )); then
                uncompress -c "$1" | tar xf -
            else
                tar xzf "$1"
            fi
            ;;
        *.gz) gzip -d "$1";;
        *.bz2) bzip2 -d "$1";;
        *.Z) uncompress "$1";;
        *.tar) tar xf "$1";;
        *.arj) unarj "$1";;
        *.7z) 7z x "$1";;
        *.rar) unrar x "$1";;
        *.xz) xz -d "$1";;
        *) echo "extract: Unsupported file type: $1"; return 2;;
    esac
}

alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz,7z,rar}=extract
