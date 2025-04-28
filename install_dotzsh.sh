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
#  Version History:
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
#  Usage:
#      ./install_dotzsh.sh [target_path] [nosudo]
#
#  Options:
#      -h, --help    Show this help message and exit.
#
#  Notes:
#  - [target_path]: Path to the installation directory (default: /usr/local/etc/zsh).
#  - [nosudo]: If specified, the script runs without sudo.
#  - Ensure that the SCRIPT_HOME environment variable points to the directory
#    containing the dot_zsh files before running the script.
#  - This script is not POSIX compliant and is designed specifically for zsh environments.
#
########################################################################

# Display script usage information
usage() {
    awk '
        BEGIN { in_usage = 0 }
        /^#  Usage:/ { in_usage = 1; print substr($0, 4); next }
        /^#{10}/ { if (in_usage) exit }
        in_usage && /^#/ { print substr($0, 4) }
    ' "$0"
    exit 0
}

# Function to check required commands
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

# Set up the environment and initialize variables
setup_environment() {
    export SCRIPT_HOME=$(dirname "$(realpath "$0" 2>/dev/null || readlink -f "$0")")

    if [ ! -d "$SCRIPT_HOME/dot_zsh/plugins" ]; then
        echo "[ERROR] $SCRIPT_HOME/dot_zsh/plugins directory does not exist." >&2
        exit 1
    fi

    TARGET=${1:-/usr/local/etc/zsh}
    echo "[INFO] Installation target: $TARGET"

    if [ -n "$2" ]; then
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
    if [ -n "$2" ]; then
        echo "[INFO] Setting ownership to current user and group..."
        chown -R "$OWNER" "$TARGET"
    else
        echo "[INFO] Setting ownership to $OWNER..."
        $SUDO chown -R "$OWNER" "$TARGET"
    fi
}

# Compile zsh scripts into .zwc files
zsh_compile() {
    echo "[INFO] Compiling zsh scripts..."
    for file in "$SCRIPT_HOME/dot_zsh/lib/"*.zsh; do
        echo "[INFO] Compiling: $file"
        zsh -c "zcompile $file"
    done
    for plugin in "$SCRIPT_HOME/dot_zsh/plugins/"*.zsh; do
        echo "[INFO] Compiling: $plugin"
        zsh -c "zcompile $plugin"
    done
}

# Clean up compiled .zwc files
zwc_cleanup() {
    echo "[INFO] Cleaning up .zwc files..."
    rm -f "$SCRIPT_HOME/dot_zsh/lib/"*.zwc
    rm -f "$SCRIPT_HOME/dot_zsh/plugins/"*.zwc
}

# Install configuration files to the target directory
install_files() {
    echo "[INFO] Installing files from $SCRIPT_HOME/dot_zsh/ to $TARGET."

    if [ -d "$TARGET" ]; then
        echo "[INFO] Removing existing directory: $TARGET"
        if ! $SUDO rm -rf "$TARGET"; then
            echo "[ERROR] Failed to remove existing $TARGET." >&2
            exit 1
        fi
    fi

    echo "[INFO] Creating target directory: $TARGET"
    if ! $SUDO mkdir -p "$TARGET"; then
        echo "[ERROR] Failed to create target directory $TARGET." >&2
        exit 1
    fi

    if ! $SUDO cp $OPTIONS "$SCRIPT_HOME/dot_zsh/lib" "$TARGET/"; then
        echo "[ERROR] Failed to copy lib." >&2
        exit 1
    fi

    if ! $SUDO cp $OPTIONS "$SCRIPT_HOME/dot_zsh/plugins" "$TARGET/"; then
        echo "[ERROR] Failed to copy plugins." >&2
        exit 1
    fi

    if ! $SUDO cp $OPTIONS "$SCRIPT_HOME/dot_zshrc" "$HOME/.zshrc"; then
        echo "[ERROR] Failed to copy .zshrc." >&2
        exit 1
    fi

    zsh -c 'zcompile $HOME/.zshrc'
}

# Install dot_zsh configuration
install_dotzsh() {
    echo "[INFO] Starting dot_zsh installation..."
    setup_environment "$@"
    zsh_compile
    install_files
    zwc_cleanup
    set_permission "$@"
    echo "[INFO] Installation completed successfully."
}

# Main function to execute the script
main() {
    case "$1" in
        -h|--help) usage ;;
    esac

    check_commands zsh cp mkdir chmod chown rm id dirname
    install_dotzsh "$@"
}

# Execute main function
main "$@"
