$TESTING=true
require "rubygems"
require "spec"
require "yaml"

lib_path = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
