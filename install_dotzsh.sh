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
#  Source Code: https://github.com/id774/scripts
#  License: LGPLv3 (Details: https://www.gnu.org/licenses/lgpl-3.0.html)
#  Contact: idnanashi@gmail.com
#
#  Version History:
#  v1.1 2025-03-05
#       Added sudo privilege check when --sudo option is specified.
#  v1.0 2025-01-17
#       Initial release. Updated documentation and refactored for readability.
#
#  Usage:
#  ./install_dotzsh.sh [target_path] [nosudo]
#
#  Notes:
#  - [target_path]: Path to the installation directory (default: /usr/local/etc/zsh).
#  - [nosudo]: If specified, the script runs without sudo.
#  - Ensure that the DOT_ZSH_SOURCE environment variable points to the directory
#    containing the dot_zsh files before running the script.
#  - This script is not POSIX compliant and is designed specifically for zsh environments.
#
########################################################################

# Check if zsh is installed
if ! command -v zsh > /dev/null 2>&1; then
    echo "Error: zsh is not installed. Please install zsh before running this script." >&2
    exit 1
fi

# Set the source directory dynamically based on the script's location
export DOT_ZSH_SOURCE=$(dirname "$(realpath "$0" 2>/dev/null || readlink -f "$0")")

# Ensure the source directory exists
if [ ! -d "$DOT_ZSH_SOURCE/dot_zsh/plugins" ]; then
    echo "Error: $DOT_ZSH_SOURCE/dot_zsh/plugins directory does not exist." >&2
    exit 1
fi

# Check if the user has sudo privileges (password may be required)
check_sudo() {
    if ! sudo -v 2>/dev/null; then
        echo "Error: This script requires sudo privileges. Please run as a user with sudo access."
        exit 1
    fi
}

# Set up the environment and initialize variables
setup_environment() {
    # Set the installation target
    test -n "$1" && export TARGET=$1 || export TARGET=/usr/local/etc/zsh
    echo "Installation target: $TARGET"

    # Determine whether to use sudo
    test -n "$2" && SUDO= || SUDO=sudo
    echo "Using sudo: ${SUDO:-no}"

    # Check sudo privileges if sudo is needed
    if [ "$SUDO" = "sudo" ]; then
        check_sudo
    fi

    # Set options and owner based on the operating system
    case $(uname) in
        Darwin)
            OPTIONS=-Rv
            OWNER=root:wheel
            ;;
        *)
            OPTIONS=-Rvd
            OWNER=root:root
            ;;
    esac
    echo "Copy options: $OPTIONS, Owner: $OWNER"
}

# Set file permissions and ownership
set_permission() {
    if [ -n "$2" ]; then
        # If nosudo is specified, set ownership to the current user and group
        echo "Setting ownership to current user and group..."
        chown -R "$(id -un):$(id -gn)" "$TARGET"
    else
        # Use sudo to set ownership to the appropriate system user and group
        echo "Setting ownership to $OWNER..."
        $SUDO chown -R $OWNER "$TARGET"
    fi
}

# Compile zsh scripts into .zwc files
zsh_compile() {
    echo "Compiling zsh scripts..."
    for file in "$DOT_ZSH_SOURCE/dot_zsh/lib/"*.zsh; do
        echo "Compiling $file"
        zsh -c "zcompile $file"
    done
    for plugin in "$DOT_ZSH_SOURCE/dot_zsh/plugins/"*.zsh; do
        echo "Compiling $plugin"
        zsh -c "zcompile $plugin"
    done
}

# Clean up compiled .zwc files
zwc_cleanup() {
    echo "Cleaning up .zwc files..."
    rm -f "$DOT_ZSH_SOURCE/dot_zsh/lib/"*.zwc
    rm -f "$DOT_ZSH_SOURCE/dot_zsh/plugins/"*.zwc
}

# Install dot_zsh configuration
install_dotzsh() {
    echo "Starting installation..."
    setup_environment "$@"

    # Remove existing target directory if it exists
    if [ -d "$TARGET" ]; then
        echo "Removing existing directory: $TARGET"
        $SUDO rm -rf "$TARGET"
    fi

    # Create the target directory
    echo "Creating target directory: $TARGET"
    $SUDO mkdir -p "$TARGET"

    # Compile zsh scripts and copy files
    zsh_compile
    echo "Copying files from $DOT_ZSH_SOURCE/dot_zsh/ to $TARGET"
    $SUDO cp -R "$DOT_ZSH_SOURCE/dot_zsh/lib" "$TARGET/"
    $SUDO cp -R "$DOT_ZSH_SOURCE/dot_zsh/plugins" "$TARGET/"
    $SUDO cp "$DOT_ZSH_SOURCE/dot_zshrc" "$HOME/.zshrc"
    zsh -c 'zcompile $HOME/.zshrc'

    # Clean up temporary .zwc files
    zwc_cleanup

    # Set permissions appropriately
    set_permission "$@"
    echo "Installation complete!"
}

# Execute the installation
install_dotzsh "$@"
