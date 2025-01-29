# extract.zsh
# Last Change: 30-Jan-2025.
# Maintainer: id774 <idnanashi@gmail.com>

function extract() {
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        echo "Usage: extract <filename>"
        return 1
    fi

    case "$1" in
        *.tar.gz|*.tgz) tar xzf "$1";;
        *.tar.xz) tar Jxf "$1";;
        *.zip) unzip "$1";;
        *.lzh) lha e "$1";;
        *.tar.bz2|*.tbz) tar xjf "$1";;
        *.tar.Z) tar xzf "$1";;
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
