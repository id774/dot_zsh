# alias.zsh
# Last Change: 22-Feb-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

alias pd='popd'
alias gd='dirs -v; echo -n "select number: "; read newdir; [ -n "$newdir" ] && cd +"$newdir" || echo "Invalid selection"'
alias sudo='sudo '
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g S='| sed'
alias -g A='| awk'
alias -g W='| wc'
alias g='git'
alias gs='git status'
alias gl='git log'
alias gd='git diff'
alias gu='git pull'
alias gp='git push'
alias ga='git add --all'
alias gc='git commit -a -v -m'
alias v='vim'
alias vv='vim .'
alias p='vim -R'
alias his='history -Di -30'
alias hist='history -Di -100'
alias hist-all='history -Di 1'
alias hist-edit='vim $HISTFILE'
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
alias cp='cp -avi'
alias mv='mv -vi'
alias rm='rm -i'
alias crontab='crontab -i'
alias sshx="TERM=xterm-256color ssh"
alias sshx256="TERM=xterm-256color ssh"

case "$(uname)" in
    Darwin)
        if [ "$TERM" != "dumb" ]; then
            alias ls='ls -G'
            alias dir='ls -G'
            alias vdir='ls -G'
        fi
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
        else
            if command -v gls >/dev/null 2>&1; then
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
                alias sort='gsort'
                alias touch='gtouch'
                alias id='gid'
                alias date='gdate'
                alias basename='gbasename'
                alias dirname='gdirname'
                alias head='ghead'
                alias tail='gtail'
                alias cp='gcp -avi'
                alias mv='gmv -vi'
                alias rm='grm -i'
                alias cut='gcut'
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
            [ -x "$(command -v gfind)" ] && alias find='gfind'
            [ -x "$(command -v gxargs)" ] && alias xargs='gxargs'
            [ -x "$(command -v trash)" ] && alias rm='trash'

            alias finder='open .'
            alias top='top -o cpu'

            [ -d "/Applications/Firefox.app" ] && {
                alias fx='open -a Firefox'
                alias firefox='open -a Firefox'
            }

            [ -d "/Applications/Thunderbird.app" ] && {
                alias tb='open -a Thunderbird'
                alias th='open -a Thunderbird'
                alias thunderbird='open -a Thunderbird'
            }

            [ -d "/Applications/Google Chrome.app" ] && {
                alias ch='open -a Google\ Chrome'
                alias chrome='open -a Google\ Chrome'
            }

            if [ -x "/Applications/Emacs.app/Contents/MacOS/Emacs" ]; then
                alias e='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'
                alias em='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'
                alias emacs='open -a Emacs'
                alias emacs-compile='/Applications/Emacs.app/Contents/MacOS/Emacs --batch -Q -f batch-byte-compile'
            fi
        fi
        ;;
    *)
        if [ "$TERM" != "dumb" ]; then
            alias ls='ls --color=auto'
            alias dir='ls --color=auto --format=vertical'
            alias vdir='ls --color=auto --format=long'
        fi
        alias l='ls -ltra'
        alias d='ls -ltr'
        alias dir='ls -l'
        alias la='ls -la'
        alias a='ls -a'
        alias lt='ls -t'
        alias lr='ls -tr'
        alias ll='ls -lZtra'
        alias dl='ls -lZtr'
        alias e='emacs -nw'
        alias em='emacs -nw'
        alias emacs-compile='emacs --batch -Q -f batch-byte-compile'
        ;;
esac
