# maven.zsh
# Last Change: 06-Dec-2012.
# Maintainer:  id774 <idnanashi@gmail.com>

set_maven_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1 ]; then
            export PATH=$1/bin:$PATH
        fi
        shift
    done
}

set_maven_path \
  /opt/maven/3.0.4
