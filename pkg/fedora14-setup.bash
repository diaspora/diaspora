#!/bin/bash
#
#  Install diaspora, its dependencies and start.
#
#  Usage: pkg/bootstrap-fedora-diaspora.sh [external hostname]
#
#  Synopsis, install:
#      $ git clone git@github.com:diaspora/diaspora.git
#      $ cd diaspora
#      $ sudo pkg/bootstrap-fedora-diaspora.sh
#
#  New start:
#      $ sudo su - diaspora
#      $ cd diaspora
#      $ script/server
#
#  Unless already existing, the diaspora user is created.
#  A new diaspora clone is place in ~diaspora.
#  This dir is populated, configured and finally
#  acts as a base for running diaspora servers.
#
#  Script is designed not to make any changes in invoking
#  caller's environment.
#
#  Must run as root

GIT_REPO='http://github.com/leamas/diaspora.git'
DIASPORA_HOSTNAME=${1:-'mumin.dnsalias.net'}

test $UID = "0" || {
    echo "You need to be root to do this, giving up"
    exit 2
}

[[ -d config && -d script ]] || {
    echo Error: "this is not a diaspora base directory"
    exit 3
}

sudo yum groupinstall -y "Development tools"

yum install  -y git bison sqlite-devel  \
            readline-devel  zlib-devel libyaml-devel libffi-devel \
            ImageMagick libxslt-devel  libxml2-devel     \
            openssl-devel mongodb-server wget  \
            ruby-devel ruby-libs ruby-ri ruby-irb ruby-rdoc \
            rubygems compat-readline5 git
sudo gem install bundler

getent group diaspora  >/dev/null || groupadd diaspora
getent passwd diaspora  >/dev/null || {
    useradd -g diaspora -s /bin/bash -m diaspora
    echo "Created user diaspora"
}

service mongod start

su - diaspora << EOF
#set -x #used by test scripts, keep

[ -e  diaspora ] && {
    echo "Moving existing  diaspora out of the way"
    mv  diaspora  diaspora.$$
}

git clone $GIT_REPO

cd diaspora

bundle install --deployment
#bundle exec jasmine init

#Configure diaspora
cp config/app_config.yml.example config/app_config.yml
source pkg/source/funcs.sh
init_appconfig config/app_config.yml "$DIASPORA_HOSTNAME"
mv lib/tasks/jasmine.rake lib/tasks/jasmine.no-rake

echo "Setting up DB..."
if  bundle exec rake db:seed:dev ; then
    cat <<- EOM
	DB ready. Logins -> tom and korth, password -> evankorth.
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
script/server -d
pidfile="~diaspora/diaspora/log/diaspora-wsd.pid"
echo " To stop server: pkill thin; kill $(cat $pidfile)"
echo 'To restart server: sudo su - diaspora -c "diaspora/script/server -d"'

EOF


