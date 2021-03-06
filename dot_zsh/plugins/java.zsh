# java.zsh
# Last Change: 17-Jun-2013.
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
  /System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Home \
  /System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home \
  /usr/lib/jvm/java-6-openjdk \
  /usr/java \
  /usr/java/default \
  /opt/java/jre \
  /opt/java/jre/current \
  /opt/java/jdk \
  /opt/java/jdk/current

export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
