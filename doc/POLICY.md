# DOT_ZSH Implementation Policy

This document states what the code in this repository is held to. It is
self-contained: everything that applies to the configuration tree and to
`install_dotzsh.sh` is stated here.

Two kinds of file live here, and they are held to different rules because
they cost different things.

- The configuration tree: `dot_zsh/lib`, `dot_zsh/plugins`, and `dot_zshrc`.
  Every line of it is read and run again each time an interactive shell
  starts. The user pays that cost, on every host, at every prompt they open.
- The installer: `install_dotzsh.sh`. It runs once, by hand, and is an
  ordinary POSIX shell script, held to the rules of Section 7.

Where this document says "the tree" it means the first of those.

## 1. About This Document

- The rules apply to what is written from now on. Nothing here is a reason to
  go back and rewrite a file that already works. A file is brought into line
  when it is edited for another reason, and no further.
- Three priorities settle a design question, in this order: **Compatibility**,
  **Safety**, **Efficiency**. This is not a list of equally weighted
  concerns; it is an order. Compatibility outranks Safety, and Safety
  outranks Efficiency. Where two forms both work and nothing above decides
  between them, the cheaper one to run at startup wins, and that is what
  Section 2 is about.
- Compatibility means two things: keeping normal, intended, existing
  behavior working, and staying compatible with the zsh versions this
  repository supports (Section 3). It does not mean preserving whatever the
  code currently does, without qualification, forever.
  - A clear bug, a regression, an unintended side effect, or behavior that is
    simply broken is not kept only because it is already there.
  - Fixing a bug that restores a broken state to a normal one is not a loss
    of compatibility; it is compatibility working as intended.
  - The current implementation is the primary fact about what runs today,
    but it is not by itself proof of what was meant to run. Intended
    behavior is read from the implementation together with the documented
    interface, history, the existing design, and maintenance intent; a
    regression already sitting in the implementation is not adopted as a new
    intended behavior on the strength of the implementation alone.
  - Raising the zsh 4.2 floor, retiring a legacy plugin or setting,
    choosing a repository version, and other large, deliberate design
    changes are decisions for the maintainer. A routine change does not make
    that call on its own.
- Safety sits between Compatibility and Efficiency. A change that saves a
  fork or a line is not taken if it weakens safety, and a rule kept for
  Compatibility is not itself unsafe merely for being old.
- Efficiency, including startup cost, is discussed at length below and
  matters a great deal, but it is the lowest of the three. A faster form
  that breaks normal existing behavior, that lowers portability across a
  supported environment, or that weakens security is not adopted for its
  speed.
- This document is written to be applied literally, including by an AI or
  another party working from it alone, without that literal application
  producing an absurd result. Absolute words -- "always", "never", "must",
  "whatever it costs" -- are reserved for a rule that really admits no
  exception; an ordinary preference is written as a preference, not dressed
  up as an invariant. A rule below should be traceable to Compatibility,
  Safety, or Efficiency; a principle is stated once here rather than
  repeated at the top of every section that relies on it.

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
- The existence of an external command in the tree is not itself a defect.
  The question Section 2.1 asks is whether that command runs on every
  startup for information zsh already has, not whether calling an external
  command is permitted at all: `git`, `dircolors`, and similar tools appear
  in the tree where there genuinely is no zsh-native answer.
- An optimization that costs correctness, compatibility, safety, or
  maintainability is not taken merely to remove a fork. Section 1's
  priorities decide, and Efficiency yields to the other two.
- Interactive startup must never block waiting on something outside the
  shell. This is a correctness requirement, not a speed preference: opening
  a normal interactive `zsh` has to produce a usable prompt immediately, on
  every host, every time. Concretely, nothing in the normal startup path may
  perform network access, `sleep`, read from the terminal, wait on a mount,
  wait on a service, or otherwise make opening a shell wait for outside
  state to finish.
- Work that matters only when a command is first used is deferred, not done
  at startup. `autoload -Uz`, a stub function that replaces itself on first
  call, and an `add-zsh-hook precmd` are the three forms used here.
- Caching a value in a file, so that it is not recomputed at every startup,
  is a valid way to cut startup cost. It is a technique, not a goal to reach
  for on its own. A cheap computation is simply left to run every time; a
  cache earns its place only once recomputing the value is itself the
  measured cost. Where the cache's own invalidation, staleness handling,
  extra state, or added complexity would cost more than the recomputation it
  avoids, recomputing is the right choice -- per Section 1, the Efficiency a
  cache buys does not outrank the Compatibility and Safety a simpler,
  stateless recomputation keeps.
- A change proposed for speed states what it measured:

```zsh
for i in 1 2 3 4 5; do time zsh -i -c exit; done
```

  and, where the answer is not obvious, `zmodload zsh/zprof` at the head of
  `dot_zshrc` with `zprof` at its foot.

- The installer byte-compiles every file in the tree with `zcompile`. That
  saves parsing, not running: a slow file is still slow compiled.

### 2.2 Size

