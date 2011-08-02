= vegas

http://code.quirkey.com/vegas

== DESCRIPTION:

Vegas aims to solve the simple problem of creating executable versions of Sinatra/Rack apps.

== FEATURES/PROBLEMS:

Currently, Vegas just includes a single class Vegas::Runner which wraps your Sinatra app to give it command line options, daemon-ization, PID/URL tracking, and browser launching.

Lets say you have a gem with a sinatra application. With Vegas you can create a bin that looks like
  
  #!/usr/bin/env ruby
  # ./bin/myapp
  
  require File.expand_path(File.dirname(__FILE__) + "/../lib/myapp")
  require 'vegas'
  
  Vegas::Runner.new(Sinatra::Application, 'myapp')
  

See the website: http://code.quirkey.com/vegas for full usage/options.

=== WINDOWS:

Using vegas (and gems that depend on it) on Windows works but isn't 100% the same. 
Daemon-ization and browser launching work, but you will see duplicate messages. 
Some options might also be lost in the process. I suggest running Vegas apps
in windows with the -F (foreground) flag.

If you see a warning like:

  `expand_path': couldn't find HOME environment -- expanding `~/.vegas' (ArgumentError)

You have to set your HOME path:

  c:\> set HOME=%HOMEPATH%

== INSTALL:

  sudo gem install vegas

== LICENSE:

MIT LICENSE, see LICENSE for details