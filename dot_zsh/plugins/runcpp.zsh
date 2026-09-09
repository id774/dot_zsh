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

    if [ -z "${TMP-}" ] || [ ! -d "${TMP-}" ]; then
        echo "runcpp: TMP is not available." >&2
        return 3
    fi

    exe="$TMP/runcpp.$$.$RANDOM.out"
    while [ -e "$exe" ]; do
        exe="$TMP/runcpp.$$.$RANDOM.out"
    done

    g++ -std=c++17 "$src" -o "$exe"
    if [ $? -ne 0 ]; then
        if ! command rm -f "$exe"; then
            echo "runcpp: Failed to remove temporary executable." >&2
            return 3
        fi
        echo "Compilation failed."
        return 2
    fi

    shift
    "$exe" "$@"
    st=$?

    if ! command rm -f "$exe"; then
        echo "runcpp: Failed to remove temporary executable." >&2
        return 3
    fi

    return "$st"
}

alias -s {c,cpp}=runcpp
