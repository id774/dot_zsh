#!/bin/zsh
#
########################################################################
# Install dot_zsh
#  $1 = path
#  $2 = nosudo
#
#  Maintainer: id774 <idnanashi@gmail.com>
#
#  v0.4 6/13,2013
#       If target exist, delete it.
#  v0.3 2/11,2012
#       Change default install target to /usr/local/etc/zsh.
#  v0.2 5/23,2011
#       Install zsh plugins to /etc/zsh/plugins.
#  v0.1 5/20,2011
#       First.
########################################################################

setup_environment() {
    test -n "$1" && export TARGET=$1
    test -n "$1" || export TARGET=/usr/local/etc/zsh
    #test -n "$1" || export TARGET=/etc/zsh
    #test -n "$1" || export TARGET=$HOME/.zsh
    test -n "$2" || SUDO=sudo
    test -n "$2" && SUDO=

    case $OSTYPE in
      *darwin*)
        OPTIONS=-Rv
        OWNER=root:wheel
        ;;
      *)
        OPTIONS=-Rvd
        OWNER=root:root
        ;;
    esac
}

set_permission() {
    $SUDO chown -R $OWNER $TARGET
}

zsh_compile() {
    zsh -c 'zcompile $SOURCE/dot_zsh/lib/load.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/lib/base.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/lib/screen.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/alias.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/apps.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/amazonaws.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/cryptfs.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/ldlib.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/prompt.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/proxy.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/java.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/incr.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/title.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/mysql.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/hadoop.zsh'
    zsh -c 'zcompile $SOURCE/dot_zsh/plugins/vcs_info.zsh'
}

zwc_cleanup() {
    rm -f $SOURCE/dot_zsh/lib/load.zsh.zwc
    rm -f $SOURCE/dot_zsh/lib/base.zsh.zwc
    rm -f $SOURCE/dot_zsh/lib/screen.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/alias.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/apps.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/amazonaws.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/cryptfs.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/ldlib.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/prompt.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/proxy.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/java.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/incr.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/title.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/mysql.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/hadoop.zsh.zwc
    rm -f $SOURCE/dot_zsh/plugins/vcs_info.zsh.zwc
}

install_dotzsh() {
    setup_environment $*
    test -d $TARGET && $SUDO rm -rf $TARGET
    $SUDO mkdir -p $TARGET
    zsh_compile
    $SUDO cp $OPTIONS $SOURCE/dot_zsh/* $TARGET/
    zwc_cleanup
    test -n "$2" || set_permission
}

export SOURCE=$HOME/dot_zsh
test -d $SOURCE/dot_zsh/plugins || exit 1
install_dotzsh $*
