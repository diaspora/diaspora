## Diaspora RPM tools

Creates Fedora 13 RPM packages from diaspora git repository.

#### Synopsis:

    # Create dist/diaspora-0.0-1010041233_fade4231.tar.gz
    % ./make_dist.sh source

    # Create dist/diaspora-bundle-0.0-1010041233_fade4231.tar.gz
    % ./make_dist.sh bundle

    # Setup links to tarballs from RPM source directory:
    % ./make_dist.sh links

    # Build rpms:
    rpmbuild -ba dist/diaspora.spec
    rpmbuild -ba dist/diaspora-bundle.spec

    #Install
    rpm -U ~/rmpbuild/rpms/i686/diaspora-bundle-0.0-1.1010042345_4343fade43.fc13.i686
    rpm -U ~/rmpbuild/rpms/noarch/diaspora-0.0-1.1010042345_4343fade43.fc13.noarch

    #Initiate (as root)
    /usr/sbin/diaspora-setup
    # Fix hostname afterwards by editing pod_url in
    # /usr/share/diaspora/master/config/app_config.yml


    # Start development server:
    sudo
    su - diaspora
    cd master
    ./script/server

    # Start using apache passenger:
    # See: http://github.com/diaspora/diaspora/wiki/Using-apache
    
#### Notes

Routines uses last available version from master branch at github.

You need to copy all patches and secondary sources in this dir to
the rpm source directory a. k. a. $(rpm --eval %_sourcedir).

The spec-files in dist/ are patched by ./make_dist.sh source to reference
correct versions of diaspora and diaspora-bundle. The diaspora-bundle
is only updated if Gemfile is updated, upgrading diaspora doesn't 
always require a new diaspora-bundle.

rpmlint shows many errors, most of which related to that the server
won't start if the .git directories are not included. Needs investigation.

This has been confirmed to start up and provide basic functionality both using 
the thin webserver and apache passenger.