- One topic to a plugin file, named after what it configures. A change that
  clearly belongs to what an existing plugin already configures is added to
  that file. A change that is a topic of its own, not already covered by an
  existing plugin's responsibility, gets a new file instead. Either way, the
  file name identifies the topic it is responsible for, and `lib/load.zsh`
  globs the plugin directory and needs no edit when a file is added.
- A file that no longer configures anything is deleted rather than left to
  load. So is a setting that duplicates a zsh default.
- No framework, no plugin manager, and no vendored third-party code is the
  long-standing direction for this tree: DOT_ZSH stays small and
  self-contained, and what the shell loads is what this repository holds.
  Ordinary maintenance keeps to that direction. Adopting a framework, a
  plugin manager, or vendored code would be a deliberate change to the
  repository's design, for the maintainer to decide explicitly, not
  something a routine change reaches for.
  - This is a different sense of "framework" from the one in the README's
    project description. README calling DOT_ZSH itself "a pluggable
    framework for the Z shell" describes the modular, pluggable
    configuration structure this repository provides. What this rule keeps
    out is an external configuration framework, a third-party shell
    framework, or a similar external abstraction layer added on top of
    DOT_ZSH as a dependency. Describing DOT_ZSH as a framework and not
    depending on an external one are not in tension.

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
- Sourcing the tree twice must be harmless: this is an ordinary correctness
  property of the tree, not a special optimization. `PATH` entries must not
  accumulate, a hook must not be registered twice, and a setup-only function
  or variable must not linger because it assumed it would run only once.

## 3. Zsh, Not POSIX

- The tree is zsh and is written as zsh. `[[ ... ]]`, `(( ... ))`, arrays,
  `local`, glob qualifiers, and parameter expansion flags are all in, and
  reaching for one that removes a fork is the point of Section 2.1, not a
  flourish. There is no portability argument for writing this tree in the
  common subset: `/bin/sh` never reads it.
- The `[ ... ]` style already in the tree is historical. It is left where it
  stands, per Section 1.
- New `PATH` work uses the `path` array with `typeset -U path`, which keeps
  the entries unique and makes a second sourcing a no-op.
- The baseline is zsh 4.2, as the README states. A feature that arrived later
  is guarded with `is-at-least`, or with `(( $+functions[...] ))` and
  `(( $+builtins[...] ))` where the question is really whether the thing
  exists. `plugins/vcs_info.zsh` and `plugins/pip.zsh` show both forms.
- Raising the zsh 4.2 floor is a maintainer decision, not one a change makes
  on its own. DOT_ZSH keeps tracking new zsh releases as they appear: there
  is no fixed target version at which support is meant to stop, and nothing
  here assumes a specific future zsh release number.
- Detect the capability where the question is really about a capability: the
  name of an operating system, a distribution, or a terminal emulator often
  answers a question the tree is not asking, and `is-at-least` or a
  `$+functions`/`$+builtins` check answers the real one instead.
  `$OSTYPE` branches that remain in the tree are for paths and other
  platform-specific facts, not a substitute for capability detection, and
  using one where the path or the OS itself is genuinely what varies is not
  a defect.
- Files in the tree are sourced, not executed. They carry no shebang, no
  execute bit, and no `exit`. `return` ends a file early.
- Nothing in the tree may depend on where the source checkout lives. The tree
  is copied elsewhere at install time, so a file that needs its neighbours
  finds them under `$ZSH_ROOT`.
- `install_dotzsh.sh` is the exception to this section. It runs before the
  tree exists, on whatever shell the host provides, and stays POSIX
  `#!/bin/sh` under the rules of Section 7.1.

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

`install_dotzsh.sh` carries the structured header described in Section 7
instead: a `#` block with `Description`, an identifying block, `Usage`,
`Options`, `Notes`, and `Version History`, from which its `usage()` prints.
It already does, and that stays.

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
- `plugins/settmp.zsh` intentionally prefers `$HOME/.tmp` to `/tmp` when
  `TMP` is unset. `$HOME/.tmp` is a private per-user temporary area when it
  exists. Provisioning that directory is outside what DOT_ZSH does: it
  neither creates `$HOME/.tmp` nor changes its permissions, and simply uses
  it if it is already there.
- When `$HOME/.tmp` does not exist, `/tmp` is the fallback, so the shell
  still has a usable temporary directory either way.
- Preferring a private per-user namespace over the shared, world-writable
  `/tmp` is a security policy, not a performance optimization. Its purpose
  is to avoid ordinary temporary files sharing a namespace with every other
  user on the host when a private directory is available.
- A tmpfs-backed `/tmp`, including the default `/tmp` configuration on
  Debian 13, changes storage and lifetime characteristics but does not make
  the namespace private to one user. Being memory-backed is not the same
  property as being user-private, and it does not change this preference.

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

## 7. The Installer

`install_dotzsh.sh` is an executable script, not a file the tree sources, and
it is held to a different set of rules than Sections 2 through 6.

### 7.1 Shell and Structure

