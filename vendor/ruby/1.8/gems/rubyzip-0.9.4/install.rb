#!/usr/bin/env ruby

$VERBOSE = true

require 'rbconfig'
require 'find'
require 'fileutils'

include Config

files = %w{ stdrubyext.rb ioextras.rb zip.rb zipfilesystem.rb ziprequire.rb tempfile_bugfixed.rb }

INSTALL_DIR = File.join(CONFIG["sitelibdir"], "zip")
FileUtils.makedirs(INSTALL_DIR)

SOURCE_DIR = File.join(File.dirname($0), "lib/zip")

files.each { 
  |filename|
  installPath = File.join(INSTALL_DIR, filename)
  FileUtils::install(File.join(SOURCE_DIR, filename), installPath, 0644,
                     :verbose => true)
}
