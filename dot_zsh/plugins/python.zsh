# python.zsh
# Last Change: 12-Jun-2013.
# Maintainer:  id774 <idnanashi@gmail.com>

set_python_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1 ]; then
            export PATH=$1/bin:$PATH
        fi
        shift
    done
}

set_python_path \
  /opt/python/current

