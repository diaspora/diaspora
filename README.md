Diaspora
========

The privacy aware, personally controlled, do-it-all, open source social network.


Preparing your system
---------------------

In order to run Diaspora for development, there are a few external dependencies in getting your environment set up:

- [Ruby](http://www.ruby-lang.org) - The Ruby programming language.  __(We're using 1.8.  Comes preinstalled on Mac OS X.)__
- [MongoDB](http://www.mongodb.org) - A snappy noSQL database.
- [OpenSSL](http://www.openssl.org/) - An encryption implementation.  (Comes preinstalled on Mac OS X and later versions of Ubuntu.)
- [ImageMagick](http://www.imagemagick.org/) - An Image processing library used to resize uploaded photos.
- [Git](http://git-scm.com/) - The fast version controll system.

We suggest using a package management system to download these dependencies.  Trust us, it's going to make your life a lot easier.  If you're using Mac OS X, you can use [homebrew](http://mxcl.github.com/homebrew/); and if you're using Debian, just use Synaptic (it comes pre-installed).


After you have Ruby installed on your system, you will need to get Bundler.

- [Bundler](http://gembundler.com/) - Gem management tool for Ruby projects.


Getting Diaspora
----------------

To download Diaspora, you will want to clone it from the official github repository [here](http://github.com/diaspora/diaspora).  If you have never used github before, their [help desk](http://help.github.com/) has a pretty awesome guide on getting setup[.](http://www.youtube.com/watch?v=OQSNhk5ICTI)


Running Diaspora
----------------

After installing the above, run the following command from where mongo is installed to start mongo.
		sudo mongod
Diaspora will **not run** unless mongo is running.  Mongo will not run by default, and will need to be started every time you wish to use or run the test suite for Diaspora.

In order to start the app server for the first time, bundler needs to grab Diaspora's gem depencencies.  To allow this, run the following command from Diaspora's root directory.  
		bundle install

It is important to run a bundle install every so often, in the event of a new gem dependency.  We will make sure to make an announcement in the event of a gem change.

Once mongo is running and bundler has finished, run:
		bundle exec thin start
This will start the app server in development mode.

Diaspora's test suite uses [rspec](http://rspec.info/), a behavior driven testing framework.  In order to run the tests, run the following command:
		bundle exec rspec spec


Getting Help
------------

There are multiple outlets of ongoing discussion on the development of Diaspora.

- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [#diaspora-dev](irc://irc.freenode.net/#diaspora-dev)

More general info and updates about the project can be found on our [blog](http://joindiaspora.com), [twitter](http://twitter.com/joindiaspora).  Also, be sure to join the official [mailing list](http://http://eepurl.com/Vebk).


License
-------
Copyright 2010 Diaspora Inc.

Diaspora is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Diaspora is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.  


