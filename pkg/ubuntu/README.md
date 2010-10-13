## Package-oriented install for ubuntu.

Here are somediaspora-installdiaspora-install scripts to install diaspora on Ubuntu. They are designed to
work as a first step towards packaging, but should be usable as is.

### Synopsis

Bootstrap the distribution from git:
    sudo apt-get install git-core
    git clone git://github.com/diaspora/diaspora.git
    cd diaspora/pkg/ubuntu

Install the dependencies (a good time for a coffe break)
    sudo ./diaspora-install-deps

Create and install the diaspora bundle and application:
    ./make-dist.sh bundle
    sudo ./diaspora-bundle-install dist/diaspora-bundle-*.tar.gz

    ./make-dist.sh source
    sudo ./diaspora-install dist/diaspora-0.0*.tar.gz

Initiate and start the server;
    sudo ./diaspora-setup
    sudo su - diaspora
    cd /usr/share/diaspora/master
    ./script/server

### Upgrading

The normal procedure to update is to just
    $ sudo su - diaspora
    $ cd /usr/share/diaspora/master/pkg/ubuntu
    $ ./make-dist.sh bundle
    $ ./make-dist.sh source

And then use diaspore-install and diaspora-install-bundle as above.

It's necessary to always have the correct bundle. The easy way is to just
    $ ./make-dist.sh bundle

    Repo:       http://github.com/diaspora/diaspora.git
    Bundle:     dist/diaspora-bundle-0.0-1010111342_afad554.tar.gz

The command will return the last built bundle (which is cached) if it's
OK to use. If it's not, it will build a new.

### Notes

The application lives in /usr/share/diaspora/master. All writable areas
(log, uploads, tmp) are links to /var/lib/diaspora. The config file lives
in /etc/diaspora. All files in /usr/share are read-only, owned by root.

The bundle lives in /usr/lib/diaspora-bundle, readonly, owned by root.
Application finds it through the patched .bundle/config in root dir.

Once diaspora ins installed ,makedist.sh et. al. are available in
/usr/share/diaspora/master/pkg/ubuntu, so there's no need to checkout
the stuff using git in this case.

The user diaspora is added during install.

Tools used for building package are installed globally. All of diasporas
dependencies lives in the nothing is insalled by user or on system level.

make-dist.sh accepts arguments to get a specified commit and/or use another
repo.

This has been tested on a Ubuntu 32-bit 10.10 , clean server and on 10.04
Lucid desktop, also clean installation.

mongodb is having problems occasionally. Sometimes the dependencies are not
installed, and mongod refuses to start. invoke /usr/bin/mongod -f /etc/mongodb.conf
fo test. The lockfile /var/lib/mongodb/mongod.conf is also a potential
problem. Remove to make it start again.

The diaspora-wsd is just placeholder FTM, it does **not** work.

Please, report any problems!






