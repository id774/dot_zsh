# apps.zsh
# Last Change: 25-Feb-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

normalize_path() {
    echo "${1:-}" | sed 's:/*$::'
}

set_app_path() {
    dir=$(normalize_path "$1")
    bin_dir="$dir/bin"
    case "$dir" in
        *" "*) return ;;
    esac
    if [ -d "$bin_dir" ]; then
        export PATH="$bin_dir:$PATH"
    fi
}

set_apps_path() {
    [ -d /opt ] || return

    setopt localoptions nullglob

    for dir in /opt/*; do
        case "$dir" in
            *" "*) continue ;;
        esac
        [ -d "$dir" ] || continue
        set_app_path "$dir"
        set_app_path "$dir/current"
    done
    unset dir bin_dir
}

if [ "$(id -u)" -ne 0 ]; then
    set_apps_path
fi

unset -f normalize_path
unset -f set_app_path
unset -f set_apps_path
