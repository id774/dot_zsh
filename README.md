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
10. [Authors](#10-authors)

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
~/dot_zsh/install_dotzsh.sh ~/.zsh nosudo
```
This installs DOT_ZSH to `~/.zsh`, bypassing the need for `sudo`.

After installation, copy `dot_zshrc` to your home directory:
```bash
cp ~/dot_zsh/dot_zshrc ~/.zshrc
```

---

## 5. Default Behavior

DOT_ZSH:
- Optionally launches GNU Screen at startup if the file `$HOME/.run_screen_on_startup` exists.
- Updates the terminal window title in GNU Screen sessions, configured via `plugins/title.zsh`.
- Aliases are primarily set in `plugins/alias.zsh`.
- For environments requiring a proxy, configure `plugins/proxy.zsh`. Proxy settings are commented out by default.

---

## 6. Customization

DOT_ZSH allows user-specific customization by overriding the default configuration.

### User-Level Core Customization:
Create a `.zsh/lib` directory in your home directory to override core files:
```bash
~/.zsh/lib
```
For example, you can modify `load.zsh`, `base.zsh`, or `screen.zsh`.

### User-Level Plugin Customization:
Create a `.zsh/plugins` directory in your home directory for user-specific plugins:
```bash
~/.zsh/plugins
```

Files in these user-level directories take precedence over the system-level files.

---

## 7. Versioning

DOT_ZSH uses the `<year>.<month>` versioning format starting from version `11.12`.
Example: `24.12`

---

## 8. Contribution

Contributions are welcome! Here’s how you can help:
1. Fork the repository.
2. Add or improve a feature, or fix an issue.
3. Submit a pull request with clear documentation and changes.

Please ensure your code is well-structured and documented.

---

## 9. License

This project is licensed under the [GNU Lesser General Public License v3 (LGPLv3)](https://www.gnu.org/licenses/lgpl-3.0.html).
You are free to use, modify, and distribute this project under the terms of the license.

---

## 10. Authors

**774**
- [Website](http://id774.net)
- [GitHub](http://github.com/id774)
