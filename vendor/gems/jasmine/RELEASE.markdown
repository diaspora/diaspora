Releasing Jasmine

Add release notes to gh-pages branch /release-notes.html.markdown

Jasmine core

* update version.json with new version
* rake jasmine:dist
* add pages/downloads/*.zip
* commit, tag, and push both jasmine/pages and jasmine
* * git push
* * git tag -a x.x.x-release
* * git push --tags

Jasmine Gem

* rake jeweler:version:bump:(major/minor/patch)
* rake jeweler:install and try stuff out
* * (jasmine init and script/generate jasmine)
* commit, tag, and push
* * git push
* * git tag -a x.x.x.x-release
* * git push --tags
* rake jeweler:release
* rake site
