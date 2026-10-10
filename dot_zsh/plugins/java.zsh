# java.zsh
# Last Change: 10-Oct-2026.
# Maintainer:  id774 <idnanashi@gmail.com>

set_java_path() {
    while [ $# -gt 0 ]
    do
        if [ -d "$1/bin" ]; then
            export JAVA_HOME="$1"
            export PATH="$JAVA_HOME/bin:$PATH"
        fi
        shift
    done
}

if (( EUID != 0 )); then
    set_java_path \
        /usr/java/default \
        /Library/Java/JavaVirtualMachines/jdk-8.jdk/Contents/Home \
        /Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home \
        /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home \
        /Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home \
        /Library/Java/JavaVirtualMachines/jdk-25.jdk/Contents/Home \
        /usr/lib/jvm/java-8-openjdk-i386 \
        /usr/lib/jvm/java-8-openjdk-amd64 \
        /usr/lib/jvm/java-8-openjdk \
        /usr/lib/jvm/java-11-openjdk-i386 \
        /usr/lib/jvm/java-11-openjdk-amd64 \
        /usr/lib/jvm/java-11-openjdk \
        /usr/lib/jvm/java-17-openjdk-i386 \
        /usr/lib/jvm/java-17-openjdk-amd64 \
        /usr/lib/jvm/java-17-openjdk \
        /usr/lib/jvm/java-21-openjdk-i386 \
        /usr/lib/jvm/java-21-openjdk-amd64 \
        /usr/lib/jvm/java-21-openjdk \
        /usr/lib/jvm/java-25-openjdk-i386 \
        /usr/lib/jvm/java-25-openjdk-amd64 \
        /usr/lib/jvm/java-25-openjdk \
        /opt/java/jre \
        /opt/java/jre/current \
        /opt/java/jdk \
        /opt/java/jdk/current
    export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
fi

unset -f set_java_path
