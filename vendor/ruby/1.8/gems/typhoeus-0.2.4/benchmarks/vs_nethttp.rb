require 'rubygems'
require File.dirname(__FILE__) + '/../lib/typhoeus.rb'
require 'open-uri'
require 'benchmark'
include Benchmark


calls = 20
@klass = Class.new do
  include Typhoeus
end

Typhoeus.init_easy_object_pool

benchmark do |t|    
  t.report("net::http") do
    responses = []
    
    calls.times do |i|
      responses << open("http://127.0.0.1:3000/#{i}").read
    end
    
    responses.each {|r| raise unless r == "whatever"}    
  end
  
  t.report("typhoeus") do
    responses = []
    
    calls.times do |i|
      responses << @klass.get("http://127.0.0.1:3000/#{i}")
    end
    
    responses.each {|r| raise unless r.body == "whatever"}
  end
end
