# runcpp.zsh
# Last Change: 09-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

function runcpp() {
    if [ -z "${1-}" ]; then
        echo "Usage: runcpp <source_file> [args...]"
        return 1
    fi

    local src exe st
    src="$1"
    exe="$TMP/runcpp.$$.out"

    g++ -std=c++17 "$src" -o "$exe"
    if [ $? -ne 0 ]; then
        command rm -f "$exe"
        echo "Compilation failed."
        return 2
    fi

    shift
    "$exe" "$@"
    st=$?

    command rm -f "$exe"
    return "$st"
}

alias -s {c,cpp}=runcpp
