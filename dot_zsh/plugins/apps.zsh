# apps.zsh
# Last Change: 08-Jul-2013.
# Maintainer:  id774 <idnanashi@gmail.com>

set_app_path() {
    if [ -d $1/bin ]; then
        export PATH=$1/bin:$PATH
    fi
}

set_apps_path() {
    while [ $# -gt 0 ]
    do
        set_app_path /opt/$1
        set_app_path /opt/$1/current
        shift
    done
}

set_apps_path \
    ruby \
    python \
    mongo \
    maven \
    gauche \
    cassandra

