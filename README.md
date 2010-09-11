Diaspora
========

The privacy aware, personally controlled, do-it-all, open source social network.


Getting started
---------------

In order to run Diaspora for development, there are a few external dependencies in getting your environment set up:

- [MongoDB](http://www.mongodb.org/downloads) - noSQL data layer.
- [OpenSSL](http://www.openssl.org/source/) - Used in the current encryption implementation.
- [ImageMagick](http://www.imagemagick.org/script/binary-releases.php?ImageMagick=0nfesabhe916b9afjc4qiikv03) - Image processing library used to resize uploaded photos.
- [Bundler](http://gembundler.com/) - Gem management tool for Ruby projects.


After installing the above, run
		sudo bin/mongod

from where mongo is installed to start mongo.  Diaspora will **not run** until mongo is running.  Mongo will not run by default, and will need to be started every time you wish to use or run the test suite for Diaspora.  It is highly recommended you alias the command to start the database in your .bashrc file.

In order to start the app server for the first time, bundler needs to grab Diaspora's gem depencencies.  To allow this, run
		bundle install

from Diaspora's root directory.  It is important to run a bundle install every so often, in the event of a new gem dependency.  We will make sure to make an announcement in the event of a gem change.

Once mongo is running and bundler has finished, run
		bundle exec thin start
to begin the app server in development mode.

Diaspora's test suite uses [rspec]:(http://rspec.info/), a behavior driven testing framework.  In order to run the tests, run
		bundle exec rspec spec


Getting Help
------------

There are multiple outlets of ongoing discussion on the development of Diaspora.

- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [#diaspora-dev](irc://irc.freenode.net/#diaspora-dev)

More general info and updates about the project can be found on our [blog](http://joindiaspora.com), [twitter](http://twitter.com/joindiaspora).  Also, be sure to join the official [mailing list](http://http://eepurl.com/Vebk).

