# java.zsh
# Last Change: 14-Dec-2011.
# Maintainer:  id774 <idnanashi@gmail.com>

set_java_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1 ]; then
            export JAVA_HOME=$1
            export PATH=$JAVA_HOME/bin:$PATH
            export CLASSPATH=.:$JAVA_HOME/lib/tools.jar
        fi
        shift
    done
}

set_java_path \
  /usr/java \
  /usr/java/default \
  /usr/lib/jvm/java-6-openjdk \
  /usr/lib/jvm/java-6-sun \
  /System/Library/Frameworks/JavaVM.framework/Versions/1.5.0/Home \
  /System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home \
  /opt/java/jdk \

export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
