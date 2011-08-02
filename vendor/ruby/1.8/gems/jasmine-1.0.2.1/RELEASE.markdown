# Releasing Jasmine

Add release notes to gh-pages branch /release-notes.html.markdown

## Jasmine core

* update version.json with new version
* rake jasmine:dist
* add pages/downloads/*.zip
* commit, tag, and push both jasmine/pages and jasmine
* * git push
* * git tag -a x.x.x-release
* * git push --tags

## Jasmine Gem

* update version in version.rb
  * for release candidates, add "rc" + number to the end of the appropriate version part,
  e.g. we should have tagged the 1.0 RC's as 1.0.0rc1, not 1.0.0.rc1. Likewise 1.0.0.1rc1.
* rake jeweler:install and try stuff out
* * (jasmine init and script/generate jasmine)
* rake site
