# base.zsh
# Last Change: 24-May-2011.
# Maintainer:  id774 <idnanashi@gmail.com>

set_gnu_env() {
    alias cp='cp -avi'
    if [ "$TERM" != "dumb" ]; then
        eval "`dircolors -b`"
        alias ls='ls --color=auto'
        alias dir='ls --color=auto --format=vertical'
        alias vdir='ls --color=auto --format=long'
    fi
}

set_linux_env() {
    export PATH=/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/bin/X11:/usr/X11R6/bin:/usr/games
    set_java_path /usr/lib/jvm/java-6-openjdk
    set_java_path /usr/lib/jvm/java-6-sun
    set_java_path /opt/java/jdk
}

set_solaris_env() {
    export PATH=/usr/gnu/bin:/usr/bin:/usr/X11/bin:/usr/sbin:/sbin
    set_java_path /usr/java
    set_java_path /opt/java/jdk
}

set_darwin_env() {
    alias cp='rsync -avz'
    alias finder='open .'
    alias gvim='open -a Vim'
    alias top='top -o cpu'
    alias fx='open -a Firefox'
    alias tb='open -a Thunderbird'
    if [ -f /usr/local/bin/fcd.sh ]; then
        alias fcd='source /usr/local/bin/fcd.sh'
    fi
    if [ "$TERM" != "dumb" ]; then
        alias ls='ls -G'
        alias dir='ls -G'
        alias vdir='ls -G'
    fi
    export PATH=/opt/sbin:/opt/bin:/opt/ruby/bin:/opt/python/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin:/usr/X11/bin
    export MANPATH=/usr/local/share/man:/usr/share/man:/opt/local/man:/usr/X11/man
    set_java_path /System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Home
    set_java_path /System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home
}

set_java_path() {
    if [ -d $1 ]; then
        export JAVA_HOME=$1
        export PATH=$JAVA_HOME/bin:$PATH
        export CLASSPATH=.:$JAVA_HOME/lib/tools.jar
    fi
}

set_os_env() {
    case $OSTYPE in
      *darwin*)
        set_darwin_env
        ;;
      *solaris*)
        set_gnu_env
        set_solaris_env
        ;;
      *)
        set_gnu_env
        set_linux_env
        ;;
    esac
}

set_terminal_options() {
    case "${TERM}" in
      *xterm*|rxvt|(dt|k|E)term)
        precmd() {
          echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
        }
        ;;
    esac

    case "${TERM}" in
      linux)
        export LANG=C
        ;;
      *)
        export LANG=ja_JP.UTF-8
        ;;
    esac
}

set_basic_options() {
    bindkey -e
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'
    autoload -U compinit ; compinit
    zstyle ':completion:*:default' menu select=1
    zstyle ':completion:*:processes' command 'ps x'
    setopt list_packed
    unsetopt auto_remove_slash
    setopt auto_param_slash
    setopt mark_dirs
    setopt list_types
    unsetopt menu_complete
    setopt auto_list
    setopt auto_menu
    setopt auto_param_keys
    setopt auto_resume
    autoload -U predict-on
    bindkey '^xp'  predict-on
    bindkey '^x^p' predict-off
    HISTFILE=$HOME/.zsh_history
    HISTSIZE=100000
    SAVEHIST=100000
    setopt extended_history
    setopt append_history
    setopt inc_append_history
    setopt share_history
    setopt hist_ignore_all_dups
    setopt hist_ignore_dups
    setopt hist_ignore_space
    unsetopt hist_verify
    setopt hist_reduce_blanks
    setopt hist_save_no_dups
    setopt hist_no_store
    setopt hist_expand
    function history-all { history -E 1 }
    autoload -U promptinit ; promptinit
    autoload -U colors     ; colors
    if [ "$TERM" != "dumb" ]; then
        zle -N predict-on
        zle -N predict-off
        PROMPT="%{$reset_color%}%{$fg[green]%}%(!.#.$) %{$reset_color%}"
        PROMPT="%{$reset_color%}%{$fg[green]%}:%{$fg[red]%}%B%~%b%{$reset_color%}$PROMPT"
        PROMPT="%{$reset_color%}%{$fg[yellow]%}%m%{$reset_color%}$PROMPT"
        PROMPT="%{$reset_color%}%{%(?.$fg[cyan].$fg[red])%}%*%{$reset_color%} $PROMPT"
    fi
    setopt auto_cd
    setopt auto_pushd
    setopt pushd_ignore_dups
    setopt pushd_to_home
    setopt pushd_silent
    alias pd='popd'
    alias gd='dirs -v; echo -n "select number: ";
    read newdir; cd +"$newdir" '
    setopt no_beep
    setopt complete_in_word
    setopt extended_glob
    setopt brace_ccl
    setopt equals
    setopt numeric_glob_sort
    setopt path_dirs
    setopt auto_name_dirs
    unsetopt flow_control
    setopt no_flow_control
    setopt hash_cmds
    setopt ignore_eof
    setopt bsd_echo
    setopt no_hup
    setopt no_checkjobs
    setopt notify
    setopt long_list_jobs
    setopt mail_warning
    setopt multios
    setopt short_loops
    setopt always_last_prompt
    setopt cdable_vars sh_word_split
    setopt rm_star_silent
    unsetopt no_clobber
    setopt no_unset
    setopt nolistbeep
    setopt magic_equal_subst
    setopt print_eightbit
    setopt print_exit_value
    LESS=-M
    export LESS
    if type /usr/bin/lesspipe &>/dev/null
    then
      LESSOPEN="| /usr/bin/lesspipe '%s'"
      LESSCLOSE="/usr/bin/lesspipe '%s' '%s'"
    fi
    umask 022
    ulimit -s unlimited
    limit coredumpsize 0
    export G_FILENAME_ENCODING=@locale
    alias sudo='sudo '
    alias -g L='| less'
    alias -g H='| head'
    alias -g T='| tail'
    alias -g G='| grep'
    alias -g S='| sed'
    alias -g A='| awk'
    alias -g W='| wc'
    alias g='gvim'
    alias vi='screen -U vim'
    alias v='vim'
    alias e='emacs -nw'
    alias em='screen -U emacs -nw'
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
    export RUBYOPT=rubygems
}

set_tmp_path() {
    if [ -d $1 ]; then
        export TMP=$1
    else
        export TMP=/tmp
    fi
    export TMPDIR=$TMP
    export TEMPDIR=$TMP
}

set_scripts_path() {
    if [ -d $1 ]; then
        export SCRIPTS=$1
        export PATH=$PATH:$SCRIPTS
    fi
}

set_private_path() {
    if [ -d $1 ]; then
        export PRIVATE=$1
        export PATH=$PATH:$PRIVATE
    fi
}

base_main() {
    set_basic_options
    set_terminal_options
    set_os_env
    set_tmp_path $HOME/.tmp
    set_private_path $HOME/private/scripts
    set_scripts_path $HOME/scripts
    test -d $HOME/bin && export PATH=$HOME/bin:$PATH
}

base_main
