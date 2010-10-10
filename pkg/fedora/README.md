## Diaspora RPM tools

Creates RPM packages from diaspora git repository.  

An alternative to the capistrano system, providing classic, binary RPM 
packages for deployment on Fedora 13.


#### Synopsis:

*Prerequisites*: ruby-1.8, rubygem and other packages as described in
http://github.com/diaspora/diaspora/wiki/Rpm-installation-on-fedora
or http://github.com/diaspora/diaspora/wiki/Installing-on-CentOS-Fedora

Create source tarballs like  dist/diaspora-0.0-1010041233_fade4231.tar.gz  
and dist/diaspora-bundle-0.0-1010041233_fade4231.tar.gz:
    % ./make-dist.sh source
    % ./make-dist.sh bundle

Setup links to tarballs from RPM source directory:
    % ./make-dist.sh links

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

See http://github.com/diaspora/diaspora/wiki/Using-apache for  
apache/passenger setup. After configuration, start with:
    /sbin/service diaspora-ws start
    /sbin/service httpd restart


#### Notes

Routines uses last available version from master branch at github. The
version contains a time stamp and an abbreviated git commit id. If listed
in filename order, like ls does, latest version will be the last one.
Using -c, a specific commit can be used for source build.

*make-dist links* creates links  also for all files listed in SOURCES.
Typically, this is  secondary sources. *make-dist.sh sources*
applies all patches named *.patch in this directory after checking out
source from git.

The spec-files in dist/ are patched by ./make-dist.sh source to reference
correct versions of diaspora and diaspora-bundle. The diaspora-bundle
is only updated if Gemfile is updated, upgrading diaspora doesn't 
always require a new diaspora-bundle. Editing spec files should be done
in this directory, changes in dist/ are lost when doing ./make-dist source.

The topmost comment's version is patched to reflect the complete version
of current specfile by 'make-dist source'. WRite the comment in this 
directory, copy-paste previous version nr. It will be updated.

This has been confirmed to start up and provide basic functionality both using 
the thin webserver and apache passenger, and on 32/64 bit systems.

#### Bugs

As of now, diaspora fails if it not owns all file under /usr/share/diaspora.
I guess this means diaspora writes some stuff somewhere. In the long run,
this should be located and symlinked to /var,leaving the rest of the files
owned by root. FTM, all files in /usr/share/diaspore are owned by
diaspora


#### Implementation

'make-dist.sh source'  script checks out latest version of diaspora into the
 dist/diaspora directory. This content is, after some patches, the diaspora package.

'make-dir.sh bundle' makes a 'bundle install --deployment' in the diaspora dir.
The resulting bundle is stored in vendor/bundle. This is, after some more 
patches, the content of diaspora-bundle.

Here is also support for running the diaspora websocket service as a system 
service through /sbin/service and some install scripts.
    
Diaspora files are stored in /usr/share/diaspora, and owned by diaspora. The
bundle, containing some C extensions, is architecture-dependent and lives
in /usr/lib[64]/diaspora. Log files are in /var/log/diaspora. Symlinks in
/usr/share diaspora makes log and bundle available as expected by diaspora app.
This is more or less as mandated by LSB and Fedora packaging rules.
 
    find /usr/share/diaspora/ -type l -exec ls -l {} \; | awk '{print $9, $10, $11}'
    /usr/share/diaspora/master/public/uploads -> /var/lib/diaspora/uploads
    /usr/share/diaspora/master/log -> /var/log/diaspora
    /usr/share/diaspora/master/vendor/bundle -> /usr/lib/diaspora-bundle/master/vendor/bundle


#### Discussion

For better or worse, this installation differs from the procedure outlined in the
original README.md:

- All configuration is done in /usr/share/diaspore. No global ur user installed bundles
  are involved. Easier to maintain, but a mess if there should be parallel
  installations.

- Service is run under it's own uid, not root or an ordinary user account.

- Using the pre-packaged mongod server means that the DB has reasonable permissions,
  not 777.

- Splitting in two packages makes sense IMHO. The bundle is not changed that often,
  but is quite bug: ~18M without test packages (the default) or ~55M with test
  packages. The application is just ~7.5M, and is fast to deploy even with these
  tools (yes, I know, capistrano is much faster...)

- Many, roughly 50% of the packages in the bundle are already packaged for Fedora
  i. e., they could be removed from the bundle and added as dependencies instead.
  This is likely to make things more stable in the long run. 
  diaspora.spec has a list.
