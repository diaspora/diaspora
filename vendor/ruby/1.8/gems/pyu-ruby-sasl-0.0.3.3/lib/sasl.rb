SASL_PATH = File.dirname(__FILE__) + "/sasl"
require 'sasl/base'
Dir.foreach(SASL_PATH) do |f|
  require "#{SASL_PATH}/#{f}" if f =~ /^[^\.].+\.rb$/ && f != 'base.rb'
end
