## Diaspora RPM tools

Creates RPM packages from diaspora git repository.  

An alternative to the capistrano system, providing classic, binary RPM 
packages for deployment on Fedora 13.

#### Synopsis:

*Prerequisites*: ruby-1.8, rubygem and other packages as described in
http://github.com/diaspora/diaspora/wiki/Rpm-installation-on-fedora

Create source tarballs like  dist/diaspora-0.0-1010041233_fade4231.tar.gz  
and dist/diaspora-bundle-0.0-1010041233_fade4231.tar.gz
    % ./make_dist.sh source
    % ./make_dist.sh bundle

Setup links to tarballs from RPM source directory:
    % ./make_dist.sh links

Build rpms:
    rpmbuild -ba dist/diaspora.spec
    rpmbuild -ba dist/diaspora-bundle.spec

Install
    rpm -U ~/rmpbuild/rpms/i686/diaspora-bundle-0.0-1.1010042345_4343fade43.fc13.i686
    rpm -U ~/rmpbuild/rpms/noarch/diaspora-0.0-1.1010042345_4343fade43.fc13.noarch

Initiate (as root). 
    /usr/share/diaspora/diaspora-setup

Start development server:
    sudo
    su - diaspora
    cd master
    ./script/server

See http://github.com/diaspora/diaspora/wiki/Using-apache for  
apache/passenger setup. After configuration, start with:
    /sbin/service diaspora-ws start
    /sbin/service httpd restart


#### Notes

Routines uses last available version from master branch at github. The
version contains a time stamp and an abbreviated git commit id. If listed
in filename order, like ls does, latest version will be the last one.

You need to copy all patches and secondary sources in this dir to
the rpm source directory a. k. a. $(rpm --eval %_sourcedir). This
includes some hidden .* files.

The spec-files in dist/ are patched by ./make_dist.sh source to reference
correct versions of diaspora and diaspora-bundle. The diaspora-bundle
is only updated if Gemfile is updated, upgrading diaspora doesn't 
always require a new diaspora-bundle. Editing spec files should be done
in this directory, changes in dist/ are lost when doing ./make_dist source.

rpmlint shows many errors, most of which related to that the server
won't start if the .git directories are not included. Needs investigation.

This has been confirmed to start up and provide basic functionality both using 
the thin webserver and apache passenger.

#### Implementation


'make_dist.sh source'  script checks out latest version of diaspora into the
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
