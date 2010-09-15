# Diaspora

The privacy aware, personally controlled, do-it-all, open source social network.

**DISCLAIMER: THIS IS PRE-ALPHA SOFTWARE AND SHOULD BE TREATED ACCORDINGLY.**
These instructions are for machines running [Ubuntu](http://www.ubuntu.com/) or Mac OS X.

## Preparing your system
In order to run Diaspora, you will need to download the following dependencies (specific instructions follow):

- Build Tools - Packages needed to compile the components that follow.
- [Ruby](http://www.ruby-lang.org) - The Ruby programming language.  (We're using **1.8.7**.  It comes preinstalled on Mac OS X.)
- [MongoDB](http://www.mongodb.org) - A snappy noSQL database.
- [OpenSSL](http://www.openssl.org/) - An encryption library.  (It comes preinstalled on Mac OS X and Ubuntu.)
- [ImageMagick](http://www.imagemagick.org/) - An Image processing library used to resize uploaded photos.
- [Git](http://git-scm.com/) - The fast version control system.

After you have Ruby installed on your system, you will need to get RubyGems, then install Bundler:

- [RubyGems](http://rubygems.org/) - Source for Ruby gems.
- [Bundler](http://gembundler.com/) - Gem management tool for Ruby projects.

**We suggest using a package management system to download these dependencies.  Trust us, it's going to make your life a lot easier.  If you're using Mac OS X, you can use [homebrew](http://mxcl.github.com/homebrew/); and if you're using Ubuntu, just use [Synaptic](http://www.nongnu.org/synaptic/) (it comes pre-installed).  The instructions below assume you have these installed.**  

### Build Tools

To install build tools on **Ubuntu**, run the following (includes the gcc and xml parsing dependencies):

		sudo apt-get install build-essential libxslt1.1 libxslt1-dev libxml2

To install build tools on **Mac OS X**, you need to download and install [Xcode](http://developer.apple.com/technologies/tools/xcode.html).

### Ruby

To install Ruby 1.8.7 on **Ubuntu**, run the following command:

		sudo apt-get install ruby-full

If you're on **Mac OS X**, you already have Ruby on your system.  Yay!

### MongoDB

To install MongoDB on **Ubuntu**, run the following commands:


If you're running a 32-bit system, run `wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-1.6.2.tgz`.  If you're running a 64-bit system, run `wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-1.6.2.tgz`.

		# extract
		tar xzf mongodb-linux-i686-1.4.0.tgz
		# create the required data directory
		sudo mkdir -p /data/db
		sudo chmod -Rv 777 /data/
			

To install MongoDB on **Mac OS X**, run the following:

		brew install mongo

### OpenSSL

If you're running either **Ubuntu** or **Mac OS X** you already have OpenSSL installed!

### ImageMagick

To install ImageMagick on **Ubuntu**, run the following:

		sudo apt-get install imagemagick libmagick9-dev

To install ImageMagick on **Mac OS X**, run the following:

		brew install imagemagick

### Git

To install Git on **Ubuntu**, run the following:
		
		sudo apt-get install git-core

To install Git on **Mac OS X**, run the following:

		brew install git


### Rubygems

On **Ubuntu**, run the following:

		wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
		tar -xf rubygems-1.3.7.tgz
		cd rubygems-1.3.7
		sudo ruby setup.rb
		sudo ln -s /usr/bin/gem1.8 /usr/bin/gem

On **Mac OS X**, RubyGems comes preinstalled; however, you might need to update it for use with the latest Bundler.  To update RubyGems, run `sudo gem update --system`.


### Bundler

After RubyGems is updated, simply run `sudo gem install bundler` to get Bundler.


## Getting Diaspora

		git clone git@github.com:diaspora/diaspora.git

If you have never used github before, their [help desk](http://help.github.com/) has a pretty awesome guide on getting setup.


## Running Diaspora

### Install required gems
To start the app server for the **first time**, Bundler needs to grab Diaspora's gem depencencies.  To allow this, run `bundle install` from Diaspora's root directory.  

It is important to run a bundle install every so often, in the event of a new gem dependency.  We will make sure to make an announcement in the event of a gem change.

### Start Mongo
After installing the above, run `sudo mongod` from where mongo is installed to start mongo.
		
Diaspora will **not run** unless mongo is running.  Mongo will not run by default, and will need to be started every time you wish to use or run the test suite for Diaspora.

### Run the app server
Once mongo is running and bundler has finished, run `bundle exec thin start` from the root Diaspora directory.  This will start the app server in development mode[.](http://bit.ly/9mwtUw)

### Testing
Diaspora's test suite uses [rspec](http://rspec.info/), a behavior driven testing framework.  In order to run the tests, run `bundle exec rspec spec`.


## Resources

We are maintaining a [public tracker project](http://www.pivotaltracker.com/projects/61641) and a [wishlist](#).

Ongoing discussion:

- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [#diaspora-dev](irc://irc.freenode.net/#diaspora-dev)

More general info and updates about the project can be found on our [blog](http://joindiaspora.com), [twitter](http://twitter.com/joindiaspora).  Also, be sure to join the official [mailing list](http://http://eepurl.com/Vebk).


## License
Copyright 2010 Diaspora Inc.

Diaspora is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Diaspora is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.  

