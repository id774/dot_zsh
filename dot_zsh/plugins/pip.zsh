# pip.zsh
# Last Change: 12-Sep-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

function _pip_completion {
    local words cword
    if is-at-least 5.0; then
        words=(${(z)${(Q)BUFFER}})
        cword=$(( ${#words} - 1 ))
        compadd -- $(COMP_WORDS="${words[*]}" \
                     COMP_CWORD=$cword \
                     PIP_AUTO_COMPLETE=1 "${words[1]}")
    else
        read -A words
        read -c cword
        reply=( $(COMP_WORDS="${words[*]}" \
                  COMP_CWORD=$((cword-1)) \
                  PIP_AUTO_COMPLETE=1 ${words[1]}) )
    fi
}

if is-at-least 5.0; then
    compdef _pip_completion pip
else
    zmodload zsh/compctl
    compctl -K _pip_completion pip
fi
