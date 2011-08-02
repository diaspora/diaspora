ENV['FORCE_COLOR'] = 'true'
require 'aruba/api'
require 'aruba/cucumber'

# Monkey patch aruba to filter out some stuff
module Aruba::Api
  alias __all_stdout all_stdout
  
  def all_stdout
    unrandom(__all_stdout)
  end

  def unrandom(out)
    out = out.gsub(/#{Dir.pwd}\/tmp\/aruba/, '.') # Remove absolute paths
    out = out.gsub(/^\d+m\d+\.\d+s$/, '0m0.012s') # Make duration predictable
    out = out.gsub(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage.*\n$/, '') # Remove SimpleCov message
  end
end

Before do
  # Make sure bin/cucumber runs with SimpleCov enabled
  # set_env('SIMPLECOV', 'true')
  
  # Set a longer timeout for aruba
  @aruba_timeout_seconds = 15
end
