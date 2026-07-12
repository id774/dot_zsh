# R.zsh
# Last Change: 12-Jul-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

set_r_path() {
    if [ -d "$1" ]; then
        export R_HOME="$1"
    fi
}

set_r_path /usr/lib/R
unset -f set_r_path
