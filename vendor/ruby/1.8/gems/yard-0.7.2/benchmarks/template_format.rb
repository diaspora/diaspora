require "benchmark"
require File.join(File.dirname(__FILE__), '..', 'lib', 'yard')

YARD::Registry.load_yardoc(File.join(File.dirname(__FILE__), '..', '.yardoc'))
obj = YARD::Registry.at("YARD::CodeObjects::Base")
puts Benchmark.measure { obj.format(:format => :html) }
