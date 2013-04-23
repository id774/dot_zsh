# amazonaws.zsh
# Last Change: 23-Apr-2013.
# Maintainer:  id774 <idnanashi@gmail.com>

set_aws_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1 ]; then
            export PATH=$1/bin:$PATH
        fi
        shift
    done
}

set_aws_path \
  /opt/aws
