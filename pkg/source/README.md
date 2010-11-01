## Diaspora source tarball generation

Creates diaspora source tarballs.

#### Generic source synopsis

Generate source tarball:
    % ./make-dist.sh source
    Using repo:          http://github.com/diaspora/diaspora.git
    Commit id:           1010092232_b313272
    Source:              dist/diaspora-0.0-1010092232_b313272.tar.gz
    Required bundle:     1010081636_d1a4ee0
    %

The source tarball could be used as-is, by unpacking add making a
*bundle install*. An alternative is to generate a canned bundle like:
    % ./make-dist.sh bundle
          [ lot's of output...]
    Bundle: dist/diaspora-bundle-0.0-1010081636_d1a4ee0.tar.gz
    %

This file can be installed anywhere. To use it, add a symlinks from app
to the bundle'.  Reasonable defaults are to install diaspora in
/usr/share/diaspora and bundle in /usr/lib/diaspora-bundle. With these,
the link setups is
    % cd /usr/share/diaspora/master
    % rm -rf vendor
    % ln -sf /usr/lib/diaspora-bundle/vendor  vendor
    % ln -sf /usr/lib/diaspora-bundle/Gemfile .
    % ln -sf /usr/lib/diaspora-bundle/Gemfile.lock .


The directories tmp, log, and public/uploads needs to be writable. If using
apache passenger, read the docs on uid used and file ownership.

Note that the bundle version required is printed each time a new source
is generated.

#### Notes

The source tarball is as retrieved from diaspora with following differences:

   - The .git directories are removed (freeing more than 50% of the size).
   - A new file /master/config/gitversion is created.
   - The file public/source.tar.gz is generated.
   - The file .bundle/config  is patched. Remove before doing
     *bundle install*

The bundle is basically the output from 'bundle package'. The git-based
gems are also added into git-gems. Bundle also houses the two files
Gemfile and Gemfile.lock

*make-dist.sh source* applies all patches named *.patch in this directory
after checking out source from git.

./make-dist.sh bundle|source occasionally fails on bad Gemfile.lock. The
root cause is a bad Gemfile in the git repo. Possible fixes includes
using a older version known to work:
     % ./make-dist.sh -c c818885b6 bundle
     % ./make-dist.sh -c c818885b6 source

or forcing a complete update of Gemfile.lock using 'bundle update' (a
potentially problematic operation):
     % ./make-dist.sh -f bundle

#### Implementation

'make-dist.sh source'  script checks out latest version of diaspora into the
 dist/diaspora directory. This content is, after some patches, the diaspora package.

'make-dir.sh bundle' makes a *bundle package* in the diaspora dir.
The resulting bundle is stored in vendor/bundle. This is, after some more
patches, the content of diaspora-bundle tarball. Target systems makes a
*bundle install --local* to use it.
