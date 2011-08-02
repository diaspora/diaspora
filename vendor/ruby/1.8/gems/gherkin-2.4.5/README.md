A fast lexer and parser for the Gherkin language based on Ragel. Gherkin is two things:

* The language that has evolved out of the Cucumber project.
* This library

Supported platforms:

* Ruby 1.8.6-1.9.2 (MRI, JRuby, REE, Rubinius)
* Pure Java
* Javascript (Tested with V8/node.js/Chrome, but might work on other Javascript engines)
* .NET
* IronRuby (experimental)

## Installing the toolchain

Due to the cross-platform nature of this library, you have to install a lot of tools to build gherkin yourself.
In order to make it easier for occasional contributors to get the development environment up and running, you don't
have to install everything up front. The build scripts should tell you if you are missing something. For example,
you shouldn't have to install MinGW to build windows binaries if you are a Linux user and just want to fix a bug in
the C code.

### Common dependencies

These are the minimal tools you need to install:

* Ragel (brew install ragel or apt-get install ragel)
* Ruby (any version should do).
* A clone of the cucumber git repo to a "cucumber" sibling folder of your gherkin folder. (Only needed to run cucumber tests)
* RVM (you may not need this if you are only building for a single platform)

With this minimal toolchain installed, install Ruby gems needed by the build:

    gem install bundler
    bundle install

Running RSpec and Cucumber tests

    rake clean spec cucumber

If the RL_LANGS environment variable is set, only the parsers for the languages specified there will be built.
E.g. in Bash, export RL_LANGS="en,fr,no". This can be quite helpful when modifying the Ragel grammar.

See subsections for building for a specific platform.

### MRI, REE or Rubinius

You'll need GCC installed.

Build the gem with:

    rake build

### Pure Java and JRuby

You must install JRuby to build the pure Java jar or the JRuby gem:

    rvm install jruby
    rvm use jruby
    rvm gemset create cucumber
    rvm use @cucumber
    gem install bundler
    bundle install

Now you can build the jar with:

    rake clean jar

### Javascript

In order to build and test Gherkin for Javascript you must install:

* Node.js (0.4.6 or higher)
* NPM (0.3.18 or higher)
* Ragel with Javascript support: http://github.com/dominicmarks/ragel-js
* Define the GHERKIN_JS environment variable in your shell (any value will do)

Now you can build the Javascript with:

    rake js
    cd js
    npm install

And you can try it out with node.js:

    node js/example/print.js spec/gherkin/fixtures/1.feature

You can also try out Gherkin running in the browser (likely to move to a separate project):

    # Pull in the Ace (http://ace.ajax.org/) editor:
    git submodule update --init
    # Open a sample Gherkin-powered editor in Chrome
    open js/example/index.html

If you're hacking and just want to rebuild the English parser:

  rake js/lib/gherkin/lexer/en.js

TODO: Make all specs pass with js lexer - replace 'c(listener)' with 'js(listener)' in i18n.rb

### .NET and IronRuby

You must install Mono and IKVM to build the pure .NET dll and the IronRuby gem:

* Install Mono from http://www.mono-project.com/ and make sure it's on your $PATH
* Download IKVM from http://www.ikvm.net/ and extract it to /usr/local/ikvm so that you have a /usr/local/ikvm/bin/ikvmc.exe

Now you can build the .NET dll with:

    rake ikvm

### MinGW Rubies (for Windows gems)

In order to build Windows binaries (so we can release Windows gems from OS X/Linux) we need to set up rake-compiler.

http://github.com/luislavena/rake-compiler/

Now, let's install MinGW...

I didn't want to install macports (I'm on homebrew) and I couldn't figure out how to build MinGW myself. I got prebuilt binaries (version 4.3.0):
http://crossgcc.rts-software.org/doku.php - just add the bin folder to your PATH

You must install MinGW rubies to build gems fow Windows.
First you need to download and install MinGW:

OS X users can get it from http://crossgcc.rts-software.org/doku.php
Once you have installed it, add this to your .bashrc:

    export PATH=$PATH:/usr/local/i386-mingw32-4.3.0/bin

Now, let's install some rubies.
Make sure you have openssl installed first.

    brew install openssl

    # 1.8.6
    # Don't worry about inconsistent patchlevels here. It works.
    rvm install 1.8.6-p399
    rvm use 1.8.6-p399
    rvm gemset create cucumber
    rvm use @cucumber
    gem install bundler
    bundle install
    rake-compiler cross-ruby VERSION=1.8.6-p287

    # 1.9.1
    # Later 1.9.1 patch levels or 1.9.2 don't compile on mingw.
    # The compiled binaries should still work on 1.9.2
    rvm install 1.9.1-p243
    rvm use 1.9.1-p243
    rvm gemset create cucumber
    rvm use @cucumber
    gem install bundler
    bundle install
    rake-compiler cross-ruby VERSION=1.9.1-p243

## Release process

* Make sure GHERKIN_JS is defined (see Javascript section above)
* Bump version in:
  * gherkin.gemspec
  * java/pom.xml
  * ikvm/Gherkin/Gherkin.csproj (2 places)
  * js/package.json
* Run bundle update, so Gemfile.lock gets updated with the changes.
* Commit changes, otherwise you will get an error at the end when a tag is made.
* bundle exec rake gems:prepare && ./build_native_gems.sh && bundle exec rake release:ALL
  * The specs intermittently fail with a segfault from therubyracer. Running specs can be disabled with SKIP_JS_SPECS=true
* Announce on Cucumber list, IRC and Twitter.

## Note on Patches/Pull Requests
 
* Fork the project.
* Run rake ragel:rb to generate all the I18n lexers
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile, VERSION, or History.txt.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009-2010 Mike Sassak, Gregory Hnatiuk, Aslak Hellesøy. See LICENSE for details.