- POSIX `#!/bin/sh`, written in POSIX shell syntax. It runs before the tree
  exists, on whatever `/bin/sh` the host provides, so it does not depend on
  bash-specific features, `local`, arrays, `[[ ... ]]`, or the `function`
  keyword.
- The user-facing header is a `#` comment block carrying `Description`, an
  identifying block (author, source repository, license, and contact),
  `Usage`, `Options`, `Notes`, and `Version History`.
- `usage()` prints that header and stays consistent with it: an option the
  script accepts is documented under `Options`, and an option documented
  under `Options` is one the script accepts.
- `-h` and `--help` are provided, and print the header. `-v` and
  `--version` are provided as well, since the header's `Version History`
  is what a version query needs to show.

### 7.2 Commands and Privilege

- A required external command is checked on the execution path that actually
  needs it, not unconditionally regardless of which path runs.
- An optional or conditional command is checked only on the path where it
  becomes necessary.
- A shell builtin is never listed as an external dependency to check for.
- `sudo` availability and privilege are examined only on the path that
  actually invokes `sudo`.

### 7.3 Logging and Exit Codes

- Informational and error output uses the existing `[INFO]`, `[WARN]`, and
  `[ERROR]` prefixes.
- Exit codes follow the existing convention: 127 for a missing command, 126
  for a command that is not executable, 1 for an ordinary failure, and 0 for
  success.

### 7.4 Destructive Operations

- A destructive operation names its target precisely. `--uninstall` removes
  only the default target, `/usr/local/etc/zsh`, plus `~/.zshrc` and
  `~/.zshrc.zwc` in the invoking user's home directory; a custom
  installation target is never removed automatically, so installing to a
  path the user chose is not silently undone by an uninstall run without
  arguments.

### 7.5 Script Versioning

- `install_dotzsh.sh` keeps its own `major.minor` version history,
  independent of the `doc/VERSIONS` repository version described in
  Section 8.
- The script version moves for a release unit a user of the script would
  actually notice: a change to its CLI behavior, its installation behavior,
  a safety fix, or a significant change to its structure.
- Documentation-only, comment-only, and formatting-only changes do not move
  the script version.
- Several related changes made the same day are one version entry, not
  several.

## 8. Versions and Documents

- The document roles defined in this section are the documentation
  structure of this repository itself: [FEATURES](FEATURES.md) is the
  detailed user-facing behavior reference, this file is the DOT_ZSH
  implementation and maintenance policy, `doc/VERSIONS` is the repository
  release history, and `README.md` is the project overview, installation,
  usage, structure, and versioning summary.
- The repository version is `<year>.<month>`, recorded in
  [`doc/VERSIONS`](VERSIONS) and used for the Git tag. A same-month release
  that corrects an earlier one may add a third `<patch>` level instead, as
  `v25.03.1` does; using one, and which correction warrants it, is for the
  maintainer to decide. The Version History Guidelines at the foot of that
  file govern the entries.
- [FEATURES](FEATURES.md) is the user-facing reference for shell behavior,
  aliases, plugins, environment variables, prompts, and other defaults enabled
  or changed by DOT_ZSH.
- Files in the tree carry no version of their own. `Last Change:` is their
  whole history, and `doc/VERSIONS` carries the rest.
- `install_dotzsh.sh` keeps its own `major.minor` version history, under the
  rules of Section 7.5.
- A document written in Markdown takes `.md` when it is newly created. That is
  why this file is `doc/POLICY.md`.
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
- A thing is named for what it is, not for a part of it. This holds in
  headers, in the documents, and in commit messages.
- A pull request carries one purpose. A coherent change is one commit,
  amended and force-pushed with `--force-with-lease` as review proceeds,
  rather than gaining a further commit for each remark. A conflict with the
  base branch is resolved by rebasing onto it, so that the branch which
  merges reads as the change it was always meant to be.

## 9. Judging a Change

Before a change to the tree is proposed, it answers these:

- Does it add a fork, a file, or a command substitution to every startup, and
  what did it measure?
- Is it silent and does it leave status zero when the path, command, or file
  it names is absent?
- Is it harmless when the tree is sourced twice?
- Does it leave behind a function or a variable the user did not ask for?
- Does it need a zsh newer than 4.2, and is that guarded?
- Does it detect a capability rather than a platform name, where the question
  is genuinely about a capability?
- Does it put a host name, an account, or a credential in the repository?
- Is `Last Change:` updated, and does `doc/VERSIONS` carry the line?
- Does it preserve normal, intended existing behavior, or is a change in that
  behavior a deliberate, stated decision?

## 10. License

This repository is dual licensed under the GPL version 3 or the LGPL version
3, at the user's option. See [LICENSE](LICENSE.md), [COPYING](COPYING), and
[COPYING.LESSER](COPYING.LESSER).

Files in the tree carry no licence header; the repository-wide terms cover
them. `install_dotzsh.sh` repeats the licence line in its header, so that a
script read on its own still states its terms.
