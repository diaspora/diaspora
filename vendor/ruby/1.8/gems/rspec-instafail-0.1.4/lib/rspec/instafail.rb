module RSpec
  begin
    require 'rspec/instafail/rspec_2'
  rescue LoadError => try_rspec_1
    require 'rspec/instafail/rspec_1'
  end

  Instafail::VERSION = File.read( File.join(File.dirname(__FILE__),'..','..','VERSION') ).strip
end
