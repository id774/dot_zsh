#!/bin/sh

########################################################################
# install_dotzsh.sh: Install dot_zsh Configuration
#
#  Description:
#  This script installs the dot_zsh configuration files to the specified
#  target directory. It compiles zsh scripts into .zwc files, sets the
#  appropriate permissions, and optionally removes existing configurations.
#
#  Author: id774 (More info: http://id774.net)
#  Source Code: https://github.com/id774/dot_zsh
#  License: The GPL version 3, or LGPL version 3 (Dual License).
#  Contact: idnanashi@gmail.com
#
#  Usage:
#      ./install_dotzsh.sh [target_path] [nosudo|--no-sudo|-n]
#      ./install_dotzsh.sh --uninstall [nosudo|--no-sudo|-n]
#
#  Options:
#      -h, --help       Show this help message and exit.
#      -n, --no-sudo    Run without sudo (the legacy "nosudo" form is also supported).
#      -u, --uninstall  Remove installed dot_zsh configuration and .zshrc files.
#
#  Notes:
#  - [target_path]: Path to the installation directory (default: /usr/local/etc/zsh).
#  - [nosudo|--no-sudo|-n]: If specified, the script runs without sudo.
#    It may be given before or after [target_path].
#  - Ensure that the SCRIPT_HOME environment variable points to the directory
#    containing the dot_zsh files before running the script.
#  - This installer uses POSIX sh and requires zsh to compile configuration files.
#  - Keep the uninstall target fixed at /usr/local/etc/zsh to prevent accidental deletion.
#  - Do not remove custom installation targets automatically.
#  - Remove ~/.zshrc and ~/.zshrc.zwc during uninstallation.
#  - Install ~/.zshrc without sudo so that it remains owned by the invoking user.
#
#  Version History:
#  v4.1 2026-08-21
#       Use POSIX path resolution and check uname before platform-specific setup.
#  v4.0 2026-07-30
#       Accept the no-sudo flag before [target_path], which was previously
#       discarded when the flag came first.
#  v3.6 2026-07-28
#       Honor the [nosudo] argument for --uninstall, which was ignored
#       after the option was documented as --uninstall [nosudo].
#       Install ~/.zshrc without sudo so it stays owned by the invoking user.
#       Accept [nosudo] as the sole installation argument.
#       Check required commands before uninstalling.
#       Accept --no-sudo and -n as aliases for nosudo.
#  v3.5 2026-07-21
#       Stop installation and report an error when a critical command fails.
#  v3.4 2026-07-19
#       Guide custom-target users to set ZSH_ROOT before .zshrc loads.
#       Honor preset ZSH_ROOT values in the installed .zshrc.
#  v3.3 2026-07-12
#       Clarify in usage/help that --uninstall always targets the default
#       path and ignores a custom [target_path].
#       Pass paths to zsh -c zcompile as a positional parameter instead of
#       interpolating them into the command string, to avoid word-splitting
#       on paths containing spaces.
#  v3.2 2026-07-11
#       Replace the awk {n,} interval expression in usage() with a portable
#       equivalent, since mawk on some systems matches it incorrectly.
#  v3.1 2025-10-01
#       Remove unused chmod from command dependency check.
#  v3.0 2025-08-01
#       Add --uninstall option to remove installed files including ~/.zshrc and .zwc files.
#  v2.3 2025-06-23
#       Unified usage output to display full script header and support common help/version options.
#  v2.2 2025-04-27
#       Add strict error checking for all critical filesystem operations
#       and unify log output with [INFO] and [ERROR] tags.
#  v2.1 2025-03-22
#       Unify usage information by extracting help text from header comments.
#  v2.0 2025-03-17
#       Standardized documentation format and added system checks.
#  [Further version history truncated for brevity]
#  v1.0 2025-01-17
#       Initial stable release.
#  v0.1 2011-05-20
#       First release.
#
########################################################################

# Display full script header information extracted from the top comment block
usage() {
    awk '
        BEGIN { in_header = 0 }
        /^#+$/ && length($0) >= 10 { if (!in_header) { in_header = 1; next } else exit }
        in_header && /^# ?/ { print substr($0, 3) }
    ' "$0"
    exit 0
}

