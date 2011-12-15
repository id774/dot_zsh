# alias.zsh
# Last Change: 15-Dec-2011.
# Maintainer:  id774 <idnanashi@gmail.com>

set_alias() {
    alias pd='popd'
    alias gd='dirs -v; echo -n "select number: ";
    read newdir; cd +"$newdir" '
    alias sudo='sudo '
    alias -g L='| less'
    alias -g H='| head'
    alias -g T='| tail'
    alias -g G='| grep'
    alias -g S='| sed'
    alias -g A='| awk'
    alias -g W='| wc'
    alias g='gvim'
    alias v='vim'
    alias e='emacs -nw'
    alias em='emacs -nw'
    alias l='ls -ltra'
    alias d='ls -ltr'
    alias dir='ls -ltr'
    alias la='ls -a'
    alias a='ls -a'
    alias f='file'
    alias j='cd'
    alias c='cd'
    alias cl='clear'
    alias cls='clear'
    alias k='clear'
    alias copy='cp'
    alias move='mv'
    alias ren='mv'
    alias del='rm'
    alias md='mkdir'
    alias s='screen -U'
    alias scrr='screen -U -D -RR'
    alias mv='mv -vi'
    alias rm='rm -i'
}

set_alias
