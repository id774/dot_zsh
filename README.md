# DOT_ZSH

A pluggable framework for the Z shell (zsh) that simplifies configuration management, supports shared bytecode, and allows user-level customization.

---

## Contents

1. [Overview](#1-overview)
2. [Directory Structure](#2-directory-structure)
3. [Supported Environments](#3-supported-environments)
4. [Installation](#4-installation)
5. [Default Behavior](#5-default-behavior)
6. [Customization](#6-customization)
7. [Versioning](#7-versioning)
8. [Contribution](#8-contribution)
9. [License](#9-license)

---

## 1. Overview

DOT_ZSH is designed to:
- Utilize `zcompile` for precompiled bytecode to improve zsh startup performance.
- Allow shared system-wide bytecode while enabling individual users to add custom snippets.
- Provide a modular structure for easily adding plugins.

---

## 2. Directory Structure

The main directory structure of DOT_ZSH is as follows:

```
.
├── dot_zsh/
│   ├── lib/
│   │   Contains core files for loading and basic settings.
│   ├── plugins/
│       Holds independent .zsh plugin files for modular functionality.
├── install_dotzsh.sh
│   Installer script to set up DOT_ZSH in the specified directory.
├── dot_zshrc
    A template for the `.zshrc` file to be placed in the user's home directory.
```

---

## 3. Supported Environments

DOT_ZSH is confirmed to work on:
- Red Hat Enterprise Linux 5 or later
- CentOS 5 or later
- Scientific Linux 5 or later
- Debian GNU/Linux 5 or later
- Ubuntu 8.04 LTS or later
- Solaris 10 or later
- macOS 10.5 or later

Supported zsh versions:
- zsh 4.2 and later (including future releases)

It should also work on most GNU/Linux and UNIX-compatible environments.

---

## 4. Installation

Run the `install_dotzsh.sh` script to install DOT_ZSH:

### Default Installation:
```bash
~/dot_zsh/install_dotzsh.sh
```
This installs DOT_ZSH to `/usr/local/etc/zsh`. Root privileges (via `sudo`) are required.

### Custom Installation:
```bash
~/dot_zsh/install_dotzsh.sh ~/.zsh --no-sudo
```
This installs DOT_ZSH to `~/.zsh`, bypassing the need for `sudo`.
The legacy `nosudo` form and the short `-n` option are also supported.

When specifying a custom target, add `ZSH_ROOT` to `~/.zshenv`:
```bash
export ZSH_ROOT="$HOME/.zsh"
```

### How `ZSH_ROOT` Is Resolved:
`~/.zshrc` locates the configuration tree as follows:

1. If `ZSH_ROOT` is already set and `$ZSH_ROOT/lib/load.zsh` exists, that tree is
   used and no search is performed.
2. Otherwise the first of these directories containing `lib/load.zsh` is used,
   and `ZSH_ROOT` is exported to point at it:
   `~/.zsh`, `~/.config/zsh`, `~/.local/share/zsh`, `/usr/local/etc/zsh`,
   `/usr/local/share/zsh`, `/etc/zsh`, `/usr/share/zsh`, `/opt/zsh`.

Because a preset `ZSH_ROOT` skips the search entirely, pointing it at a
system-wide install will bypass a `~/.zsh` tree that would otherwise take
precedence.

After installation, copy `dot_zshrc` to your home directory:
```bash
cp ~/dot_zsh/dot_zshrc ~/.zshrc
```

### Uninstallation:
To remove DOT_ZSH, including the installed configuration files and compiled `.zwc` bytecode, run:

```bash
~/dot_zsh/install_dotzsh.sh --uninstall
```

You can also specify `--no-sudo` as with installation, if needed:

```bash
~/dot_zsh/install_dotzsh.sh --uninstall --no-sudo
```

The `nosudo` and `-n` aliases are also accepted.

For safety, `--uninstall` removes only `/usr/local/etc/zsh`.
Custom installation targets are not removed automatically.

This will remove:
- The default target directory (`/usr/local/etc/zsh`)
- `~/.zshrc` and `~/.zshrc.zwc` in your home directory

`~/.zshrc_local` is not removed.

---

## 5. Default Behavior

DOT_ZSH:
- Optionally launches GNU Screen at startup if the file `$HOME/.run_screen_on_startup` exists.
- Aliases are primarily set in `plugins/alias.zsh`.
- For environments requiring a proxy, configure `plugins/proxy.zsh`. Proxy settings are commented out by default.
- Sources `$HOME/.zshrc_local` at the end of `~/.zshrc` if that file exists. See [Customization](#6-customization).

---

## 6. Customization

### Machine-Local Settings:
If `~/.zshrc_local` exists, it is sourced at the end of `~/.zshrc`. This is the
recommended place for host-specific settings: the installer never overwrites it,
and `--uninstall` leaves it in place.

### User-Level Configuration Tree:
DOT_ZSH loads exactly one configuration tree, selected as described in
[Installation](#4-installation). To maintain your own, place a complete tree in
a directory that precedes the system-wide one in the search order:
```bash
~/.zsh/lib
~/.zsh/plugins
```
You can then modify core files such as `load.zsh`, `base.zsh`, or `screen.zsh`,
and add your own plugins.

Note that a user-level tree **replaces** the system-wide one rather than merging
with it:
- The search matches on `lib/load.zsh`. A directory that contains only
  `plugins/` is skipped, and its plugins are never loaded.
- Once a tree is selected, only that tree's `lib/` and `plugins/` are sourced.
  Plugins present only under `/usr/local/etc/zsh/plugins` will not load.

So to add a plugin while keeping everything else, install a full copy to your
home directory (`install_dotzsh.sh ~/.zsh nosudo`) and add your plugin there,
rather than creating `~/.zsh/plugins` on its own.

---

## 7. Versioning

DOT_ZSH uses the `<year>.<month>` versioning format starting from version `11.12`.
Example: `24.12`

For detailed version history, please refer to the [VERSIONS](doc/VERSIONS) file.

---

## 8. Contribution

We welcome contributions! Here's how you can help:
1. Fork the repository.
2. Add or improve a feature, or fix an issue.
3. Submit a pull request with clear documentation and changes.

Please ensure your code is well-structured and documented.

---

## 9. License

This repository is dual licensed under the [GPL version 3](https://www.gnu.org/licenses/gpl-3.0.html) or the [LGPL version 3](https://www.gnu.org/licenses/lgpl-3.0.html), at your option.
For full details, please refer to the [LICENSE](doc/LICENSE) file.  See also [COPYING](doc/COPYING) and [COPYING.LESSER](doc/COPYING.LESSER) for the complete license texts.

Thank you for using and contributing to this repository!
