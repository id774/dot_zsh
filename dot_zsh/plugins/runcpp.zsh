# runcpp.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

function runcpp () { g++ -std=c++0x $1 && shift && ./a.out $@ }
