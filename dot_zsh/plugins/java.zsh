# java.zsh
# Last Change: 28-Jan-2025.
# Maintainer:  id774 <idnanashi@gmail.com>

set_java_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1/bin ]; then
            export JAVA_HOME=$1
            export PATH=$JAVA_HOME/bin:$PATH
            export CLASSPATH=.:$JAVA_HOME/lib/tools.jar
        fi
        shift
    done
}

set_java_path \
  /usr/java/default \
  /Library/Java/JavaVirtualMachines/jdk-8.jdk/Contents/Home \
  /Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home \
  /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home \
  /usr/lib/jvm/java-6-openjdk \
  /usr/lib/jvm/java-8-openjdk-amd64 \
  /usr/lib/jvm/java-1.8.0-openjdk \
  /usr/lib/jvm/java-11-openjdk-amd64 \
  /usr/lib/jvm/java-11-openjdk \
  /usr/lib/jvm/java-17-openjdk-amd64 \
  /usr/lib/jvm/java-17-openjdk \
  /opt/java/jre \
  /opt/java/jre/current \
  /opt/java/jdk \
  /opt/java/jdk/current

export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
unset -f set_java_path
