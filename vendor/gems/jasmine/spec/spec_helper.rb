require "rubygems"
require "bundler"
require 'stringio'

Bundler.setup(:default, :test)

require 'spec'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))

require "jasmine"

def create_temp_dir
  tmp = File.join(Dir.tmpdir, 'jasmine-gem-test')
  FileUtils.rm_r(tmp, :force => true)
  FileUtils.mkdir(tmp)
  tmp
end

def temp_dir_before
  @root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
  @old_dir = Dir::pwd
  @tmp = create_temp_dir
end

def temp_dir_after
  Dir::chdir @old_dir
  FileUtils.rm_r @tmp
end

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end
end
