# base.zsh
# Last Change: 30-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

append_to_path_if_exists() {
    [ -d "$1" ] && export PATH="$1:$PATH"
}

set_os_env() {
    case "$(uname)" in
        Darwin)
            export PATH="/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
            [ "$(id -u)" -ne 0 ] && append_to_path_if_exists "/usr/local/bin"
            ;;
        *)
            export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
            ;;
    esac

    if [ "$(id -u)" -ne 0 ]; then
        append_to_path_if_exists /usr/gnu/bin
        append_to_path_if_exists /opt/bin
        append_to_path_if_exists /opt/sbin
        append_to_path_if_exists /opt/local/sbin
    fi
}

set_terminal_options() {
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
    autoload -U promptinit ; promptinit
    autoload -U colors     ; colors
    autoload -U predict-on
    zle -N predict-on
    zle -N predict-off
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
    setopt auto_cd
    setopt auto_pushd
    setopt pushd_ignore_dups
    setopt pushd_to_home
    setopt pushd_silent
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
    setopt rc_quotes
    umask 022
    ulimit -s unlimited
    ulimit -c 0
    export G_FILENAME_ENCODING=@locale
    export TIME_STYLE=long-iso
}

base_main() {
    set_basic_options
    set_terminal_options
    set_os_env
}

base_main

unset -f append_to_path_if_exists
unset -f set_os_env
unset -f set_terminal_options
unset -f set_basic_options
unset -f base_main
