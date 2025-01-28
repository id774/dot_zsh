# runcpp.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

function runcpp() {
    if [ -z "$1" ]; then
        echo "Usage: runcpp <source_file> [args...]"
        return 1
    fi

    src="$1"
    exe="${src%.*}.out"

    g++ -std=c++17 "$src" -o "$exe"
    if [ $? -ne 0 ]; then
        echo "Compilation failed."
        return 2
    fi

    shift
    ./"$exe" "$@"
}
