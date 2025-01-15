# java.zsh
# Last Change: 16-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

# Function to set JAVA_HOME dynamically or from predefined candidates
set_java_path() {
    # Dynamically detect Java installation path
    set_java_path_dynamic() {
        if [[ "$OSTYPE" == "darwin"* && -x /usr/libexec/java_home ]]; then
            # Use macOS-specific java_home utility
            /usr/libexec/java_home
        elif [[ -x /usr/bin/java ]]; then
            # Use the real path of java binary to determine JAVA_HOME
            dirname $(dirname $(readlink -f /usr/bin/java))
        fi
    }

    # Predefined candidates for JAVA_HOME
    local candidates=(
        /usr/lib/jvm/java-11-openjdk-amd64
        /usr/lib/jvm/java-6-openjdk
        /usr/java
        /usr/java/default
        /opt/java/jre \
        /opt/java/jre/current \
        /opt/java/jdk \
        /opt/java/jdk/current
    )

    # Backup the original PATH to ensure it remains intact
    local original_path="$PATH"

    # Loop through the candidates and set JAVA_HOME if a valid path is found
    for path in "${candidates[@]}"; do
        if [[ -d "$path" ]]; then
            export JAVA_HOME="$path"
            # Add JAVA_HOME/bin to PATH if not already present
            if [[ ":$PATH:" != *":$JAVA_HOME/bin:"* ]]; then
                export PATH="$JAVA_HOME/bin:$original_path"
            fi
            # Set CLASSPATH
            export CLASSPATH=.:$JAVA_HOME/lib/tools.jar
            return
        fi
    done

    # If no predefined candidate is valid, try dynamic detection
    local dynamic_path
    dynamic_path=$(set_java_path_dynamic)
    if [[ -n "$dynamic_path" ]]; then
        export JAVA_HOME="$dynamic_path"
        # Add JAVA_HOME/bin to PATH if not already present
        if [[ ":$PATH:" != *":$JAVA_HOME/bin:"* ]]; then
            export PATH="$JAVA_HOME/bin:$original_path"
        fi
        # Set CLASSPATH
        export CLASSPATH=.:$JAVA_HOME/lib/tools.jar
    fi
}

# Initialize JAVA_HOME and PATH
set_java_path

# Set global Java options
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
