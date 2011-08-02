ENV['CUCUMBER_COLORS']=nil
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

# For Travis....
if defined? Encoding
  Encoding.default_external = 'utf-8'
  Encoding.default_internal = 'utf-8'
end

require 'rubygems'
require 'bundler'
Bundler.setup

require 'cucumber'
$KCODE='u' unless Cucumber::RUBY_1_9

RSpec.configure do |c|
  c.before do
    ::Term::ANSIColor.coloring = true
  end
end
