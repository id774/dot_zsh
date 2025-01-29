# settmp.zsh
# Last Change: 30-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

set_tmp_path() {
    if [ -z "${TMP-}" ]; then
        TMP="${1}"
        [ -d "$TMP" ] || TMP="${2}"
        export TMP
        export TMPDIR="$TMP"
        export TEMPDIR="$TMP"
    fi
}

set_tmp_path "$HOME/.tmp" "/tmp"
unset -f set_tmp_path
