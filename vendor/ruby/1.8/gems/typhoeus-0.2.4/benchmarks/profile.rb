require File.dirname(__FILE__) + '/../lib/typhoeus.rb'
require 'rubygems'
require 'ruby-prof'

calls = 20
@klass = Class.new do
  include Typhoeus
end

Typhoeus.init_easy_objects

RubyProf.start

responses = []
calls.times do |i|
  responses << @klass.get("http://127.0.0.1:3000/#{i}")
end

responses.each {|r| }#raise unless r.response_body == "whatever"}

result = RubyProf.stop

 # Print a flat profile to text
 printer = RubyProf::FlatPrinter.new(result)
 printer.print(STDOUT, 0)