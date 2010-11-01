#!/bin/bash
#
#  Install diaspora, its dependencies and start.
#
#  Usage: pkg/bootstrap-fedora-diaspora.sh [external hostname]
#
#  Synopsis:
#
#      $ git clone git@github.com:diaspora/diaspora.git
#      $ cd diaspora
#      $ sudo pkg/bootstrap-rffedora-diaspora.sh
#
#  Unless already existing, the diaspora user is created.
#  The directory the scripts is invoked from is copied to
#  diasporas's home dir, populated and configured and finally
#  acts as a base for running diaspora servers.
#
#  Script is designed not to make any changes in invoking
#  caller's environment.
#  user.
#
#  Must run as root

GIT_REPO='git@github.com:leamas/diaspora.git'
DIASPORA_HOSTNAME=${1:-'mumin.dnsalias.net'}

test $UID = "0" || {
    echo "You need to be root to do this, giving up"
    exit 2
}

[[ -d config && -d script ]] || {
    echo Error: "this is not a diaspora base directory"
    exit 3
}
yum install  -y git bison svn sqlite-devel gcc-c++ patch          \
            readline-devel  zlib-devel libyaml-devel libffi-devel \
            ImageMagick rubygems libxslt-devel  libxml2-devel     \
            openssl-devel mongodb-server wget openssh-clients     \
            make autoconf automake

getent group diaspora  >/dev/null || groupadd diaspora
getent passwd diaspora  >/dev/null || {
    useradd -g diaspora -s /bin/bash -m diaspora
    echo "Created user diaspora"
}

home=$( getent passwd diaspora | cut -d: -f6)
[ -e  $home/diaspora ] && {
    echo "Moving existing  $home/diaspora out of the way"
    mv  $home/diaspora  $home/diaspora.$$
}
mkdir $home/diaspora
cp -ar * $home/diaspora
chown -R diaspora  $home/diaspora

su - diaspora << EOF
#set -x

cd diaspora

#Configure diaspora
cp config/app_config.yml.example config/app_config.yml
source source/funcs.sh
init_appconfig config/app_config.yml "$DIASPORA_HOSTNAME"


[ -e "\$HOME/.rvm/scripts/rvm" ] || {
    echo '#### Installing rvm ####'
    wget  http://rvm.beginrescueend.com/releases/rvm-install-head
    bash < rvm-install-head && rm rvm-install-head
    if [[ -s "\$HOME/.rvm/scripts/rvm" ]]; then
        . "\$HOME/.rvm/scripts/rvm"
    else
        echo "Error: rvm installation failed";
        exit 1;
    fi
    touch \$HOME/.bashrc
    grep -q "rvm/scripts/rvm" \$HOME/.bashrc || {
        echo '[[ -s "\$HOME/.rvm/scripts/rvm" ]] &&  \
            source "\$HOME/.rvm/scripts/rvm"' \
               >> \$HOME/.bashrc
    }
}

source \$HOME/.bashrc

ruby=\$(which ruby) || ruby=""

if [[ -z "\$ruby" || ("\${ruby:0:4}" == "/usr") ]]; then
    echo '#### Installing ruby (will take forever) ... ####'
    rvm install ruby-1.8.7-p302
    rvm --default ruby-1.8.7

    echo "#### Installing bundler ... ####"
    gem install bundler
fi

bundle install

echo "Setting up DB..."
if  bundle exec rake db:seed:dev ; then
    cat <<- EOM
	DB ready. Login -> tom and password -> evankorth.
	More details ./diaspora/db/seeds/tom.rb. and ./diaspora/db/seeds/dev.rb.
	EOM
else
    cat <<- EOM
	Database config failed. You might want to remove all db files with
	'rm -rf /var/lib/mongodb/*' and/or reset the config file by
	'cp config/app_config.yml.example config/app_config.yml' before
	making a new try. Also, make sure the mongodb server is running
	e. g., by running 'service mongodb status'.
	EOM
fi

echo "Starting server"
script/server

EOF


