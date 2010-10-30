## Diaspora RPM tools

Creates diaspora source tarballs and RPM packages

An alternative to the capistrano system, providing classic, binary RPM
packages for deployment on Fedora 13 and OS-independent source tarballs
aimed for packaging purposes.


#### Fedora RPM synopsis

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
[source README](http://github.com/diaspora/diaspora/blob/master/source/fedora/README.md)

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

#### Notes

prepare-rpm.sh prepare creates links  also for all files listed in SOURCES.
Typically, this is  secondary sources. *make-dist.sh source*
applies all patches named *.patch in this directory after checking out
source from git.

The spec-files in dist/ are patched by *./make-dist.sh prepare* to reference
correct versions of diaspora and diaspora-bundle. The diaspora-bundle
is only updated if Gemfile is updated, upgrading diaspora doesn't
always require a new diaspora-bundle. Editing spec files should be done
in this directory, changes in dist/ are lost when doing *./make-dist prepare*.

The topmost comment's version is patched to reflect the complete version
of current specfile by *make-dist source*. Write the comment in this
directory, copy-paste previous version nr. It will be updated.

This has been confirmed to start up and provide basic functionality both using
the thin webserver and apache passenger, on 32/64 bit systems and in the
mock build environment. Irregular nightly builds are available form time to time
at [ftp://mumin.dnsalias.net/pub/leamas/diaspora/builds](ftp://mumin.dnsalias.net/pub/leamas/diaspora/builds)

#### Implementation

'make-dist.sh source'  script checks out latest version of diaspora into the
 dist/diaspora directory. This content is, after some patches, the diaspora package.

'make-dir.sh bundle' makes a *bundle package* in the diaspora dir.
The resulting bundle is stored in vendor/bundle. This is, after some more
patches, the content of diaspora-bundle tarball. Target systems makes a
*bundle install --local* to use it.

Here is also support for running the diaspora websocket service as a system
service through /sbin/service and some install scripts.

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
