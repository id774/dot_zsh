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

export EC2_HOME=/opt/aws
# export EC2_PRIVATE_KEY=$HOME/.aws/pk-XXXXXXXX.pem
# export EC2_CERT=$HOME/.aws/cert-XXXXXXXX.pem
# export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
# export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

set_aws_path \
  $EC2_HOME
