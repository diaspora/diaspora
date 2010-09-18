## Commit Guidlines
You are welcome to contribute, add and extend Diaspora however you see fit.  We will do our best to incorporate everything that meets our guidelines.

We need you to fill out a [contributor agreement form](https://spreadsheets.google.com/a/joindiaspora.com/viewform?formkey=dGI2cHA3ZnNHLTJvbm10LUhXRTJjR0E6MQ&theme=0AX42CRMsmRFbUy1iOGYwN2U2Mi1hNWU0LTRlNjEtYWMyOC1lZmU4ODg1ODc1ODI&ifq) before we can accept your patches.  The agreement gives Diaspora joint ownership of the patch so the copyright isn't scattered.  You can find it [here](https://spreadsheets.google.com/a/joindiaspora.com/viewform?formkey=dGI2cHA3ZnNHLTJvbm10LUhXRTJjR0E6MQ&theme=0AX42CRMsmRFbUy1iOGYwN2U2Mi1hNWU0LTRlNjEtYWMyOC1lZmU4ODg1ODc1ODI&ifq). 

All commits must be tested, and after each commit, all tests should be green before a pull request is sent.  Please write your tests in Rspec.

GEMS:  We would like to keep external dependencies unduplicated.  We're using Nokogiri, and Mongomapper, and EM::HttpRequest as much as possible.  We have a few gems in the project we'd rather not use, but if you can, use dependencies we already have.

# Diaspora

The privacy aware, personally controlled, do-it-all, open source social network.

**DISCLAIMER: THIS IS PRE-ALPHA SOFTWARE AND SHOULD BE TREATED ACCORDINGLY.**
**PLEASE, DO NOT RUN IN PRODUCTION.  IT IS FUN TO GET RUNNING, BUT EXPECT THINGS TO BE BROKEN**

Also, we really want to continue to focus on features and improving the code base. When we think it is 
ready for general use, we will post more detailed instructions.



These instructions are for machines running [Ubuntu](http://www.ubuntu.com/), [Fedora](http://www.fedoraproject.org) or Mac OS X.  We are developing Diaspora for the latest and greatest browsers, so please update your Firefox, Chrome or Safari to the latest and greatest.

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

**We suggest using a package management system to download these dependencies.  Trust us, it's going to make your life a lot easier.  If you're using Mac OS X, you can use [homebrew](http://mxcl.github.com/homebrew/); if you're using Ubuntu, just use [Synaptic](http://www.nongnu.org/synaptic/) (it comes pre-installed); if you're using Fedora simply use [yum](http://yum.baseurl.org/).  The instructions below assume you have these installed.**

### Build Tools

To install build tools on **Ubuntu**, run the following (includes the gcc and xml parsing dependencies):

		sudo apt-get install build-essential libxslt1.1 libxslt1-dev libxml2

To install build tools on **Fedora**, run the following:

		sudo yum install libxslt libxslt-devel libxml2 libxml2-devel

To install build tools on **Mac OS X**, you need to download and install [Xcode](http://developer.apple.com/technologies/tools/xcode.html).

### Ruby

To install Ruby 1.8.7 on **Ubuntu**, run the following command:

		sudo apt-get install ruby-full

Please note that you need to have Universe enabled in your /etc/apt/sources.list file to install ruby using apt-get. 

At this time Fedora does not have Ruby 1.8.7. As a workaround it is possible to use [rvm](http://rvm.beginrescueend.com/) with a locally compiled Ruby installation. A semi automated method for doing this is available. It is highly recommended that you review the script before running it so you understand what will occur. The script can be executed by running the following command:

		./script/bootstrap-fedora-diaspora.sh

After reviewing and executing the above script you will need to follow the "MongoDB" section and then you should skip all the way down to "Start Mongo".


If you're on **Mac OS X**, you already have Ruby on your system.  Yay!

### MongoDB

To install MongoDB on **Ubuntu**, add the official MongoDB repository from this link:

http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages

For Lucid, add the following line to your /etc/apt/sources.list (for other distros, see http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages):

		deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen

And then run:
		sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
		sudo apt-get update
		sudo apt-get install mongodb-stable

You can also run the binary directly by doing the following:

If you're running a 32-bit system, run `wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-1.6.2.tgz`.  If you're running a 64-bit system, run `wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-1.6.2.tgz`.

		# extract
		tar xzf mongodb-linux-i686-1.4.0.tgz
		# create the required data directory
		sudo mkdir -p /data/db
		sudo chmod -Rv 777 /data/


To install MongoDB on a x86_64 **Fedora** system, add the official MongoDB repository from MongoDB (http://www.mongodb.org/display/DOCS/CentOS+and+Fedora+Packages) into /etc/yum.repos.d/10gen.repo:

		[10gen]
		name=10gen Repository
		baseurl=http://downloads.mongodb.org/distros/fedora/13/os/x86_64/
		gpgcheck=0
		enabled=1


Then use yum to install the packages:

		sudo yum install mongo-stable mongo-stable-server


If you're running a 32-bit system, run `wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-1.6.2.tgz`.  If you're running a 64-bit system, run `wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-1.6.2.tgz`.

		# extract
		tar xzf mongodb-linux-i686-1.4.0.tgz
		# create the required data directory
		sudo mkdir -p /data/db
		sudo chmod -Rv 777 /data/


To install MongoDB on **Mac OS X**, run the following:

		brew install mongo
		sudo mkdir -p /data/db
		sudo chmod -Rv 777 /data/

### OpenSSL

If you're running either **Ubuntu**, **Fedora** or **Mac OS X** you already have OpenSSL installed!

### ImageMagick

To install ImageMagick on **Ubuntu**, run the following:

		sudo apt-get install imagemagick libmagick9-dev

To install ImageMagick on **Fedora**, run the following:

		sudo yum install ImageMagick

To install ImageMagick on **Mac OS X**, run the following:

		brew install imagemagick

### Git

To install Git on **Ubuntu**, run the following:

		sudo apt-get install git-core

To install Git on **Fedora**, run the following:

		sudo yum install git


To install Git on **Mac OS X**, run the following:

		brew install git


### Rubygems

On **Ubuntu** 10.04, run the following:

		sudo add-apt-repository ppa:maco.m/ruby
		sudo apt-get update
		sudo apt-get install rubygems

This PPA is maintained by an Ubuntu Developer. For Ubuntu 10.10, this version of rubygems is in the repositories.

On **Fedora**, run the following:

		sudo yum install rubygems

On **Mac OS X**, RubyGems comes preinstalled; however, you might need to update it for use with the latest Bundler.  To update RubyGems, run `sudo gem update --system`.


### Bundler

After RubyGems is updated, simply run `sudo gem install bundler` to get Bundler.  If you're using Ubuntu repository .debs, bundler is found at /var/lib/gems/1.8/bin/bundle


## Getting Diaspora

		git clone http://github.com/diaspora/diaspora.git

If you have never used github before, their [help desk](http://help.github.com/) has a pretty awesome guide on getting setup.


## Running Diaspora

### Install required gems
To start the app server for the first time, you need to use Bundler to install Diaspora's gem depencencies.  Run `bundle install` from Diaspora's root directory.  Bundler will also warn you if there is a new dependency and you need to bundle install again.

### Start Mongo
If you installed the Ubuntu package, MongoDB should already be running (if not, run `service mongodb start`). If you installed the binary manually, run `sudo mongod` from where mongo is installed to start mongo.

If you installed the Fedora package, MongoDB will need to be started via `service mongodb start`. If you installed the binary manually, run `sudo mongod` from where mongo is installed to start mongo.

If you installed the OsX package through "brew", MongoDB will need to be started via `sudo launchctl load /Library/LaunchDaemons/org.mongodb.mongod.plist`. (before you have to go to /Library/LaunchDaemons and add a symlink to /usr/local/Cellar/mongodb/1.6.2-x86_64/org.mongodb.mongod.plist)

Diaspora will not run unless mongo is running.  Mongo will not run by default, and will need to be started every time you wish to use or run the test suite for Diaspora.

### Run the server
`./script/server` will start both thin and the websocket server.  If you want to run a different app server, you will have to run them separately.  See below for instructions.

### Run the app server
Once mongo is running and bundler has finished, run `bundle exec thin start` from the root Diaspora directory.  This will start the app server in development mode[.](http://bit.ly/9mwtUw)

### Run the websocket server
run `bundle exec ruby ./script/websocket_server` to start the websocket server on port 8080.  Change the port in config/app_config.yml.

### Logging in
Run `rake db:seed:tom`, then login with user `tom` and password `evankorth`. More details in db/seeds/tom.rb.


### Testing
Diaspora's test suite uses [rspec](http://rspec.info/), a behavior driven testing framework.  In order to run the tests, run `bundle exec rspec spec`.

## Resources

We are maintaining a [public tracker project](http://www.pivotaltracker.com/projects/61641) and a [roadmap](https://github.com/diaspora/diaspora/wiki/Roadmap).  Also, you can file [bug reports](https://github.com/diaspora/diaspora/issues) right here on github.

Ongoing discussion:
- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [Diaspora Q&A site](http://diaspora.shapado.com/)
- [#diaspora-dev](irc://irc.freenode.net/#diaspora-dev)

More general info and updates about the project can be found on our [blog](http://joindiaspora.com), [twitter](http://twitter.com/joindiaspora).  Also, be sure to join the official [mailing list](http://http://eepurl.com/Vebk).

If you wish to contact us privately about any exploits in Diaspora you may find, you can email [exploits@joindiaspora.com](mailto:exploits@joindiaspora.com).


## License
Copyright 2010 Diaspora Inc.

Diaspora is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Diaspora is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.

