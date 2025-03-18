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
#  License: LGPLv3 (Details: https://www.gnu.org/licenses/lgpl-3.0.html)
#  Contact: idnanashi@gmail.com
#
#  Version History:
#  v2.0 2025-03-17
#       Standardized documentation format and added system checks.
#  [Further version history truncated for brevity]
#  v1.0 2025-01-17
#       Initial stable release.
#  v0.1 2011-05-20
#       First release.
#
#  Usage:
#  ./install_dotzsh.sh [target_path] [nosudo]
#
#  Notes:
#  - [target_path]: Path to the installation directory (default: /usr/local/etc/zsh).
#  - [nosudo]: If specified, the script runs without sudo.
#  - Ensure that the SCRIPT_HOME environment variable points to the directory
#    containing the dot_zsh files before running the script.
#  - This script is not POSIX compliant and is designed specifically for zsh environments.
#
########################################################################

# Display help message
show_help() {
    cat <<EOF
Usage: $(basename "$0") [target_path] [nosudo]

Options:
  -h, --help    Show this help message and exit.

Description:
  This script installs the dot_zsh configuration files to the specified
  target directory, compiles zsh scripts into .zwc files, sets appropriate
  permissions, and optionally removes existing configurations.
EOF
}

# Function to check required commands
check_commands() {
    for cmd in "$@"; do
        cmd_path=$(command -v "$cmd" 2>/dev/null)
        if [ -z "$cmd_path" ]; then
            echo "Error: Command '$cmd' is not installed. Please install $cmd and try again." >&2
            exit 127
        elif [ ! -x "$cmd_path" ]; then
            echo "Error: Command '$cmd' is not executable. Please check the permissions." >&2
            exit 126
        fi
    done
}

# Check if the user has sudo privileges (password may be required)
check_sudo() {
    if ! sudo -v 2>/dev/null; then
        echo "Error: This script requires sudo privileges. Please run as a user with sudo access." >&2
        exit 1
    fi
}

# Set up the environment and initialize variables
setup_environment() {
    export SCRIPT_HOME=$(dirname "$(realpath "$0" 2>/dev/null || readlink -f "$0")")

    if [ ! -d "$SCRIPT_HOME/dot_zsh/plugins" ]; then
        echo "Error: $SCRIPT_HOME/dot_zsh/plugins directory does not exist." >&2
        exit 1
    fi

    TARGET=${1:-/usr/local/etc/zsh}
    echo "Installation target: $TARGET"

    if [ -n "$2" ]; then
        SUDO=""
    else
        SUDO="sudo"
    fi
    echo "Using sudo: ${SUDO:-no}"

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
    echo "Copy options: $OPTIONS, Owner: $OWNER"
}

# Set file permissions and ownership
set_permission() {
    if [ -n "$2" ]; then
        echo "Setting ownership to current user and group..."
        chown -R "$OWNER" "$TARGET"
    else
        echo "Setting ownership to $OWNER..."
        $SUDO chown -R "$OWNER" "$TARGET"
    fi
}

# Compile zsh scripts into .zwc files
zsh_compile() {
    echo "Compiling zsh scripts..."
    for file in "$SCRIPT_HOME/dot_zsh/lib/"*.zsh; do
        echo "Compiling $file"
        zsh -c "zcompile $file"
    done
    for plugin in "$SCRIPT_HOME/dot_zsh/plugins/"*.zsh; do
        echo "Compiling $plugin"
        zsh -c "zcompile $plugin"
    done
}

# Clean up compiled .zwc files
zwc_cleanup() {
    echo "Cleaning up .zwc files..."
    rm -f "$SCRIPT_HOME/dot_zsh/lib/"*.zwc
    rm -f "$SCRIPT_HOME/dot_zsh/plugins/"*.zwc
}

# Install configuration files to the target directory
install_files() {
    echo "Installing files from $SCRIPT_HOME/dot_zsh/ to $TARGET"

    if [ -d "$TARGET" ]; then
        echo "Removing existing directory: $TARGET"
        $SUDO rm -rf "$TARGET"
    fi

    echo "Creating target directory: $TARGET"
    $SUDO mkdir -p "$TARGET"

    $SUDO cp -Rv "$SCRIPT_HOME/dot_zsh/lib" "$TARGET/"
    $SUDO cp -Rv "$SCRIPT_HOME/dot_zsh/plugins" "$TARGET/"
    $SUDO cp -v "$SCRIPT_HOME/dot_zshrc" "$HOME/.zshrc"
    zsh -c 'zcompile $HOME/.zshrc'
}

# Install dot_zsh configuration
install_dotzsh() {
    echo "Starting installation..."
    setup_environment "$@"
    zsh_compile
    install_files
    zwc_cleanup
    set_permission "$@"
    echo "Installation complete!"
}

# Main function to execute the script
main() {
    # Parse command-line arguments
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                show_help
                exit 0
                ;;
        esac
    done

    check_commands zsh cp mkdir chmod chown rm id dirname
    install_dotzsh "$@"
}

# Execute main function
main "$@"
