require "rubygems"
require "bundler"
require 'stringio'
require 'tmpdir'

Bundler.setup(:default, :development)

def rspec2?
  Gem.available? "rspec", ">= 2.0"
end

def rails2?
  Gem.available? "rails", "~> 2.3"
end

def rails3?
  Gem.available? "rails", ">= 3.0"
end

if rspec2?
  require 'rspec'
else
  require 'spec'
end

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))

require "jasmine"

def create_rails(name)
  if rails3?
    `rails new #{name}`
  else
    `rails #{name}`
  end
end

def create_temp_dir
  tmp = File.join(Dir.tmpdir, "jasmine-gem-test_#{Time.now.to_f}")
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
