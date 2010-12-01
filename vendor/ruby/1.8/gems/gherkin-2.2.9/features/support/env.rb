require 'rubygems'
require 'bundler'
Bundler.setup

# I'm sure there's a better way than this...
%w{ /../../spec /../../lib}.each do |path|
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + path)
end
require 'gherkin'
require 'gherkin/sexp_recorder'
require 'gherkin/output_stream_string_io'
require 'gherkin/java_libs'
require 'gherkin/json'

module TransformHelpers
  def tr_line_number(step_arg)
    /(\d+)$/.match(step_arg)[0].to_i
  end

  def tr_line_numbers(step_arg)
    if step_arg =~ /through/
      Range.new(*step_arg.scan(/\d+/).collect { |i| i.to_i })
    else
      step_arg.scan(/\d+/).collect { |i| i.to_i }
    end
  end
end

class GherkinWorld
  include TransformHelpers
  
  def initialize
    @formatter = Gherkin::SexpRecorder.new
  end
end

World do 
  GherkinWorld.new
end
