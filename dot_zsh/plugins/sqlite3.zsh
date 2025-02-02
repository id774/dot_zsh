# sqlite3.zsh
# Last Change: 02-Feb-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

export SQLITE_TMPDIR="${TMP:-/tmp}"
alias sqlite-csv='sqlite3 -header -csv -nullvalue "NULL"'
