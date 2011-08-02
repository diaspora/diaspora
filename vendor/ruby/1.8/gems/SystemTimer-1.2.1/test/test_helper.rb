 $:.unshift File.dirname(__FILE__) + '/../lib'
 $:.unshift File.dirname(__FILE__) + '/../ext/system_timer'
 $: << File.dirname(__FILE__) + "/../vendor/gems/dust-0.1.6/lib"
 $: << File.dirname(__FILE__) + "/../vendor/gems/mocha-0.9.1/lib"
require 'test/unit'
require 'dust'
require 'mocha'
require 'stringio'
require "open-uri"
require 'system_timer'
