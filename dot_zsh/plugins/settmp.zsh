# settmp.zsh
# Last Change: 16-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

set_tmp_path() {
    if [ -z "${TMP-}" ] && [ -d "$1" ]; then
        TMP="$1"
        export TMP
        export TMPDIR="$TMP"
        export TEMPDIR="$TMP"
    fi
}

set_tmp_path "$HOME/.tmp"
unset -f set_tmp_path
