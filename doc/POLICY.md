# DOT_ZSH Implementation Policy

This document states what the code in this repository is held to.

Two kinds of file live here, and they are held to different rules because
they cost different things.

- The configuration tree: `dot_zsh/lib`, `dot_zsh/plugins`, and `dot_zshrc`.
  Every line of it is read and run again each time an interactive shell
  starts. The user pays that cost, on every host, at every prompt they open.
- The installer: `install_dotzsh.sh`. It runs once, by hand, and is an
  ordinary shell script bound by the policy of the companion repository
  [`scripts`](https://github.com/id774/scripts).

Where this document says "the tree" it means the first of those.

## 1. About This Document

- The rules apply to what is written from now on. Nothing here is a reason to
  go back and rewrite a file that already works. A file is brought into line
  when it is edited for another reason, and no further.
- Startup cost is the constraint that settles most questions. Where two forms
  both work, the one that runs fewer commands at startup wins, and the reason
  needs no further argument.
- `scripts/doc/POLICY` governs a maintained toolset, not this repository.
  Section 7 states which of its rules hold here and which deliberately do not.

## 2. The Startup Path

### 2.1 Speed

- A fork is the unit of cost. Every external command run at startup is a
  process created, a binary loaded, and a pipe read, for an answer zsh
  usually already holds.

| Instead of | Write |
| --- | --- |
| `$(uname)` | `$OSTYPE` |
| `$(id -u)` | `$EUID` |
| `command -v foo >/dev/null 2>&1` | `(( $+commands[foo] ))` |
| `$(dirname "$f")`, `$(basename "$f")` | `${f:h}`, `${f:t}` |
| `echo "$d" \| sed 's:/*$::'` | `${d%%/#}` |
| `for d in /opt/*; do [ -d "$d" ] \|\| continue` | `for d in /opt/*(N/)` |
| `$(ls "$d" \| wc -l)` | `files=("$d"/*(N)); (( $#files ))` |

- `${d%%/#}` needs `extended_glob`, which `lib/base.zsh` sets before any
  plugin loads. Ordering within the tree is fixed and may be relied on.
- A question about the shell's own situation is asked of the shell. Whether
  this shell already runs inside GNU Screen is `$STY`, not a pipeline of four
  commands counting processes.
- Nothing at startup may block: no network access, no `sleep`, no read from
  the terminal, no command that waits on a mount or a service.
- Work that matters only when a command is first used is deferred, not done
  at startup. `autoload -Uz`, a stub function that replaces itself on first
  call, and an `add-zsh-hook precmd` are the three forms used here.
- A result that does not change between startups is cached in a file and
  refreshed when the file is missing or stale. Recomputing it at every prompt
  is the defect, whatever it costs once.
- A change proposed for speed states what it measured:

```zsh
for i in 1 2 3 4 5; do time zsh -i -c exit; done
```

  and, where the answer is not obvious, `zmodload zsh/zprof` at the head of
  `dot_zshrc` with `zprof` at its foot.

- The installer byte-compiles every file in the tree with `zcompile`. That
  saves parsing, not running: a slow file is still slow compiled.

### 2.2 Size

- One topic to a plugin file, named after what it configures. The file name is
  the index, so adding a feature means adding a file. `lib/load.zsh` globs the
  directory and needs no edit.
- A file that no longer configures anything is deleted rather than left to
  load. So is a setting that duplicates a zsh default.
- No framework, no plugin manager, and no vendored third-party code. What the
  shell loads is what this repository holds.

### 2.3 Namespace

- A helper that exists only to set something up is defined, called, and
  removed with `unset -f` in the same file. A variable used the same way is
  `unset`, or made `local` to a function.
- What survives the file is what the user is meant to type (`extract`,
  `runcpp`) or what zsh calls later (a hook, a completion function).
- Change options inside a function with `setopt localoptions`, never globally
  for the benefit of one loop.

### 2.4 Silence and Status

- Startup writes nothing to stdout or stderr. An absent path, command, or
  file is a normal state, not a condition to report.
- The first prompt must not report a failed command. `base.zsh` sets
  `print_exit_value`, so the last command a startup file runs decides what the
  user sees: end a file with `if [ -f "$f" ]; then . "$f"; fi`, not with
  `[ -f "$f" ] && . "$f"`.
- `no_unset` is set. A parameter that may be unset is read as `${VAR-}` or
  `${VAR:-default}`, never bare.
- `sh_word_split` is set. Quote every expansion that is not deliberately being
  split, paths holding spaces included.
- Sourcing the tree twice must be harmless. `PATH` entries must not
  accumulate, and a hook must not be registered twice.

## 3. Zsh, Not POSIX

- The tree is zsh and is written as zsh. `[[ ... ]]`, `(( ... ))`, arrays,
  `local`, glob qualifiers, and parameter expansion flags are all in, and
  reaching for one that removes a fork is the point of section 2.1, not a
  flourish. There is no portability argument for writing this tree in the
  common subset: `/bin/sh` never reads it.
- The `[ ... ]` style already in the tree is historical. It is left where it
  stands, per section 1.
- New `PATH` work uses the `path` array with `typeset -U path`, which keeps
  the entries unique and makes a second sourcing a no-op.
- The baseline is zsh 4.2, as the README states. A feature that arrived later
  is guarded with `is-at-least`, or with `(( $+functions[...] ))` and
  `(( $+builtins[...] ))` where the question is really whether the thing
  exists. `plugins/vcs_info.zsh` and `plugins/pip.zsh` show both forms.
- Detect the capability, never the platform. The name of an operating system,
  a distribution, or a terminal emulator answers a question the tree is not
  asking; `$OSTYPE` branches that remain are for paths, not features.
- Files in the tree are sourced, not executed. They carry no shebang, no
  execute bit, and no `exit`. `return` ends a file early.
- Nothing in the tree may depend on where the source checkout lives. The tree
  is copied elsewhere at install time, so a file that needs its neighbours
  finds them under `$ZSH_ROOT`.
- `install_dotzsh.sh` is the exception to this section. It runs before the
  tree exists, on whatever shell the host provides, and stays POSIX
  `#!/bin/sh` under the rules of section 7.1.

## 4. File Header

Every file in the tree opens with exactly three comment lines, then a blank
line, then code:

```zsh
# alias.zsh
# Last Change: 25-May-2026.
# Maintainer:  id774 <idnanashi@gmail.com>
```

- The first line is the file's own name. `dot_zshrc` carries `# .zshrc`, the
  name it is installed under.
- `Last Change:` is `DD-Mon-YYYY.`, with the English month abbreviation and
  the trailing period. It moves when the file's behaviour changes, not for a
  comment, a rewrap, or a whitespace edit.
- Two spaces follow `Maintainer:`, so that the address lines up under the
  date.
- Nothing else. No description, no usage, no requirements, no version history,
  and no licence line. Three lines are three lines to read at every file and
  three lines to keep true; the file name says what the file configures, and
  the repository documents say the rest.

`install_dotzsh.sh` carries the structured header of `scripts/doc/POLICY`
section 1.6.1 instead: the `#` block with `Description`, the identifying
block, `Usage`, `Options`, `Notes`, and `Version History`, from which its
`usage()` prints. It already does, and that stays.

## 5. Comments

- The tree carries almost no comments, and that is the intent, not an
  omission. A `setopt` named after what it does, a plugin named after what it
  configures, and a helper named after what it sets do not need a line
  repeating them.
- Write a comment where the code is not its own reason: why a form that looks
  wrong is right, why an order matters, why a value is the value it is. The
  note in `dot_zshrc` on using `if` rather than `&&` is the example. Without
  it the next reader tidies it back and the first prompt reports a failed
  command again.
- English, imperative, and as short as the reason allows.
- No banner, no divider, no `Function to ...` preamble, and no comment that
  restates the line below it.
- No commented-out code, except where the file is a template of settings to
  enable, as `plugins/proxy.zsh` is.

## 6. What the Tree May Contain

### 6.1 Paths and Environment

- Test before exporting. A directory that is not there is skipped in silence.
- Prepend once. Guard with a glob qualifier or `typeset -U path` so that a
  second sourcing changes nothing.
- A variable is exported at startup only when a program reads it from the
  environment. Anything else belongs in the plugin of the tool that uses it.

### 6.2 Aliases

- An alias is a shorter name for a command. It goes in `plugins/alias.zsh`, or
  in the plugin of the tool it belongs to when that file exists.
- Global aliases (`alias -g`) are avoided. A one-letter global alias expands
  where it was never meant to, which is why they were removed in v26.01.
- Suffix aliases (`alias -s`) are used where a file type has one obvious
  handler, as `extract.zsh` and `runcpp.zsh` do.
- An alias that shadows a real command keeps that command's behaviour for the
  arguments it is given.

### 6.3 Secrets and Private Data

- No key, token, or password, and no real host name, account name, or address
  of a private system. `plugins/proxy.zsh` keeps placeholders, commented out,
  and that is the pattern.
- Nothing here is specific to one machine. Host-specific settings belong in
  `~/.zshrc_local`, which this repository neither ships nor removes.

### 6.4 Root

- A root shell gets `PATH`, options, and nothing that reaches into a user's
  home directory or a user's tool tree. `$EUID` decides.

## 7. What `scripts/doc/POLICY` Lends

### 7.1 What Applies

- `install_dotzsh.sh` is bound by it in full: POSIX `/bin/sh`, the structured
  header, `usage()` printing that header, `check_commands` and `check_sudo`,
  the `[INFO]` / `[WARN]` / `[ERROR]` prefixes, the exit codes 0, 1, 126, and
  127, and the `major.minor` version history in its own header.
- Naming, from its section 1.2.4: name a thing by what it is, not by a part of
  it. This holds in the headers, the documents, and the commit messages.
- Documents, from its sections 1.6.2 to 1.6.4, as section 8 below states.
- Pull requests and branches, from its section 1.8: one purpose to a pull
  request, one commit to a coherent change, amended and force pushed with
  `--force-with-lease` rather than gaining a commit per remark, conflicts
  resolved by rebasing, and a revised branch reading as the change finally
  intended.

### 7.2 What Does Not Apply to the Tree

Listed so that they are not reintroduced here by reflex.

- The structured header block. Section 4 asks for three lines.
- Per-file version numbers and `Version History` entries.
- The POSIX rule, the ban on `local`, and the avoidance of `[[ ... ]]`,
  arrays, and the `function` keyword.
- `-h` and `-v`, usage output, and the exit code table.
- `check_commands`, `check_sudo`, and the `[INFO]` / `[WARN]` / `[ERROR]`
  prefixes. A file sourced at startup reports nothing.
- A test suite. There is no `run_tests.sh` here, and a fix arrives without
  one. What a change to the tree is checked against is section 9.

## 8. Versions and Documents

- The repository version is `<year>.<month>`, recorded in
  [`doc/VERSIONS`](VERSIONS) and used for the Git tag. The Version History
  Guidelines at the foot of that file govern the entries.
- Files in the tree carry no version of their own. `Last Change:` is their
  whole history, and `doc/VERSIONS` carries the rest.
- `install_dotzsh.sh` keeps its own `major.minor` version history, under the
  rules of `scripts/doc/POLICY` sections 1.7.1 and 1.7.2.
- A document written in Markdown takes `.md` when it is newly created. That is
  why this file is `doc/POLICY.md` while the policy of `scripts`, written
  earlier, is `doc/POLICY`.
- `LICENSE`, `COPYING`, and `COPYING.LESSER` keep the extensionless names by
  which they are recognised. `doc/VERSIONS` keeps its name too: a path here is
  a public URL, and no existing document is renamed to add or change an
  extension.
- `.gitattributes` gives `diff=markdown` to `*.md`, so that a diff hunk header
  names the section it falls in. It is a diff aid and nothing more. No file is
  given `linguist-language`, and `doc/VERSIONS`, `doc/COPYING`, and
  `doc/COPYING.LESSER` are excluded.
- Plain text is wrapped near 80 columns where that is practical. A URL, a
  command, a table, or a line that is clearer whole may exceed it.

## 9. Judging a Change

Before a change to the tree is proposed, it answers these:

- Does it add a fork, a file, or a command substitution to every startup, and
  what did it measure?
- Is it silent and does it leave status zero when the path, command, or file
  it names is absent?
- Is it harmless when the tree is sourced twice?
- Does it leave behind a function or a variable the user did not ask for?
- Does it need a zsh newer than 4.2, and is that guarded?
- Does it detect a capability rather than a platform name?
- Does it put a host name, an account, or a credential in the repository?
- Is `Last Change:` updated, and does `doc/VERSIONS` carry the line?

## 10. License

This repository is dual licensed under the GPL version 3 or the LGPL version
3, at the user's option. See [LICENSE](LICENSE), [COPYING](COPYING), and
[COPYING.LESSER](COPYING.LESSER).

Files in the tree carry no licence header; the repository-wide terms cover
them. `install_dotzsh.sh` repeats the licence line in its header, so that a
script read on its own still states its terms.
