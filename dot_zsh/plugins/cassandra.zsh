# cassandra.zsh
# Last Change: 13-Jun-2013.
# Maintainer:  id774 <idnanashi@gmail.com>

set_cassandra_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1 ]; then
            export PATH=$1/bin:$PATH
        fi
        shift
    done
}

set_cassandra_path \
  /opt/cassandra/current

