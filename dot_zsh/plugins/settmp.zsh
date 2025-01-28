# settmp.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

set_tmp_path() {
    TMP=${1:-/tmp}
    if [ -d "$1" ]; then
        TMP="$1"
    fi
    export TMP
    export TMPDIR=$TMP
    export TEMPDIR=$TMP
}

set_tmp_path "$HOME/.tmp"
unset set_tmp_path
