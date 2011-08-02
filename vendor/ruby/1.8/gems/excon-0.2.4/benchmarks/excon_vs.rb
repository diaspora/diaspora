require File.join(File.dirname(__FILE__), '..', 'lib/excon')

require 'benchmark'
require 'net/http'
require 'open-uri'

COUNT = 100
data = "Content-Length: 100"
Benchmark.bmbm(25) do |bench|
  bench.report('excon') do
    COUNT.times do
      Excon.new('http://www.google.com').request(:method => 'GET', :path => '/')
    end
  end
  bench.report('excon (persistent)') do
    excon = Excon.new('http://www.google.com')
    COUNT.times do
      excon.request(:method => 'GET', :path => '/')
    end
  end
  bench.report('net/http') do
    COUNT.times do
      # Net::HTTP.get('www.google.com', '/')
      Net::HTTP.start('www.google.com') {|http| http.get('/') }
    end
  end
  bench.report('net/http (persistent)') do
    Net::HTTP.start('www.google.com', 80) do |http|
      COUNT.times do
        http.get('/')
      end
    end
  end
  bench.report('open-uri') do
    COUNT.times do
      open('http://www.google.com/').read
    end
  end
end
