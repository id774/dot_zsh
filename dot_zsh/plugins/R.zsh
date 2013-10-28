# R.zsh
# Last Change: 28-Oct-2013.
# Maintainer:  id774 <idnanashi@gmail.com>

set_r_path() {
    if [ -d $1 ]; then
        export R_HOME=$1
    fi
}

set_r_path /usr/lib/R
