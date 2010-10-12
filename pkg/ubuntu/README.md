## Package-oriented install for ubuntu.

Here are some scripts to install diaspora on Ubuntu. They are designed to
work as a first step towards packaging, but should be usable as is.

### Synopsis

Bootstrap the distribution from git:
    git clone git://github.com/diaspora/diaspora.git
    cd diaspora/pkg/ubuntu

Install the dependencies (a good time for a coffe break)
    ./diaspora-install-deps

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

### Notes

The application lives in /usr/share/diaspora/master. All writable areas
(log, uploads, tmp) are links to /var/lib/diaspora. The config file lives
in /etc/diaspora. All files in /usr/share are read-only, owned by root.

The bundle lives in /usr/lib/diaspora-bundle, readonly,owned by root.
Application finds it through the patched .bundle/config in root dir.

The user diaspora is added during install.

The  'make-dist-source' prints a message about the version of the bundle
it needs. Normally, it doesn't change and it's a fast procedure to generate
and install the source tarball. Generating the bundle takes some time, though.

make-dist.sh accepts arguments to get a specified commit and/or use another
repo.

This has been tested on a Ubuntu 32-bit 10.10 , clean server. Since this
is a very small dist, the dependencies should possibly be complete.

The diaspora-wsd is just placeholder FTM, it does **not** work.

Please, report any problems!






