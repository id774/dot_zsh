# ruby.zsh
# Last Change: 09-Feb-2013.
# Maintainer:  id774 <idnanashi@gmail.com>

set_ruby_path() {
    while [ $# -gt 0 ]
    do
        if [ -d $1 ]; then
            export PATH=$1/bin:$PATH
        fi
        shift
    done
}

set_ruby_path \
  /opt/ruby/1.8.7 \
  /opt/ruby/1.9.2 \
  /opt/ruby/1.9.3
  /opt/ruby/2.0
