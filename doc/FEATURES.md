# DOT_ZSH Features

This document is a user-facing reference for how zsh behavior changes when
DOT_ZSH is installed.

It is not a complete reference for zsh itself, nor is it a complete manual for
the standard features provided by zsh. It documents behavior that DOT_ZSH
explicitly configures, enables, adds, or changes.

Specifically, it covers:

- shell startup and configuration load order
- shell options
- line editing
- completion
- history
- directory navigation
- globbing and expansion
- job control
- PATH
- locale
- temporary directories
- environment variables
- aliases
- commands provided by DOT_ZSH
- suffix aliases
- prompts
- VCS information
- GNU Screen and tmux integration
- language- and tool-specific settings
- platform-specific behavior
- zsh version-specific behavior
- behavior that differs between root and non-root users
- user-local customization
- every bundled plugin and its role

This document does not attempt to explain every standard zsh feature
used by the implementation. It explains the parts added or changed by DOT_ZSH.

The implementation remains authoritative. Source file names are included where
appropriate so that each behavior can be traced back to its configuration.


## 1. Startup and configuration load order

The DOT_ZSH startup path is:

    ~/.zshrc
      |
      +-- resolve ZSH_ROOT
      |
      +-- $ZSH_ROOT/lib/load.zsh
            |
            +-- $ZSH_ROOT/lib/base.zsh
            |
            +-- $ZSH_ROOT/plugins/*.zsh
            |
            +-- if $HOME/.run_screen_on_startup exists
            |     |
            |     +-- $ZSH_ROOT/lib/screen.zsh
            |
            +-- load.zsh returns
      |
      +-- if $HOME/.zshrc_local exists
            |
            +-- $HOME/.zshrc_local

The major configuration stages are therefore:

1. DOT_ZSH base configuration
2. all plugins
3. optional GNU Screen startup
4. user-local configuration

Because `~/.zshrc_local` is sourced last, it is the final override point for
environment variables, aliases, options, and other settings established by
DOT_ZSH.

Source:

    dot_zshrc
    dot_zsh/lib/load.zsh


## 2. ZSH_ROOT resolution

`~/.zshrc` selects exactly one DOT_ZSH configuration tree and exposes it as
`ZSH_ROOT`.

If `ZSH_ROOT` is already set and the following file exists:

    $ZSH_ROOT/lib/load.zsh

that tree is used directly.

No other directory is searched in that case.

If the preset `ZSH_ROOT` cannot be used, DOT_ZSH searches for `lib/load.zsh` in
this order:

    $HOME/.zsh
    $HOME/.config/zsh
    $HOME/.local/share/zsh
    /usr/local/etc/zsh
    /usr/local/share/zsh
    /etc/zsh
    /usr/share/zsh
    /opt/zsh

The first directory containing `lib/load.zsh` becomes `ZSH_ROOT`.

Configuration trees are not merged.

For example, creating only:

    ~/.zsh/plugins/

does not cause those plugins to load when:

    ~/.zsh/lib/load.zsh

does not exist.

When a user-level tree is selected, plugins from the system-wide tree are not
loaded automatically.

Source:

    dot_zshrc


## 3. Base shell behavior

`lib/base.zsh` is sourced before every DOT_ZSH plugin.

The shell options and completion infrastructure established here are therefore
available to plugins loaded afterward.

Source:

    dot_zsh/lib/base.zsh


## 4. Line editor

DOT_ZSH selects Emacs-style key bindings for the zsh line editor:

    bindkey -e

Interactive command-line editing therefore uses the Emacs-style editing map as
its base.

DOT_ZSH itself does not install a large separate set of custom key bindings
beyond the behavior documented here.

Source:

    dot_zsh/lib/base.zsh


## 5. Predictive input infrastructure

DOT_ZSH autoloads:

    predict-on

and registers:

    predict-on
    predict-off

as ZLE widgets.

Predictive input itself is not automatically enabled by the default DOT_ZSH
configuration.

The infrastructure is therefore available, but prediction does not run
continuously immediately after shell startup.

Source:

    dot_zsh/lib/base.zsh


## 6. Completion

DOT_ZSH initializes the zsh completion system at startup.

The primary initialization is:

    autoload -U compinit
    compinit

When `compaudit` is available, DOT_ZSH runs it as well.

Completion candidate colors use `LS_COLORS`.

If `LS_COLORS` is unset and `dircolors` is available, DOT_ZSH derives
`LS_COLORS` from `dircolors`.

The completion system is configured to:

- use a candidate menu
- permit menu selection beginning with the first candidate
- color completion candidates
- use `ps x` for process completion
- use a dedicated color rule for processes offered to `kill`
- display candidate lists in packed form
- mark directory candidates by type
- control slash handling for parameter completion
- show completion candidates automatically
- use a menu when multiple candidates exist
- complete from inside a word

The principal related options are:

    LIST_PACKED
    AUTO_PARAM_SLASH
    MARK_DIRS
    LIST_TYPES
    AUTO_LIST
    AUTO_MENU
    AUTO_PARAM_KEYS
    COMPLETE_IN_WORD

The following are disabled:

    AUTO_REMOVE_SLASH
    MENU_COMPLETE

Source:

    dot_zsh/lib/base.zsh


## 7. History

DOT_ZSH stores shell history in:

    $HOME/.zsh_history

The configured sizes are:

    HISTSIZE=10000
    SAVEHIST=10000

The in-memory history and saved history therefore use 10,000 entries as their
configured limits.


### 7.1 Extended history

DOT_ZSH enables:

    EXTENDED_HISTORY

This uses the zsh extended history format, which can retain metadata such as
timestamps and command duration.


### 7.2 Append history

DOT_ZSH enables:

    APPEND_HISTORY
    INC_APPEND_HISTORY

History is appended rather than being rewritten only when a session exits.

Interactive sessions also write history incrementally.


### 7.3 Shared history

DOT_ZSH enables:

    SHARE_HISTORY

History is shared among multiple zsh sessions.


### 7.4 Duplicate suppression

DOT_ZSH enables:

    HIST_IGNORE_ALL_DUPS
    HIST_IGNORE_DUPS
    HIST_SAVE_NO_DUPS

These options suppress duplicate commands in retained and saved history.


### 7.5 Space-prefixed commands

DOT_ZSH enables:

    HIST_IGNORE_SPACE

Commands beginning with a space are not stored in history.


### 7.6 Blank reduction

DOT_ZSH enables:

    HIST_REDUCE_BLANKS

Unnecessary blanks are reduced when commands are stored in history.


### 7.7 Internal history commands

DOT_ZSH enables:

    HIST_NO_STORE

Commands that zsh identifies as history operations that should not themselves
be stored are omitted from history.


### 7.8 History expansion

DOT_ZSH enables:

    HIST_EXPAND

History expansion is enabled.


### 7.9 HIST_VERIFY

DOT_ZSH disables:

    HIST_VERIFY

Source:

    dot_zsh/lib/base.zsh


## 8. Directory navigation

DOT_ZSH enables several zsh features that make directory navigation more
automatic than in a plain default configuration.


### 8.1 AUTO_CD

DOT_ZSH enables:

    AUTO_CD

A directory name entered in command position can be treated as a directory
change without explicitly writing `cd`.


### 8.2 AUTO_PUSHD

DOT_ZSH enables:

    AUTO_PUSHD

Changing directories automatically updates the directory stack.


### 8.3 PUSHD_IGNORE_DUPS

DOT_ZSH enables:

    PUSHD_IGNORE_DUPS

Duplicate directories are suppressed in the directory stack.


### 8.4 PUSHD_TO_HOME

DOT_ZSH enables:

    PUSHD_TO_HOME

`pushd` without an argument uses the home directory.


### 8.5 PUSHD_SILENT

DOT_ZSH enables:

    PUSHD_SILENT

Unnecessary directory-stack output is suppressed during `pushd` operations.


### 8.6 CDABLE_VARS

DOT_ZSH enables:

    CDABLE_VARS

Parameter names can be used as directory targets by `cd`.


### 8.7 AUTO_NAME_DIRS

DOT_ZSH enables:

    AUTO_NAME_DIRS

Parameters that contain directory paths can be used as zsh named directories.

Source:

    dot_zsh/lib/base.zsh


## 9. Globbing and expansion

DOT_ZSH enables several extended zsh globbing and expansion features.


### 9.1 EXTENDED_GLOB

DOT_ZSH enables:

    EXTENDED_GLOB

Extended zsh glob syntax becomes available.


### 9.2 BRACE_CCL

DOT_ZSH enables:

    BRACE_CCL

Character classes can be used in brace expansion.


### 9.3 NUMERIC_GLOB_SORT

DOT_ZSH enables:

    NUMERIC_GLOB_SORT

Numeric portions of glob results are considered numerically rather than only
lexicographically.


### 9.4 EQUALS

DOT_ZSH enables:

    EQUALS

The `=command` form can expand to the path of a command.


### 9.5 PATH_DIRS

DOT_ZSH enables:

    PATH_DIRS

PATH-based lookup is used for command names in cases where zsh would otherwise
treat the path differently.


### 9.6 MAGIC_EQUAL_SUBST

DOT_ZSH enables:

    MAGIC_EQUAL_SUBST

Filename expansion is supported on the right-hand side of arguments in forms
such as `name=value`.

Source:

    dot_zsh/lib/base.zsh


## 10. Shell word splitting

DOT_ZSH enables:

    SH_WORD_SPLIT

This is an important difference from the normal zsh default.

Unquoted parameter expansions can undergo Bourne-shell-like word splitting.

For that reason, the DOT_ZSH implementation policy requires parameter
expansions to be quoted unless splitting is intentional.

Source:

    dot_zsh/lib/base.zsh
    doc/POLICY.md


## 11. Flow control

Terminal flow control is disabled through:

    NO_FLOW_CONTROL

This makes control characters normally associated with terminal flow control
available for line-editing use.

Source:

    dot_zsh/lib/base.zsh


## 12. Command hashing

DOT_ZSH enables:

    HASH_CMDS

zsh can cache command locations and reuse them for later command lookup.

Source:

    dot_zsh/lib/base.zsh


## 13. EOF behavior

DOT_ZSH enables:

    IGNORE_EOF

An EOF entered in an interactive shell therefore does not immediately terminate
the shell in the ordinary way.

This reduces accidental termination of an interactive terminal session.

Source:

    dot_zsh/lib/base.zsh


## 14. Job and process behavior

DOT_ZSH changes several job-control behaviors.


### 14.1 HUP handling

DOT_ZSH enables:

    NO_HUP

zsh does not send HUP to jobs as part of normal shell termination behavior.


### 14.2 Running-job checks

DOT_ZSH enables:

    NO_CHECK_JOBS

The normal check for active jobs when the shell exits is suppressed.


### 14.3 Job notifications

DOT_ZSH enables:

    NOTIFY

Background-job state changes can be reported without waiting for the next
ordinary prompt cycle.


### 14.4 Long job listings

DOT_ZSH enables:

    LONG_LIST_JOBS

Job information is displayed in the long format.


### 14.5 Automatic job resumption

DOT_ZSH enables:

    AUTO_RESUME

A simple command that matches a stopped job can resume that job instead of
starting a new command with the same name.


### 14.6 Mail warnings

DOT_ZSH enables:

    MAIL_WARNING

zsh mail-file warning behavior is enabled.

Source:

    dot_zsh/lib/base.zsh


## 15. Redirection and shell syntax

DOT_ZSH enables:

    MULTIOS
    SHORT_LOOPS
    ALWAYS_LAST_PROMPT
    BSD_ECHO
    RC_QUOTES


### MULTIOS

zsh multios behavior is enabled, allowing one command output to be redirected
to multiple destinations.


### SHORT_LOOPS

zsh short loop syntax is enabled.


### ALWAYS_LAST_PROMPT

Where possible, zsh reuses the original prompt line after a completion list is
displayed.


### BSD_ECHO

`echo` follows the corresponding BSD-style interpretation selected by this zsh
option.


### RC_QUOTES

Consecutive single quotes can represent a quote inside single-quoted text using
the zsh `RC_QUOTES` behavior.

Source:

    dot_zsh/lib/base.zsh


## 16. File overwrite behavior

DOT_ZSH disables:

    NO_CLOBBER

Normal `>` redirection can therefore overwrite an existing file.

Source:

    dot_zsh/lib/base.zsh


## 17. Unset parameter behavior

DOT_ZSH enables:

    NO_UNSET

Unconditional access to an unset parameter is treated more strictly and can
produce an error.

DOT_ZSH therefore uses forms such as:

    ${VAR-}
    ${VAR:-default}

when a parameter may legitimately be unset.

Source:

    dot_zsh/lib/base.zsh
    doc/POLICY.md


## 18. Beep behavior

DOT_ZSH suppresses shell beeps through:

    NO_BEEP
    NOLISTBEEP

Completion lists and related shell operations therefore do not use the normal
audible beep behavior.

Source:

    dot_zsh/lib/base.zsh


## 19. rm glob confirmation

DOT_ZSH enables:

    RM_STAR_SILENT

zsh itself does not add its extra confirmation for operations such as `rm *`.

`alias.zsh` normally gives `rm` an interactive option separately, so the final
deletion behavior is also affected by the alias configuration.

Source:

    dot_zsh/lib/base.zsh
    dot_zsh/plugins/alias.zsh


## 20. Character display

DOT_ZSH enables:

    PRINT_EIGHT_BIT

8-bit characters can be treated as printable characters.

Source:

    dot_zsh/lib/base.zsh


## 21. Command exit status

DOT_ZSH enables:

    PRINT_EXIT_VALUE

When a command exits with a nonzero status, zsh reports the exit status.

As a result, the status of the final command in a startup file can itself
become user-visible.

`dot_zshrc` uses an `if` statement rather than a simple `&&` test for
`~/.zshrc_local` so that an absent local file does not leave a failed status
that appears at the first prompt.

Source:

    dot_zsh/lib/base.zsh
    dot_zshrc


## 22. umask

DOT_ZSH sets:

    umask 022

Permissions of newly created files and directories are affected by this umask.

Source:

    dot_zsh/lib/base.zsh


## 23. Resource limits

DOT_ZSH sets:

    ulimit -s unlimited
    ulimit -c 0

The stack size is made unlimited and the core-dump size is set to zero.

Source:

    dot_zsh/lib/base.zsh


## 24. Locale

`LANG` is selected according to `TERM`.

For the Linux console:

    TERM=linux
    LANG=C

For other terminal types:

    LANG=ja_JP.UTF-8

DOT_ZSH also exports:

    G_FILENAME_ENCODING=@locale

Source:

    dot_zsh/lib/base.zsh


## 25. Time display format

DOT_ZSH exports:

    TIME_STYLE=long-iso

Commands that honor `TIME_STYLE`, including relevant GNU tools, can therefore
use the long ISO timestamp format.

Source:

    dot_zsh/lib/base.zsh


## 26. Base PATH

DOT_ZSH rebuilds the base PATH during startup.


### 26.1 macOS

On macOS, the initial base PATH is:

    /usr/local/sbin
    /usr/bin
    /bin
    /usr/sbin
    /sbin

For a non-root user, `/usr/local/bin` is prepended when that directory exists.


### 26.2 Other platforms

On other platforms, the base PATH is:

    /usr/local/sbin
    /usr/local/bin
    /sbin
    /bin
    /usr/sbin
    /usr/bin


### 26.3 Non-root additions

For a non-root user, each of the following directories is prepended when it
exists:

    /usr/gnu/bin
    /opt/bin
    /opt/sbin
    /opt/local/sbin

Directories that do not exist are skipped.

Source:

    dot_zsh/lib/base.zsh


## 27. Plugin loading

After `lib/base.zsh` has run, DOT_ZSH sources:

    $ZSH_ROOT/plugins/*.zsh

Plugins are not registered in a separate enable list.

Every `.zsh` file present in the plugin directory is sourced automatically.

The current implementation loads those files in filename order.

Load order can therefore matter when one plugin uses an environment variable
set by an earlier plugin.

For example, `settmp.zsh` can establish `TMP`, and the later `sqlite3.zsh`
plugin uses that value for `SQLITE_TMPDIR`.

Source:

    dot_zsh/lib/load.zsh


## 28. Plugin list

DOT_ZSH currently contains 19 plugins:

    R.zsh
    alias.zsh
    apps.zsh
    extract.zsh
    java.zsh
    ldlib.zsh
    mysql.zsh
    pager.zsh
    pip.zsh
    prompt.zsh
    proxy.zsh
    python.zsh
    ruby.zsh
    runcpp.zsh
    scripts.zsh
    settmp.zsh
    sqlite3.zsh
    title.zsh
    vcs_info.zsh


## 29. R.zsh

Role:

    R environment

When `/usr/lib/R` exists, DOT_ZSH exports:

    R_HOME=/usr/lib/R

When that directory does not exist, `R_HOME` is not changed by this plugin.

Source:

    dot_zsh/plugins/R.zsh


## 30. alias.zsh

Role:

    command aliases

This plugin has one of the largest user-visible effects in DOT_ZSH.

It provides short command names, but it also changes invocation behavior for
existing commands such as:

    cp
    mv
    rm
    ls
    find
    sort

The final aliases depend on the platform, whether the shell belongs to root,
which commands are installed, and which applications are present.

Source:

    dot_zsh/plugins/alias.zsh


## 31. Common aliases

The following major aliases are defined independently of platform.


### Directory stack

    pd='popd'


### sudo

    sudo='sudo '

The trailing space allows aliases following `sudo` to be expanded as well.


## 32. Git aliases

DOT_ZSH defines:

    g='git'

    gs='git status'
    gst='git status'

    gci='git commit -v'

    ga='git add'
    gaa='git add --all'

    gd='git diff'
    gdi='git diff'

    gb='git branch'
    gbr='git branch'

    gco='git checkout'

    gl='git log'
    glp='git log -p'

    gu='git pull'

    gp='git push'
    gpu='git push'


## 33. Vim aliases

DOT_ZSH defines:

    v='vim'
    vv='vim .'

    p='vim -R'
    pp='vim -R .'

`p` and `pp` start Vim in read-only mode.


## 34. History aliases

DOT_ZSH defines:

    h='history -Di -30'
    his='history -Di -50'
    hist='history -Di -100'
    hist-all='history -Di 1'

These show recent history or the complete history at different ranges.

DOT_ZSH also defines:

    hist-edit='vim $HISTFILE'

which opens the history file directly in Vim.

The following aliases are also defined:

    eh='erase_history'
    hh='erase_history'

and DOT_ZSH exports:

    ERASE_HISTORY_SELF_NAMES=eh,hh

`erase_history` itself is not implemented by this plugin and is expected to be
provided by the surrounding environment.


## 35. File-type alias

DOT_ZSH defines:

    f='file'


## 36. Directory aliases

DOT_ZSH defines:

    j='cd'
    c='cd'

    jj='clear && cd'

    jjj='clear && cd && cltmp && mail'

`jjj` expects `cltmp` and `mail` to be available.


## 37. SSH key alias

DOT_ZSH defines:

    jk='ssh-add'


## 38. Clear aliases

DOT_ZSH defines:

    cl='clear'
    cls='clear'
    k='clear'


## 39. Temporary cleanup aliases

DOT_ZSH defines:

    kk='cltmp'

    kkk='clear && cd && cltmp && mail'

`cltmp` is expected to be supplied by an external command or function; it is
not defined by this DOT_ZSH plugin.


## 40. Exit aliases

DOT_ZSH defines:

    x='exit'
    xx='exit'


## 41. Process-kill aliases

DOT_ZSH defines:

    q='sudo pkill -9'
    qq='sudo kill -9'

These are short aliases that explicitly use signal 9.

`q` is intended to pass a process name or similar argument to `pkill`, while
`qq` passes an argument such as a PID to `kill`.


## 42. File-operation aliases

The common definitions are:

    cp='cp -avi'
    mv='mv -vi'
    rm='rm -i'

Normal `cp`, `mv`, and `rm` therefore become more interactive and verbose than
their unaliased forms.

Additional aliases are:

    copy='cp -avi'
    move='mv -vi'
    ren='mv -vi'
    del='rm -vi'

Directory-operation aliases are:

    md='mkdir -v'
    rd='rmdir -v'


## 43. Mail aliases

DOT_ZSH defines:

    m='mail'

    mm='cltmp && mail'

    mmm='clear && cd && cltmp && mail'

Aliases that use `cltmp` require that external command or function to be
available.


## 44. Directory-stack selector

DOT_ZSH defines an interactive alias equivalent to:

    sc='dirs -v; echo -n "select number: "; read newdir; ...'

`sc` displays the current directory stack with numbers, reads a number from the
user, and changes directory using:

    cd +number


## 45. GNU Screen aliases

DOT_ZSH defines:

    s='screen -U'

    scd='screen -U -D'
    scdd='screen -U -D'

    scr='screen -U -D -RR'
    scrr='screen -U -D -RR'

    scls='screen -ls'

    scxr='screen -x -rU'


## 46. crontab alias

DOT_ZSH defines:

    crontab='crontab -i'

The interactive form of `crontab` is therefore used.


## 47. SSH terminal aliases

DOT_ZSH defines:

    sshx='TERM=xterm-256color ssh'
    sshx256='TERM=xterm-256color ssh'

These start SSH with `TERM` set to `xterm-256color`.


## 48. macOS aliases

Alias behavior has additional branches on macOS.


### 48.1 ls color

When `TERM` is not `dumb`, DOT_ZSH initially defines:

    ls='ls -G'
    dir='ls -G'
    vdir='ls -G'


### 48.2 macOS root user

For root, DOT_ZSH defines BSD `ls`-oriented aliases:

    l='ls -Tltra'
    d='ls -Tltr'
    dir='ls -Tl'
    la='ls -Tla'
    a='ls -a'
    lt='ls -t'
    lr='ls -tr'
    ll='ls -Tltra'
    dl='ls -Tltr'


### 48.3 macOS non-root with GNU coreutils

For a non-root user, when `gls` is available, DOT_ZSH maps many commands to
their GNU counterparts.

Listing aliases:

    l='gls --color=auto -ltra'
    d='gls --color=auto -ltr'
    dir='gls --color=auto -l'
    la='gls --color=auto -la'
    a='gls --color=auto -a'
    lt='gls --color=auto -t'
    lr='gls --color=auto -tr'
    ll='gls --color=auto -ltra'
    dl='gls --color=auto -ltr'
    ls='gls --color=auto'

Disk-usage aliases:

    du='gdu'
    duh='gdu -h'
    dum='gdu --max-depth=1'
    dua='gdu --apparent-size --max-depth=1'
    duhm='gdu -h --max-depth=1'
    duha='gdu -h --apparent-size --max-depth=1'

Disk-free alias:

    df='gdf'

Other GNU utility aliases:

    sort='gsort'
    touch='gtouch'
    id='gid'
    date='gdate'
    basename='gbasename'
    dirname='gdirname'
    head='ghead'
    tail='gtail'

File-operation aliases:

    cp='gcp -avi'
    mv='gmv -vi'
    rm='grm -i'
    del='grm -vi'

Directory-operation aliases:

    mkdir='gmkdir'
    rmdir='grmdir'
    md='gmkdir -v'
    rd='grmdir -v'

Text utility aliases:

    cut='gcut'
    wc='gwc'
    tee='gtee'
    uniq='guniq'
    shuf='gshuf'
    split='gsplit'


### 48.4 gfind and gxargs

When available, DOT_ZSH defines:

    find='gfind'
    xargs='gxargs'


### 48.5 trash

When the `trash` command is available for a non-root macOS user, DOT_ZSH
defines:

    rm='trash'

This definition occurs after the earlier `rm='grm -i'` or ordinary interactive
`rm` definition.

The final `rm` command therefore sends files through `trash` instead of
directly removing them when this condition is met.


### 48.6 Finder

DOT_ZSH defines:

    finder='open .'


### 48.7 top

DOT_ZSH defines:

    top='top -o cpu'

This starts macOS `top` ordered by CPU usage.


### 48.8 Firefox

When:

    /Applications/Firefox.app

exists, DOT_ZSH defines:

    fx='open -a Firefox'
    firefox='open -a Firefox'


### 48.9 Thunderbird

When:

    /Applications/Thunderbird.app

exists, DOT_ZSH defines:

    tb='open -a Thunderbird'
    th='open -a Thunderbird'
    thunderbird='open -a Thunderbird'


### 48.10 Google Chrome

When:

    /Applications/Google Chrome.app

exists, DOT_ZSH defines:

    ch='open -a Google Chrome'
    chrome='open -a Google Chrome'


### 48.11 Emacs for macOS

When the following executable exists:

    /Applications/Emacs.app/Contents/MacOS/Emacs

DOT_ZSH defines:

    e='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'
    em='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'

These start Emacs in the terminal.

DOT_ZSH also defines:

    emacs='open -a Emacs'

to launch the GUI application through macOS `open`.

For batch byte compilation it defines:

    emacs-compile='/Applications/Emacs.app/Contents/MacOS/Emacs --batch -Q -f batch-byte-compile'


## 49. Non-macOS aliases

On platforms other than macOS, DOT_ZSH configures aliases around GNU-style
command options.

When `TERM` is not `dumb`:

    ls='ls --color=auto'
    dir='ls --color=auto --format=vertical'
    vdir='ls --color=auto --format=long'

Listing aliases are:

    l='ls -ltra'
    d='ls -ltr'
    dir='ls -l'
    la='ls -la'
    a='ls -a'
    lt='ls -t'
    lr='ls -tr'
    ll='ls -lZtra'
    dl='ls -lZtr'

Disk-usage aliases are:

    duh='du -h'
    dum='du --max-depth=1'
    dua='du --apparent-size --max-depth=1'
    duhm='du -h --max-depth=1'
    duha='du -h --apparent-size --max-depth=1'

Emacs aliases are:

    e='emacs -nw'
    em='emacs -nw'

and:

    emacs-compile='emacs --batch -Q -f batch-byte-compile'


## 50. apps.zsh

Role:

    /opt application PATH discovery

This plugin is active for non-root users.

When `/opt` exists, DOT_ZSH examines directories under `/opt/*`.

For each application directory, it checks:

    /opt/<name>/bin

and prepends that directory to PATH when it exists.

It also checks:

    /opt/<name>/current/bin

and prepends that directory when it exists.

Application directories containing spaces are skipped.

Missing directories are ignored.

Source:

    dot_zsh/plugins/apps.zsh


## 51. extract.zsh

Role:

    archive extraction helper

DOT_ZSH provides the function:

    extract

Usage:

    extract <filename>

The command selected depends on the file type.


### Supported formats

    *.tar.gz
    *.tgz
        tar xzf

    *.tar.xz
        tar Jxf

    *.zip
        unzip

    *.lzh
        lha e

    *.tar.bz2
    *.tbz
        tar xjf

    *.tar.Z
        tar xzf

    *.gz
        gzip -d

    *.bz2
        bzip2 -d

    *.Z
        uncompress

    *.tar
        tar xf

    *.arj
        unarj

    *.7z
        7z x

    *.rar
        unrar x

    *.xz
        xz -d


### Error behavior

When no argument is given, or the argument does not name an existing file,
`extract` prints:

    Usage: extract <filename>

and returns status 1.

For an unsupported file type it prints:

    extract: Unsupported file type: ...

and returns status 2.


## 52. Archive suffix aliases

DOT_ZSH maps the following zsh suffix aliases to `extract`:

    gz
    tgz
    zip
    lzh
    bz2
    tbz
    Z
    tar
    arj
    xz
    7z
    rar

A matching file placed in command position can therefore use `extract` as its
handler.

A `.tar.gz` file, for example, reaches `extract` through the final `gz` suffix,
and the function then recognizes the complete `.tar.gz` name.

Source:

    dot_zsh/plugins/extract.zsh


## 53. java.zsh

Role:

    Java environment detection and selection

This plugin applies its main configuration only for non-root users.

It examines the following Java installation candidates in order:

    /usr/java/default

    /Library/Java/JavaVirtualMachines/jdk-8.jdk/Contents/Home
    /Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home
    /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
    /Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home

    /usr/lib/jvm/java-8-openjdk-i386
    /usr/lib/jvm/java-8-openjdk-amd64
    /usr/lib/jvm/java-8-openjdk

    /usr/lib/jvm/java-11-openjdk-i386
    /usr/lib/jvm/java-11-openjdk-amd64
    /usr/lib/jvm/java-11-openjdk

    /usr/lib/jvm/java-17-openjdk-i386
    /usr/lib/jvm/java-17-openjdk-amd64
    /usr/lib/jvm/java-17-openjdk

    /usr/lib/jvm/java-21-openjdk-i386
    /usr/lib/jvm/java-21-openjdk-amd64
    /usr/lib/jvm/java-21-openjdk

    /opt/java/jre
    /opt/java/jre/current
    /opt/java/jdk
    /opt/java/jdk/current

When:

    <candidate>/bin

exists, DOT_ZSH sets:

    JAVA_HOME=<candidate>

    PATH=$JAVA_HOME/bin:$PATH

    CLASSPATH=.:$JAVA_HOME/lib/tools.jar

The scan does not stop after the first matching candidate.

When multiple candidates exist, the later matching candidate therefore becomes
the final `JAVA_HOME`.

The `bin` directories of matching installations are prepended to PATH as each
candidate is processed.

For non-root users DOT_ZSH also exports, independently of whether a Java
candidate matched:

    _JAVA_OPTIONS=-Dawt.useSystemAAFontSettings=lcd

Source:

    dot_zsh/plugins/java.zsh


## 54. ldlib.zsh

Role:

    library path environment

DOT_ZSH sets:

    LD_LIBRARY_PATH=/usr/local/lib:/usr/lib
    LD_FLAGS=/usr/local/lib:/usr/lib

These values replace the values present at the time this plugin is sourced;
they are not appended to an existing `LD_LIBRARY_PATH`.

A later `~/.zshrc_local` can override them when necessary.

Source:

    dot_zsh/plugins/ldlib.zsh


## 55. mysql.zsh

Role:

    MySQL client prompt

DOT_ZSH exports:

    MYSQL_PS1='\R:\m:\s \u@\h [\d] > '

When the MySQL client honors this environment variable, its prompt contains
time, user, host, and database information.

Source:

    dot_zsh/plugins/mysql.zsh


## 56. pager.zsh

Role:

    editor and pager defaults

DOT_ZSH exports:

    EDITOR=vim

Vim is therefore selected as the default editor for programs that honor
`EDITOR`.

DOT_ZSH also exports:

    LESS=-qR

and:

    GIT_PAGER="less -cm"

Git therefore uses `less -cm` as its configured pager.

Source:

    dot_zsh/plugins/pager.zsh


## 57. pip.zsh

Role:

    pip completion

DOT_ZSH provides `_pip_completion`, which uses pip's own completion protocol.

The registration method depends on the zsh version.


### zsh 5.0 and later

DOT_ZSH uses:

    compdef _pip_completion pip


### zsh earlier than 5.0

DOT_ZSH uses the historical compatibility path:

    compctl -K _pip_completion pip

This preserves pip completion on the older zsh versions supported by DOT_ZSH.

Source:

    dot_zsh/plugins/pip.zsh


## 58. prompt.zsh

Role:

    primary prompt

When `TERM` is not `dumb`, DOT_ZSH defines its own `PROMPT`.

The left prompt conceptually contains:

    current time
    hostname
    current directory
    command-status color
    root/non-root marker

Its general shape is:

    time hostname:directory$

or, for root:

    time hostname:directory#


### 58.1 Time

The prompt uses:

    %*


### 58.2 Hostname

The prompt uses:

    %m


### 58.3 Current directory

The prompt uses:

    %~

This permits zsh home-directory and named-directory notation in the displayed
path.


### 58.4 Exit-status color

When the previous command succeeded, the prompt marker is green.

When the previous command failed, the prompt marker is red.


### 58.5 Root marker

A privileged shell displays:

    #

A non-root shell displays:

    $


### 58.6 TERM=dumb

When `TERM=dumb`, this plugin does not replace `PROMPT`.

Source:

    dot_zsh/plugins/prompt.zsh


## 59. proxy.zsh

Role:

    proxy configuration template

This plugin does not enable a proxy in its default state.

The example definitions are all commented out:

    PROXY
    http_proxy
    https_proxy
    ftp_proxy
    HTTP_PROXY
    HTTPS_PROXY
    FTP_PROXY
    no_proxy

The presence of this file in the plugin directory therefore does not by itself
set proxy environment variables.

The file is a template for environments where the user needs to supply concrete
proxy values.

Repository policy prohibits storing private hosts, credentials, or real private
account information in this file.

Source:

    dot_zsh/plugins/proxy.zsh
    doc/POLICY.md


## 60. python.zsh

Role:

    Python and Flask environment defaults

DOT_ZSH always exports:

    PYTHONDONTWRITEBYTECODE=1

Python therefore suppresses its normal writing of `.pyc` bytecode files when it
honors this environment variable.

DOT_ZSH also exports:

    FLASK_ENV=development

The variable is exported to the shell environment and can affect Flask or
related tooling that reads it.

Source:

    dot_zsh/plugins/python.zsh


## 61. ruby.zsh

Role:

    Ruby environment

DOT_ZSH exports:

    RUBYOPT=rubygems

Ruby processes therefore receive `rubygems` through the default `RUBYOPT`
environment variable.

DOT_ZSH also defines:

    be='bundle exec'

Examples include:

    be rake
    be ruby script.rb

which invoke the corresponding command through:

    bundle exec ...

Source:

    dot_zsh/plugins/ruby.zsh


## 62. runcpp.zsh

Role:

    C and C++ compile-and-run helper

DOT_ZSH provides:

    runcpp

Usage:

    runcpp <source_file> [args...]

For a source file named:

    foo.cpp

the output executable is:

    foo.out

The compile command is:

    g++ -std=c++17 "$src" -o "$exe"

After a successful compilation DOT_ZSH runs:

    ./"$exe" "$@"

Arguments following the source file are passed to the compiled program.

If compilation fails, DOT_ZSH prints:

    Compilation failed.

returns status 2, and does not run the program.


## 63. C and C++ suffix aliases

DOT_ZSH defines suffix aliases for:

    c
    cpp

with the handler:

    runcpp

A `.c` or `.cpp` file in command position can therefore invoke `runcpp`.

An important detail is that even a `.c` file is compiled by the implementation
with:

    g++ -std=c++17

The C suffix alias therefore uses the C++ compiler path as implemented.

Source:

    dot_zsh/plugins/runcpp.zsh


## 64. scripts.zsh

Role:

    user script directories

This plugin applies its configuration only for non-root users.


### 64.1 SCRIPTS

DOT_ZSH exports:

    SCRIPTS=$HOME/scripts

When the directory exists, it is prepended to PATH.


### 64.2 PRIVATE

DOT_ZSH exports:

    PRIVATE=$HOME/private/scripts

When the directory exists, it is prepended to PATH.


### 64.3 Local user binaries

When they exist, DOT_ZSH prepends:

    $HOME/.local/bin
    $HOME/bin

to PATH.

Source:

    dot_zsh/plugins/scripts.zsh


## 65. settmp.zsh

Role:

    temporary directory

This plugin chooses a temporary directory only when `TMP` is unset.

The first candidate is:

    $HOME/.tmp

If that directory does not exist, DOT_ZSH uses:

    /tmp

The selected path is exported as:

    TMP
    TMPDIR
    TEMPDIR

If `TMP` is already set when this plugin loads, the plugin does not reset these
variables.

Source:

    dot_zsh/plugins/settmp.zsh


## 66. sqlite3.zsh

Role:

    SQLite environment and helper alias

DOT_ZSH sets:

    SQLITE_TMPDIR="${TMP:-/tmp}"

Under the normal plugin load order this typically uses `TMP` established earlier
by `settmp.zsh`.

DOT_ZSH also defines:

    sqlite-csv='sqlite3 -header -csv -nullvalue "NULL"'

This provides an SQLite invocation that:

- includes column headers
- uses CSV output
- displays SQL NULL values as the string `NULL`

Source:

    dot_zsh/plugins/sqlite3.zsh


## 67. title.zsh

Role:

    GNU Screen and tmux window title

This plugin becomes active when `TERM` matches:

    screen*
    tmux*

At startup it sets the window title to:

    zsh


### 67.1 Directory changes

When the directory changes, the title or hard-status text is updated to reflect
the current directory.


### 67.2 Command execution

Before command execution, the plugin uses `preexec` to update the title
according to the command being run.

For an ordinary command, the leading command name is used.

Commands such as:

    vim file
    git status
    ssh host

therefore result in a title based on the corresponding first command name.


### 67.3 Special commands

The plugin handles several command forms specially:

    fg
    %job
    cd
    ls
    gls
    clear
    screen
    pwd

Commands such as `ls`, `gls`, and `clear` return the title to `zsh`.

Directory changes update the directory-oriented title behavior.

Source:

    dot_zsh/plugins/title.zsh


## 68. vcs_info.zsh

Role:

    VCS information in the right prompt

DOT_ZSH uses the standard zsh `vcs_info` facility.

The enabled VCS backends are:

    git
    svn
    hg


### 68.1 Standard format

The basic format is:

    (<vcs>)-[<branch>]

For example:

    (git)-[master]


### 68.2 Action state

When an action such as a rebase or merge is active, the configured action
format is:

    (<vcs>)-[<branch>|<action>]


### 68.3 SVN

The SVN branch format also includes the revision.


### 68.4 Git status on zsh 4.3.10 and later

On zsh 4.3.10 and later, DOT_ZSH enables Git working-tree change checks.

A staged change is represented by:

    +

An unstaged change is represented by:

    -

The corresponding markers can appear after the branch information.


### 68.5 precmd update

VCS information is refreshed through a `precmd` hook.

The VCS state of the current directory is therefore recalculated before the
prompt is displayed.


### 68.6 Right prompt

When VCS information exists, the right prompt displays that information.

When no VCS information exists, the right prompt displays:

    [username]


### 68.7 Transient right prompt

DOT_ZSH enables:

    TRANSIENT_RPROMPT

The right prompt therefore uses zsh transient-right-prompt behavior.

Source:

    dot_zsh/plugins/vcs_info.zsh


## 69. Final prompt composition

The standard DOT_ZSH prompt is composed by two plugins.

The left side comes from:

    prompt.zsh

The right side comes from:

    vcs_info.zsh

The left side contains:

- time
- hostname
- current directory
- previous-command success or failure color
- root or non-root marker

The right side contains:

- Git, SVN, or Mercurial information

or, outside a recognized VCS:

- the username

Source:

    dot_zsh/plugins/prompt.zsh
    dot_zsh/plugins/vcs_info.zsh


## 70. Automatic GNU Screen startup

GNU Screen automatic startup is enabled only when the following file exists:

    $HOME/.run_screen_on_startup

When that marker exists, `load.zsh` sources:

    lib/screen.zsh

GNU Screen automatic startup is therefore opt-in behavior.

When the marker file is absent, `screen.zsh` is not sourced.

Source:

    dot_zsh/lib/load.zsh
    dot_zsh/lib/screen.zsh


## 71. screen.zsh conditions

`screen.zsh` does not perform its automatic GNU Screen startup logic when
`TERM` is:

    linux
    xterm-256color

For other terminal types it can execute:

    screen -U -D -RR

when its conditions are met.

The implementation first examines the system process list.

When no `screen` process is found and the `screen` command is available, it
executes GNU Screen.

The plugin also has a terminal-type branch for:

    *xterm*
    rxvt
    dtterm
    kterm
    Eterm

and executes:

    screen -U -D -RR

when `screen` is available.

Because `exec` is used, a matching startup path replaces the current zsh process
with GNU Screen.

Source:

    dot_zsh/lib/screen.zsh


## 72. Root and non-root differences

Not every DOT_ZSH plugin is disabled for root.

Some plugins that operate on user-specific tool or application paths do skip
their main behavior for root.


### Main user/tool path processing skipped for root

The principal processing in these plugins is skipped for root:

    apps.zsh
    java.zsh
    scripts.zsh


### base.zsh

Base shell options, the base PATH, locale, and other core settings are still
applied for root.


### alias.zsh

Aliases are also loaded for root.

On macOS, `alias.zsh` contains separate root and non-root branches.

Source:

    dot_zsh/lib/base.zsh
    dot_zsh/plugins/apps.zsh
    dot_zsh/plugins/java.zsh
    dot_zsh/plugins/scripts.zsh
    dot_zsh/plugins/alias.zsh


## 73. Platform-specific behavior

DOT_ZSH provides common core behavior across GNU/Linux, UNIX-compatible
systems, and macOS, while retaining some platform-specific branches for paths
and aliases.


### macOS

Major differences include:

- a macOS-specific base PATH
- BSD `ls` color through `-G`
- use of `g`-prefixed GNU coreutils when available
- replacement of `rm` with `trash` when available for a non-root user
- a Finder launcher
- conditional Firefox, Thunderbird, and Chrome launchers
- conditional Emacs.app aliases


### Other platforms

GNU-style command options are used.

Examples include:

    ls --color=auto
    du --max-depth=1
    du --apparent-size


## 74. zsh version-specific behavior

The DOT_ZSH support baseline is zsh 4.2 and later.

Features that require newer zsh releases use compatibility branches.


### zsh 4.2 and later

This is the DOT_ZSH baseline.


### zsh 4.3.10 and later

`vcs_info.zsh` enables Git working-tree change checks.

Additional markers become available:

    staged: +
    unstaged: -


### zsh 5.0 and later

`pip.zsh` uses the modern `compdef` registration path.


### zsh earlier than 5.0

pip completion uses the `compctl` compatibility path.

Source:

    dot_zsh/plugins/vcs_info.zsh
    dot_zsh/plugins/pip.zsh


## 75. User-local customization

After the repository-wide DOT_ZSH tree has been sourced, DOT_ZSH sources:

    $HOME/.zshrc_local

when that file exists.

The installer does not overwrite this file.

Uninstallation does not remove it.

Host-specific configuration, private settings, credentials, machine-local
paths, and overrides of DOT_ZSH defaults belong here.

For example, it can contain overrides such as:

    export JAVA_HOME=...
    export EDITOR=...
    unalias rm
    alias rm='...'
    export http_proxy=...

Source:

    dot_zshrc
    README.md
    doc/POLICY.md


## 76. User-level configuration tree

A user can use a complete user-level configuration tree instead of the
system-wide configuration tree.

A typical tree is:

    ~/.zsh/
      lib/
      plugins/

The user-level plugin directory and the system-wide plugin directory are not
merged.

Even when the goal is only to add one custom plugin, a selected user-level tree
must be a complete tree containing `lib/load.zsh`.

The intended way to create such a complete copy is, for example:

    install_dotzsh.sh ~/.zsh --no-sudo

after which additional plugins can be placed in that tree's `plugins/`
directory.

Source:

    README.md
    dot_zshrc


## 77. Adding plugins

DOT_ZSH does not use a plugin manager.

A plugin is added by placing a `.zsh` file under:

    $ZSH_ROOT/plugins/

Because `load.zsh` globs the directory, there is no central plugin list to edit
when another plugin is added.

A new plugin should cover one topic and use a filename that identifies that
topic.

Examples include:

    python.zsh
    ruby.zsh
    java.zsh
    mysql.zsh

Because every plugin is sourced again on shell startup, repository policy
requires startup files to remain small, silent, and free of avoidable external
processes.

Source:

    dot_zsh/lib/load.zsh
    doc/POLICY.md


## 78. Byte compilation

The installer uses `zcompile` on the configuration tree.

This allows zsh to use compiled bytecode and reduce source parsing work during
startup.

The startup tree includes:

    dot_zsh/lib/
    dot_zsh/plugins/

The installer also installs `dot_zshrc` as `~/.zshrc` and creates its compiled
form.

Byte compilation reduces parsing cost. It does not make external commands or
other runtime operations inside plugins execute faster.

Source:

    README.md
    install_dotzsh.sh
    doc/POLICY.md


## 79. Environment variable reference

The principal environment variables directly or conditionally configured by
DOT_ZSH are listed below.

Core:

    PATH
    LANG
    HISTFILE
    HISTSIZE
    SAVEHIST
    G_FILENAME_ENCODING
    TIME_STYLE

R:

    R_HOME

Java:

    JAVA_HOME
    CLASSPATH
    _JAVA_OPTIONS

Libraries:

    LD_LIBRARY_PATH
    LD_FLAGS

MySQL:

    MYSQL_PS1

Pager and editor:

    EDITOR
    LESS
    GIT_PAGER

Python:

    PYTHONDONTWRITEBYTECODE
    FLASK_ENV

Ruby:

    RUBYOPT

User script locations:

    SCRIPTS
    PRIVATE

Temporary directory:

    TMP
    TMPDIR
    TEMPDIR

SQLite:

    SQLITE_TMPDIR

Proxy template:

    PROXY
    http_proxy
    https_proxy
    ftp_proxy
    HTTP_PROXY
    HTTPS_PROXY
    FTP_PROXY
    no_proxy

The proxy variables are commented out in the default configuration and are not
automatically set.


## 80. User commands and functions provided by DOT_ZSH

The principal user-facing functions that remain available after startup are:

    extract
    runcpp

Functions also remain for completion or hook integration.

Examples include:

    _pip_completion
    _update_vcs_info_msg

In environments where terminal-title integration is active, zsh hook functions
such as:

    chpwd
    preexec

are also defined.

Helper functions used only during plugin setup are removed with `unset -f`
after their setup work is complete.

Source:

    dot_zsh/plugins/*.zsh
    doc/POLICY.md


## 81. Suffix alias reference

Archive extraction:

    gz   -> extract
    tgz  -> extract
    zip  -> extract
    lzh  -> extract
    bz2  -> extract
    tbz  -> extract
    Z    -> extract
    tar  -> extract
    arj  -> extract
    xz   -> extract
    7z   -> extract
    rar  -> extract

Compile and run:

    c    -> runcpp
    cpp  -> runcpp


## 82. Important automatic command-behavior changes

Several DOT_ZSH aliases materially change the behavior of commands users may
already know.


### rm

Common configuration:

    rm='rm -i'

macOS with GNU coreutils:

    rm='grm -i'

Non-root macOS with the `trash` command:

    rm='trash'

The final behavior therefore depends on the environment.


### cp

Common configuration:

    cp='cp -avi'

macOS with GNU coreutils:

    cp='gcp -avi'


### mv

Common configuration:

    mv='mv -vi'

macOS with GNU coreutils:

    mv='gmv -vi'


### crontab

DOT_ZSH defines:

    crontab='crontab -i'


### sudo

DOT_ZSH defines:

    sudo='sudo '

The trailing space allows alias expansion after `sudo`.


## 83. Important automatic environment changes

DOT_ZSH changes several environment settings at shell startup even when the
user does not explicitly invoke a DOT_ZSH helper command.


### Python

DOT_ZSH exports:

    PYTHONDONTWRITEBYTECODE=1
    FLASK_ENV=development


### Ruby

DOT_ZSH exports:

    RUBYOPT=rubygems


### Editor

DOT_ZSH exports:

    EDITOR=vim


### Pager

DOT_ZSH exports:

    LESS=-qR
    GIT_PAGER="less -cm"


### Dynamic libraries

DOT_ZSH sets:

    LD_LIBRARY_PATH=/usr/local/lib:/usr/lib


### Temporary directory

When `TMP` is unset, DOT_ZSH uses:

    $HOME/.tmp

or:

    /tmp


### Java

For non-root users, DOT_ZSH scans known JDK and JRE paths and can modify
`JAVA_HOME`, PATH, and `CLASSPATH` according to the installations that exist.


## 84. Features not enabled by default

The presence of a plugin file does not necessarily mean that its feature is
fully enabled automatically.


### Proxy

The settings in `proxy.zsh` are commented out and therefore disabled by
default.


### GNU Screen automatic startup

Automatic startup requires the marker:

    $HOME/.run_screen_on_startup


### Predictive input

`predict-on` and `predict-off` are made available as ZLE widgets, but
predictive input is not automatically switched on.


### Optional paths and applications

Configuration for paths or applications that do not exist is skipped where the
corresponding plugin performs an existence check.

Examples include:

    /opt/*
    Firefox.app
    Thunderbird.app
    Google Chrome.app
    Emacs.app
    Java installations
    /usr/lib/R


## 85. Load-order-dependent behavior

Plugins are separated by topic, but the final environment is the result of their
load order.

For example:

    settmp.zsh

can establish `TMP`, after which:

    sqlite3.zsh

uses the value to set:

    SQLITE_TMPDIR

Aliases behave similarly: when the same alias is redefined later, the later
definition is the final definition.

The macOS `rm` alias is a representative example in which the effective path
can progress according to available tools:

    rm -i
      ->
    grm -i
      ->
    trash

The final user customization file:

    ~/.zshrc_local

is applied after all of those repository settings.


## 86. External command dependencies

DOT_ZSH does not include a plugin manager or vendored third-party packages.

Some features become useful only when their corresponding external commands are
installed.

Examples include the following.

Archive tools:

    tar
    unzip
    lha
    gzip
    bzip2
    uncompress
    unarj
    7z
    unrar
    xz

C and C++:

    g++

GNU Screen:

    screen

macOS GNU tools:

    gls
    gdu
    gdf
    gsort
    gtouch
    gid
    gdate
    gbasename
    gdirname
    ghead
    gtail
    gcp
    gmv
    grm
    gmkdir
    grmdir
    gcut
    gwc
    gtee
    guniq
    gshuf
    gsplit
    gfind
    gxargs

Other optional tools:

    trash
    pip
    vim
    git
    sqlite3
    mail
    cltmp
    erase_history

DOT_ZSH checks the existence of many paths and commands before configuring
them.

Other aliases are defined without first checking whether the target command
exists, so using those aliases still requires the corresponding external
command to be installed.


## 87. Feature categories

The user-visible DOT_ZSH behavior can be grouped into the following categories.


### Core shell configuration

    lib/base.zsh

This covers shell options, history, completion, PATH, locale, and resource
limits.


### Command shortcuts and behavior overrides

    alias.zsh


### Environment configuration

    R.zsh
    java.zsh
    ldlib.zsh
    mysql.zsh
    pager.zsh
    python.zsh
    ruby.zsh
    scripts.zsh
    settmp.zsh
    sqlite3.zsh


### PATH discovery

    apps.zsh
    scripts.zsh
    java.zsh


### Interactive helper commands

    extract.zsh
    runcpp.zsh


### Completion

    pip.zsh


### User interface

    prompt.zsh
    vcs_info.zsh
    title.zsh


### Optional network configuration

    proxy.zsh


### Optional terminal and session startup

    lib/screen.zsh


## 88. Plugin catalog

Plugin:

    R.zsh

Role:

    R environment

Automatic effect:

    Sets R_HOME when /usr/lib/R exists.


Plugin:

    alias.zsh

Role:

    General command aliases

Automatic effect:

    Defines Git, filesystem, history, Screen, SSH, editor, macOS application,
    and other aliases. It also changes the behavior of existing commands such
    as cp, mv, and rm.


Plugin:

    apps.zsh

Role:

    /opt application discovery

Automatic effect:

    For non-root users, adds /opt/*/bin and /opt/*/current/bin directories to
    PATH when they exist.


Plugin:

    extract.zsh

Role:

    Archive extraction

Automatic effect:

    Provides the extract function and archive suffix aliases.


Plugin:

    java.zsh

Role:

    Java environment

Automatic effect:

    For non-root users, scans known JDK and JRE paths and sets JAVA_HOME, PATH,
    and CLASSPATH. It also sets _JAVA_OPTIONS.


Plugin:

    ldlib.zsh

Role:

    Dynamic library environment

Automatic effect:

    Sets LD_LIBRARY_PATH and LD_FLAGS.


Plugin:

    mysql.zsh

Role:

    MySQL client prompt

Automatic effect:

    Sets MYSQL_PS1.


Plugin:

    pager.zsh

Role:

    Editor and pager defaults

Automatic effect:

    Sets EDITOR, LESS, and GIT_PAGER.


Plugin:

    pip.zsh

Role:

    pip completion

Automatic effect:

    Registers pip completion using the path appropriate for the running zsh
    version.


Plugin:

    prompt.zsh

Role:

    Left prompt

Automatic effect:

    When TERM is not dumb, configures a prompt containing time, host,
    directory, command status, and the privilege marker.


Plugin:

    proxy.zsh

Role:

    Proxy configuration template

Automatic effect:

    None in the default state because all proxy definitions are commented out.


Plugin:

    python.zsh

Role:

    Python and Flask defaults

Automatic effect:

    Sets PYTHONDONTWRITEBYTECODE=1 and FLASK_ENV=development.


Plugin:

    ruby.zsh

Role:

    Ruby environment

Automatic effect:

    Sets RUBYOPT=rubygems and defines be='bundle exec'.


Plugin:

    runcpp.zsh

Role:

    C and C++ compile and run

Automatic effect:

    Provides the runcpp function and .c/.cpp suffix aliases.


Plugin:

    scripts.zsh

Role:

    User script paths

Automatic effect:

    For non-root users, adds script and bin directories below HOME to PATH and
    exports SCRIPTS and PRIVATE.


Plugin:

    settmp.zsh

Role:

    Temporary directory

Automatic effect:

    When TMP is unset, selects ~/.tmp or /tmp and exports TMP, TMPDIR, and
    TEMPDIR.


Plugin:

    sqlite3.zsh

Role:

    SQLite environment

Automatic effect:

    Sets SQLITE_TMPDIR and provides the sqlite-csv alias.


Plugin:

    title.zsh

Role:

    Screen and tmux title integration

Automatic effect:

    In screen or tmux environments, updates the window title according to
    commands and directory changes.


Plugin:

    vcs_info.zsh

Role:

    VCS right prompt

Automatic effect:

    Displays Git, SVN, or Mercurial information in the right prompt and
    displays the username when no VCS information is present.


## 89. Source reference

The principal user-visible behaviors are defined in the following files.

    dot_zshrc
        Resolves ZSH_ROOT and sources ~/.zshrc_local.

    dot_zsh/lib/load.zsh
        Defines the base, plugin, and Screen load order.

    dot_zsh/lib/base.zsh
        Configures shell options, history, completion, PATH, locale, and
        resource limits.

    dot_zsh/lib/screen.zsh
        Provides marker-controlled GNU Screen automatic startup.

    dot_zsh/plugins/R.zsh
        Configures the R environment.

    dot_zsh/plugins/alias.zsh
        Defines command aliases.

    dot_zsh/plugins/apps.zsh
        Adds /opt application paths.

    dot_zsh/plugins/extract.zsh
        Provides the extract function and archive suffix aliases.

    dot_zsh/plugins/java.zsh
        Configures the Java environment.

    dot_zsh/plugins/ldlib.zsh
        Configures the library environment.

    dot_zsh/plugins/mysql.zsh
        Configures the MySQL prompt.

    dot_zsh/plugins/pager.zsh
        Configures editor and pager environment variables.

    dot_zsh/plugins/pip.zsh
        Configures pip completion.

    dot_zsh/plugins/prompt.zsh
        Configures the left prompt.

    dot_zsh/plugins/proxy.zsh
        Provides the proxy configuration template.

    dot_zsh/plugins/python.zsh
        Configures the Python and Flask environment.

    dot_zsh/plugins/ruby.zsh
        Configures the Ruby environment.

    dot_zsh/plugins/runcpp.zsh
        Provides the C and C++ compile-and-run helper.

    dot_zsh/plugins/scripts.zsh
        Configures user script paths.

    dot_zsh/plugins/settmp.zsh
        Configures the temporary directory.

    dot_zsh/plugins/sqlite3.zsh
        Configures the SQLite environment.

    dot_zsh/plugins/title.zsh
        Configures GNU Screen and tmux titles.

    dot_zsh/plugins/vcs_info.zsh
        Configures Git, SVN, and Mercurial information in the right prompt.


## 90. Scope of this document

This document covers:

"what DOT_ZSH adds or changes compared with a plain zsh environment."

It does not attempt to provide a complete general explanation of every zsh
option, nor complete manuals for Git, Vim, GNU Screen, Java, Python, Ruby, or
other external software.

When DOT_ZSH:

- sets an environment variable
- adds an alias
- changes PATH
- adds completion
- changes a prompt
- changes command behavior

for one of those tools, that DOT_ZSH-specific behavior is part of this
reference.

A plugin filename alone is not sufficient for a user to determine its actual
effect. Each plugin is therefore documented in terms of:

- what the plugin is for
- what it performs automatically
- what it exports
- which aliases or functions it provides
- the conditions under which it becomes effective
- platform-specific differences
- zsh version-specific differences

The purpose of this document is to let a user determine:

"what happens to my shell when DOT_ZSH starts"

without having to read every source file individually.
