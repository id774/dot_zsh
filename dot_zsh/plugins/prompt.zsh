# prompt.zsh
# Last Change: 16-Dec-2011.
# Maintainer:  id774 <idnanashi@gmail.com>

autoload -U promptinit ; promptinit
autoload -U colors     ; colors
if [ "$TERM" != "dumb" ]; then
    zle -N predict-on
    zle -N predict-off
    PROMPT="%{$reset_color%}%{$fg[green]%}%(!.#.$) %{$reset_color%}"
    PROMPT="%{$reset_color%}%{$fg[green]%}:%{$fg[magenta]%}%B%~%b%{$reset_color%}$PROMPT"
    PROMPT="%{$reset_color%}%{$fg[yellow]%}%m%{$reset_color%}$PROMPT"
    PROMPT="%{$reset_color%}%{%(?.$fg[cyan].$fg[red])%}%*%{$reset_color%} $PROMPT"
fi
