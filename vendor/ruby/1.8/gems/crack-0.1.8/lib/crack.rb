module Crack
  VERSION = "0.1.8".freeze
  class ParseError < StandardError; end
end

require 'crack/core_extensions'
require 'crack/json'
require 'crack/xml'