Monitor API
===========

There are three ways you can run the monitor.

1. call monitor with a path parameter, and define callbacks in a block
2. call monitor with a block to configure multiple paths and callbacks
3. create a monitor object and run each step manually

Monitor with path
-----------------

This form watches one path, and enters the run loop automatically. The first parameter is the path to watch, and the second parameter is an optional glob pattern or array of glob patterns that a file must match in order to trigger a callback. The default glob, if ommitted, is `'**/*'`.

	FSSM.monitor('/some/directory/', '**/*') do
	  update {|base, relative|}
	  delete {|base, relative|}
	  create {|base, relative|}
	end

Monitor with block
------------------

This form watches one or more paths, and enters the run loop automatically. The glob configuration call can be ommitted, and defaults to `'**/*'`.

	FSSM.monitor do
	  path '/some/directory/' do
	    glob '**/*.yml'
   
	    update {|base, relative|}
	    delete {|base, relative|}
	    create {|base, relative|}
	  end
 
	  path '/some/other/directory/' do
	    update {|base, relative|}
	    delete {|base, relative|}
	    create {|base, relative|}
	  end
	end

Monitor object
--------------

This form doesn't enter the run loop automatically.

	monitor = FSSM::Monitor.new

	monitor.path '/some/directory/' do
	  update {|base, relative|}
	  delete {|base, relative|}
	  create {|base, relative|}
	end

	monitor.run
