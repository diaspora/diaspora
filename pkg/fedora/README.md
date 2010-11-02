## Diaspora RPM tools

Create RPM packages

An alternative to the capistrano system, providing classic, binary RPM
packages for deployment on Fedora.


#### Synopsis

Prerequisites:

- ruby-1.8, rubygem, git  and rake as described in
  [RPM installation Fedora](http://github.com/diaspora/diaspora/wiki/Rpm-installation-on-fedora)
  or [Installing-on-CentOS-Fedora](http://github.com/diaspora/diaspora/wiki/Installing-on-CentOS-Fedora)

- A personal environment to build RPM:s, also described in
  [RPM installation Fedora](http://github.com/diaspora/diaspora/wiki/Rpm-installation-on-fedora)

Install g++ and gcc:
    % yum install gcc-c++

Bootstrap the distribution from git:
    % sudo apt-get install git-core
    % git clone git://github.com/diaspora/diaspora.git
    % cd diaspora/pkg/ubuntu

Create and install the diaspora bundle and application in
diaspora/pkg/source according to
[source README](http://github.com/diaspora/diaspora/tree/master/pkg/source/)

Setup links from  tarballs to RPM source directory and create spec files:
    % ./prepare-rpm.sh

Build rpms:
    rpmbuild -ba dist/diaspora.spec
    rpmbuild -ba dist/diaspora-bundle.spec

Install (as root):
    rpm -U ~/rmpbuild/rpms/i686/diaspora-bundle-0.0-1.1010042345_4343fade43.fc13.i686
    rpm -U ~/rmpbuild/rpms/noarch/diaspora-0.0-1.1010042345_4343fade43.fc13.noarch

Initiate (as root).
    /usr/share/diaspora/diaspora-setup

Start development server:
    sudo
    su - diaspora
    cd /usr/share/diaspora/master
    ./script/server

See [Using Apache](http://github.com/diaspora/diaspora/wiki/Using-apache) for
apache/passenger setup. After configuration, start with:
    /sbin/service diaspora-wsd start
    /sbin/service httpd restart

prepare-rpm.sh prepare creates links  also for all files listed in SOURCES.
Typically, this is  secondary sources. *make-dist.sh source*

#### Notes

prepare-rpm.sh prepare creates links  also for all files listed in SOURCES.
Typically, this is  secondary sources.

The spec-files in dist/ are patched by *./prepare-rpm.sh to reference
correct versions of diaspora and diaspora-bundle.  Editing spec files should be
done in this directory, changes in dist/ are lost when doing *./prepare-rpm.sh *.

The topmost comment's version is patched to reflect the complete version
of current specfile .  Write the comment in this directory, copy-paste
previous version nr. It will be updated.

This has been confirmed to start up and provide basic functionality both using
the thin webserver and apache passenger, on 32/64 bit systems and in the
mock build environment. Irregular nightly builds are available form time to time
at [ftp://mumin.dnsalias.net/pub/leamas/diaspora/builds](ftp://mumin.dnsalias.net/pub/leamas/diaspora/builds)

#### Implementation

Diaspora files are stored in /usr/share/diaspora, and owned by root. The
bundle, containing some C extensions, is architecture-dependent and lives
in /usr/lib[64]/diaspora. Log files are in /var/log/diaspora. Symlinks in
/usr/share diaspora makes log, bundle  and tmp dir available as expected by
diaspora app.  This is more or less as mandated by LSB and Fedora packaging rules.

    find . -type l -exec ls -l {} \; | awk '{print $9, $10, $11}'
    ./public/uploads -> /var/lib/diaspora/uploads
    ./log -> /var/log/diaspora
    ./tmp -> /var/lib/diaspora/tmp
    ./vendor/bundle -> /usr/lib/diaspora-bundle/master/vendor/bundle


#### Discussion

The 1.8.7 rebuild is a pain. However, in Fedora 14 1.8.7 is the default
ruby version.

For better or worse, this installation differs from the procedure outlined
in the original README.md:

- All configuration is done in /usr/share/diaspore. No global or user
  installed bundles are involved. Easier to maintain, but a mess if there
  should be parallel installations.

- Service is run under it's own uid, not root or an ordinary user account.

- Using the pre-packaged mongod server means that the DB has reasonable
  permissions, not 777.

- Splitting in two packages makes sense IMHO. The bundle is not changed
  that often, but is quite big: ~35M without test packages (the default) or
  ~55M with test packages. The application is just ~3M, and is fast to
  deploy even with these tools (yes, I know, capistrano is much faster...)

- Many, roughly 50% of the packages in the bundle are already packaged
  for Fedora i. e., they could be removed from the bundle and added as
  dependencies instead.  This is likely to make things more stable in the
  long run.  diaspora.spec has a list.
