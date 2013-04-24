# amazonaws.zsh
# Last Change: 24-Apr-2013.
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

export AWS_PATH=/opt/aws
export AWS_ELB_HOME=$AWS_PATH/apitools/elb
export AWS_IAM_HOME=$AWS_PATH/apitools/iam
export AWS_RDS_HOME=$AWS_PATH/apitools/rds
export AWS_AUTO_SCALING_HOME=$AWS_PATH/apitools/as
export AWS_CLOUDWATCH_HOME=$AWS_PATH/apitools/mon
export EC2_HOME=$AWS_PATH/apitools/ec2
export EC2_AMITOOL_HOME=$AWS_PATH/amitools/ec2
# export EC2_PRIVATE_KEY=$HOME/.aws/pk-XXXXXXXX.pem
# export EC2_CERT=$HOME/.aws/cert-XXXXXXXX.pem
# export EC2_URL=http://ec2.ap-northeast-1.amazonaws.com
# export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
# export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

set_aws_path \
  $AWS_PATH \
  $AWS_ELB_HOME \
  $AWS_IAM_HOME \
  $AWS_RDS_HOME \
  $AWS_AUTO_SCALING_HOME \
  $AWS_CLOUDWATCH_HOME \
  $EC2_HOME \
  $EC2_AMITOOL_HOME