# Check if required commands are available and executable
check_commands() {
    for cmd in "$@"; do
        cmd_path=$(command -v "$cmd" 2>/dev/null)
        if [ -z "$cmd_path" ]; then
            echo "[ERROR] Command '$cmd' is not installed. Please install $cmd and try again." >&2
            exit 127
        elif [ ! -x "$cmd_path" ]; then
            echo "[ERROR] Command '$cmd' is not executable. Please check the permissions." >&2
            exit 126
        fi
    done
}

# Check if the user has sudo privileges (password may be required)
check_sudo() {
    if ! sudo -v 2>/dev/null; then
        echo "[ERROR] This script requires sudo privileges. Please run as a user with sudo access." >&2
        exit 1
    fi
}

# Return success when the argument disables sudo
is_no_sudo() {
    case "$1" in
        nosudo|--no-sudo|-n)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Set up the environment and initialize variables
setup_environment() {
    SCRIPT_PATH=$0
    case "$SCRIPT_PATH" in
        */*) ;;
        *)
            if [ ! -f "$SCRIPT_PATH" ]; then
                SCRIPT_PATH=$(command -v "$SCRIPT_PATH" 2>/dev/null)
            fi
            ;;
    esac
    SCRIPT_HOME=$(CDPATH= cd -P "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd)
    if [ -z "$SCRIPT_HOME" ]; then
        echo "[ERROR] Failed to resolve the installer directory." >&2
        exit 1
    fi
    export SCRIPT_HOME

    if [ ! -d "$SCRIPT_HOME/dot_zsh/plugins" ]; then
        echo "[ERROR] $SCRIPT_HOME/dot_zsh/plugins directory does not exist." >&2
        exit 1
    fi

    TARGET=${1:-/usr/local/etc/zsh}
    echo "[INFO] Installation target: $TARGET"

    if is_no_sudo "$2"; then
        SUDO=""
    else
        SUDO="sudo"
    fi
    echo "[INFO] Using sudo: ${SUDO:-no}"

    case "$(uname)" in
        Darwin)
            OPTIONS=-Rv
            OWNER=root:wheel
            ;;
        *)
            OPTIONS=-Rvd
            OWNER=root:root
            ;;
    esac

    if [ "$SUDO" = "sudo" ]; then
        check_sudo
    else
        OWNER="$(id -un):$(id -gn)"
    fi
    echo "[INFO] Copy options: $OPTIONS, Owner: $OWNER"
}

# Set file permissions and ownership
set_permission() {
    if is_no_sudo "$2"; then
        echo "[INFO] Setting ownership to current user and group..."
        if ! chown -R "$OWNER" "$TARGET"; then
            echo "[ERROR] Failed to set ownership on $TARGET." >&2
            return 1
        fi
    else
        echo "[INFO] Setting ownership to $OWNER..."
        if ! $SUDO chown -R "$OWNER" "$TARGET"; then
            echo "[ERROR] Failed to set ownership on $TARGET." >&2
            return 1
        fi
    fi
}

# Compile zsh scripts into .zwc files
zsh_compile() {
    echo "[INFO] Compiling zsh scripts..."
    for file in "$SCRIPT_HOME/dot_zsh/lib/"*.zsh; do
        echo "[INFO] Compiling: $file"
        if ! zsh -c 'zcompile "$1"' _ "$file"; then
            echo "[ERROR] Failed to compile $file." >&2
            return 1
        fi
    done
    for plugin in "$SCRIPT_HOME/dot_zsh/plugins/"*.zsh; do
        echo "[INFO] Compiling: $plugin"
        if ! zsh -c 'zcompile "$1"' _ "$plugin"; then
            echo "[ERROR] Failed to compile $plugin." >&2
            return 1
        fi
    done
}

# Clean up compiled .zwc files
zwc_cleanup() {
    echo "[INFO] Cleaning up .zwc files..."
    if ! rm -f "$SCRIPT_HOME/dot_zsh/lib/"*.zwc \
        "$SCRIPT_HOME/dot_zsh/plugins/"*.zwc; then
        echo "[ERROR] Failed to clean up .zwc files." >&2
        return 1
    fi
}

# Install configuration files to the target directory
install_files() {
    echo "[INFO] Installing files from $SCRIPT_HOME/dot_zsh/ to $TARGET."

    if [ -d "$TARGET" ]; then
        echo "[INFO] Removing existing directory: $TARGET"
        if ! $SUDO rm -rf "$TARGET"; then
            echo "[ERROR] Failed to remove existing $TARGET." >&2
            return 1
        fi
    fi

    echo "[INFO] Creating target directory: $TARGET"
    if ! $SUDO mkdir -p "$TARGET"; then
        echo "[ERROR] Failed to create target directory $TARGET." >&2
        return 1
    fi

    if ! $SUDO cp $OPTIONS "$SCRIPT_HOME/dot_zsh/lib" "$TARGET/"; then
        echo "[ERROR] Failed to copy lib." >&2
        return 1
    fi

    if ! $SUDO cp $OPTIONS "$SCRIPT_HOME/dot_zsh/plugins" "$TARGET/"; then
        echo "[ERROR] Failed to copy plugins." >&2
        return 1
    fi

    # ~/.zshrc belongs to the invoking user, so install it without sudo to keep
    # it user-owned. Remove it first: a copy left root-owned by an earlier
    # version is not writable by its owner, but can still be replaced because
    # the home directory itself is.
    if ! rm -f "$HOME/.zshrc" "$HOME/.zshrc.zwc"; then
        echo "[ERROR] Failed to remove existing $HOME/.zshrc." >&2
        return 1
    fi

    if ! cp $OPTIONS "$SCRIPT_HOME/dot_zshrc" "$HOME/.zshrc"; then
        echo "[ERROR] Failed to copy .zshrc." >&2
        return 1
    fi

    if ! zsh -c 'zcompile "$1"' _ "$HOME/.zshrc"; then
        echo "[ERROR] Failed to compile $HOME/.zshrc." >&2
        return 1
    fi
}

# Install dot_zsh configuration
install_dotzsh() {
    echo "[INFO] Starting dot_zsh installation..."
    setup_environment "$@"
    if ! zsh_compile; then
        zwc_cleanup
        return 1
    fi
    if ! install_files; then
        zwc_cleanup
        return 1
    fi
    zwc_cleanup || return 1
    set_permission "$@" || return 1
    if [ -n "$1" ]; then
        echo "[INFO] To use this target, add the following line to ~/.zshenv:"
        echo "[INFO] export ZSH_ROOT=\"$TARGET\""
    fi
    echo "[INFO] Installation completed successfully."
}

# Uninstall dot_zsh configuration
uninstall() {
    check_commands rm id dirname uname
    echo "[INFO] Starting dot_zsh uninstallation..."
    # Pass the no-sudo argument through while keeping the default target path.
    setup_environment "" "$1"

    TARGET="/usr/local/etc/zsh"

    if [ -f "$HOME/.zshrc" ]; then
        echo "[INFO] Removing $HOME/.zshrc"
        if ! rm -f "$HOME/.zshrc"; then
            echo "[ERROR] Failed to remove $HOME/.zshrc." >&2
        fi
    fi

    if [ -f "$HOME/.zshrc.zwc" ]; then
        echo "[INFO] Removing $HOME/.zshrc.zwc"
        if ! rm -f "$HOME/.zshrc.zwc"; then
            echo "[ERROR] Failed to remove $HOME/.zshrc.zwc." >&2
        fi
    fi

    if [ -d "$TARGET" ]; then
        echo "[INFO] Removing target directory: $TARGET"
        if ! $SUDO rm -rf "$TARGET"; then
            echo "[ERROR] Failed to remove directory $TARGET." >&2
            exit 1
        fi
    else
        echo "[INFO] Target directory $TARGET does not exist. Skipping."
    fi

    echo "[INFO] Uninstallation completed successfully."
}

# Perform installation steps
install() {
    check_commands zsh cp mkdir chown rm id dirname uname

    # Sort the arguments so the no-sudo flag may appear on either side of the
    # target path. An absent target stays empty and falls back to the default.
    TARGET_ARG=""
    NO_SUDO_ARG=""
    for arg in "$@"; do
        if is_no_sudo "$arg"; then
            NO_SUDO_ARG="$arg"
        else
            TARGET_ARG="$arg"
        fi
    done

    install_dotzsh "$TARGET_ARG" "$NO_SUDO_ARG"
}

# Main entry point of the script
main() {
    case "$1" in
        -h|--help|-v|--version)
            usage
            ;;
        -u|--uninstall)
            shift
            uninstall "$@"
            ;;
        ""|*)
            install "$@"
            ;;
    esac
}

# Execute main function
main "$@"
