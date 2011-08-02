module RSpec
  # when installed as plugin in jruby, lib is not in load-path
  # https://github.com/grosser/rspec-instafail/pull/3
  lib = File.dirname(File.dirname(__FILE__))
  begin
    require "#{lib}/rspec/instafail/rspec_2"
  rescue LoadError # try rspec 1
    require "#{lib}/rspec/instafail/rspec_1"
  end

  Instafail::VERSION = File.read( File.join(File.dirname(__FILE__),'..','..','VERSION') ).strip
end
