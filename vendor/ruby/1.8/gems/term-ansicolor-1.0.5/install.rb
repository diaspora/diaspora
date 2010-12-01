#!/usr/bin/env ruby

require 'rbconfig'
include Config
require 'fileutils'
include FileUtils::Verbose

destdir = "#{ENV['DESTDIR']}"
libdir = CONFIG["sitelibdir"]
dest = destdir + File.join(libdir, 'term')
mkdir_p dest
install 'lib/term/ansicolor.rb', dest
dest = destdir + File.join(libdir, 'term', 'ansicolor')
mkdir_p dest
install 'lib/term/ansicolor/version.rb', dest
