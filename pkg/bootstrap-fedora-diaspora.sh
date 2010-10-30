#!/bin/bash
#
#  Install diaspora, its dependencies and start.
#
#  Usage: bootstrap-fedora-diaspora.sh [external hostname]
#
#  Must run as root
GIT_REPO='git@github.com:leamas/diaspora.git'
DIASPORA_HOSTNAME='mumin.dnsalias.net'

test $UID = "0" || {
    echo "You need to be root to do this, giving up"
    exit 2
}

yum install  -y git bison svn autoconf sqlite-devel gcc-c++ patch \
            readline-devel  zlib-devel libyaml-devel libffi-devel \
            ImageMagick git rubygems libxslt-devel  libxml2-devel \
            openssl-devel mongodb-server wget openssh-clients

getent group diaspora  >/dev/null || groupadd diaspora
getent passwd diaspora  >/dev/null || {
    useradd -g diaspora -s /bin/bash -m diaspora
    echo "Created user diaspora"
}

su - diaspora <<EOF

#set -x
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

[ -d .ssh ] || {
    ssh-keygen -q
    echo "StrictHostKeyChecking no" > .ssh/config
    chmod 600 .ssh/config
}

ruby=\$(which ruby) || ruby=""

if [[ -z "\$ruby" || ("\${ruby:0:4}" == "/usr") ]]; then
    echo '#### Installing ruby (will take forever) ... ####'
    rvm install ruby-1.8.7-p302
    rvm --default ruby-1.8.7

    echo "#### Installing bundler ... ####"
    gem install bundler
fi

echo '### Clone diapora, install bundle. ###'
rm -rf diaspora
git clone $GIT_REPO
cd diaspora
echo "PWD: \$PWD"
echo "pkg: \$(ls pkg)"
echo "source: \$(ls pkg/source)"
source pkg/source/funcs.sh
bundle install

#Configure diaspora

cp config/app_config.yml.example config/app_config.yml
init_appconfig config/app_config.yml "$DIASPORA_HOSTNAME"

# Install DB setup
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

# Run appserver
echo "Starting server"
script/server

EOF


