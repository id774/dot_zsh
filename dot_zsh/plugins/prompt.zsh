# prompt.zsh
# Last Change: 12-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

if [ "${TERM-}" != "dumb" ]; then
    PROMPT="%{$reset_color%}%{%(?.$fg[green].$fg[red])%}%(!.#.$) %{$reset_color%}"
    PROMPT="%{$reset_color%}%{$fg[green]%}:%{$fg[magenta]%}%B%~%b%{$reset_color%}$PROMPT"
    PROMPT="%{$reset_color%}%{$fg[yellow]%}%m%{$reset_color%}$PROMPT"
    PROMPT="%{$reset_color%}%{$fg[cyan]%}%*%{$reset_color%} $PROMPT"
fi
