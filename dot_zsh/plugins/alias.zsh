# alias.zsh
# Last Change: 20-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -d $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}

function runcpp () { g++ -std=c++0x $1 && shift && ./a.out $@ }

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
    alias g='git'
    alias v='vim'
    alias vv='vim .'
    alias p='vim -R'
    alias his='history -Di -30'
    alias hist='history -Di -100'
    alias history='history -Di'
    alias f='file'
    alias j='cd'
    alias jj='clear && cd'
    alias jk='ssh-add'
    alias c='cd'
    alias cl='clear'
    alias cls='clear'
    alias k='clear'
    alias kk='cltmp'
    alias x='exit'
    alias q='sudo pkill -9'
    alias qq='sudo kill -9'
    alias copy='cp'
    alias move='mv'
    alias ren='mv'
    alias del='rm'
    alias md='mkdir'
    alias s='screen -U'
    alias sc='screen -U'
    alias scd='screen -U -D'
    alias scdd='screen -U -D'
    alias scr='screen -U -D -RR'
    alias scrr='screen -U -D -RR'
    alias scls='screen -ls'
    alias scxr='screen -x -rU'
    alias mv='mv -vi'
    alias crontab='crontab -i'
    alias sshx="TERM=xterm-256color ssh"
    alias sshx256="TERM=xterm-256color ssh"
    alias be='bundle exec'
    alias sqlite3='sqlite3 -header -csv -nullvalue "NULL"'
    alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract
    alias -s {c,cpp}=runcpp

    case $OSTYPE in
      *darwin*)
        if [ "$UID" -eq 0 ]; then
          alias l='ls -Tltra'
          alias d='ls -Tltr'
          alias dir='ls -Tl'
          alias la='ls -Tla'
          alias a='ls -a'
          alias lt='ls -t'
          alias lr='ls -tr'
          alias ll='ls -Tltra'
          alias dl='ls -Tltr'
          alias rm='rm -i'
        else
          if type gls &> /dev/null; then
            alias l='gls --color=auto -ltra'
            alias d='gls --color=auto -ltr'
            alias dir='gls --color=auto -l'
            alias la='gls --color=auto -la'
            alias a='gls --color=auto -a'
            alias lt='gls --color=auto -t'
            alias lr='gls --color=auto -tr'
            alias ll='gls --color=auto -ltra'
            alias dl='gls --color=auto -ltr'
            alias ls='gls --color=auto'
            alias du='gdu'
            alias df='gdf'
            alias stat='gstat'
            alias sort='gsort'
            alias find='gfind'
            alias touch='gtouch'
            alias id='gid'
            alias date='gdate'
            alias basename='gbasename'
            alias dirname='gdirname'
            alias head='ghead'
            alias tail='gtail'
            alias cp='gcp -i'
            alias mv='gmv -i'
            alias rm='grm -i'
            alias cut='gcut'
            alias xargs='gxargs'
            alias wc='gwc'
            alias tee='gtee'
            alias uniq='guniq'
            alias shuf='gshuf'
            alias split='gsplit'
          else
            alias l='ls -Tltra'
            alias d='ls -Tltr'
            alias dir='ls -Tl'
            alias la='ls -Tla'
            alias a='ls -a'
            alias lt='ls -t'
            alias lr='ls -tr'
            alias ll='ls -Tltra'
            alias dl='ls -Tltr'
          fi
          if type trash &> /dev/null; then
            alias rm='trash'
          else
            alias rm='rm -i'
          fi
          alias finder='open .'
          alias top='top -o cpu'
          alias e='open -a Emacs'
          alias em='open -a Emacs'
          alias fx='open -a Firefox'
          alias firefox='open -a Firefox'
          alias tb='open -a Thunderbird'
          alias thunderbird='open -a Thunderbird'
          alias ch='open -a Google\ Chrome'
          alias chrome='open -a Google\ Chrome'
          if [ -x "/Applications/Emacs.app/Contents/MacOS/Emacs" ]; then
            alias emacs='/Applications/Emacs.app/Contents/MacOS/Emacs'
            alias emacs-compile='/Applications/Emacs.app/Contents/MacOS/Emacs --batch -Q -f batch-byte-compile'
          fi
        fi
        ;;
      *)
        alias l='ls -ltra'
        alias d='ls -ltr'
        alias dir='ls -l'
        alias la='ls -la'
        alias a='ls -a'
        alias lt='ls -t'
        alias lr='ls -tr'
        alias ll='ls -lZtra'
        alias dl='ls -lZtr'
        alias rm='rm -i'
        alias e='emacs -nw'
        alias em='emacs -nw'
        alias emacs-compile='emacs --batch -Q -f batch-byte-compile'
        ;;
    esac
}

set_alias
