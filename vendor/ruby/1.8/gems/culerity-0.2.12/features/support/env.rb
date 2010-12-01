require File.dirname(__FILE__) + "/../../lib/culerity"

gem 'cucumber'
require 'cucumber'
gem 'rspec'
require 'spec'

Before do
  @tmp_root  = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path  = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end

require 'rubigen'
require 'rubigen/helpers/generator_test_helper'
include RubiGen::GeneratorTestHelper

SOURCES = Dir[File.dirname(__FILE__) + "/../../generators"].map do |f|
  RubiGen::PathSource.new(:test, File.expand_path(f))
end

