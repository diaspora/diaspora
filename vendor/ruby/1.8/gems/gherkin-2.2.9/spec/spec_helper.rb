require 'rubygems'
require 'bundler'
Bundler.setup

require 'gherkin'
require 'stringio'
require 'gherkin/sexp_recorder'
require 'gherkin/output_stream_string_io'
require 'gherkin/java_libs'
require 'gherkin/json'
require 'gherkin/shared/lexer_group'
require 'gherkin/shared/tags_group'
require 'gherkin/shared/py_string_group'
require 'gherkin/shared/row_group'

module GherkinSpecHelper
  def scan_file(file)
    @lexer.scan(fixture(file))
  end

  def fixture(file)
    File.new(File.dirname(__FILE__) + "/gherkin/fixtures/" + file).read
  end

  def rubify_hash(hash)
    if defined?(JRUBY_VERSION)
      h = {}
      hash.keySet.each{|key| h[key] = hash[key]}
      h
    else
      hash
    end
  end
end

RSpec.configure do |c|
  c.include(GherkinSpecHelper)
end

# Allows comparison of Java List with Ruby Array (rows)
RSpec::Matchers.define :r do |expected|
  match do |row|
    def row.inspect
      "r " + self.map{|cell| cell}.inspect
    end
    row.map{|cell| cell}.should == expected
  end
end

RSpec::Matchers.define :a do |expected|
  match do |array|
    def array.inspect
      "a " + self.map{|e| e.to_sym}.inspect
    end
    array.map{|e| e.to_sym}.should == expected
  end
end

RSpec::Matchers.define :sym do |expected|
  match do |actual|
    expected.to_s == actual.to_s
  end
end

RSpec::Matchers.define :allow do |event|
  match do |parser|
    parser.expected.index(event)
  end  
end
