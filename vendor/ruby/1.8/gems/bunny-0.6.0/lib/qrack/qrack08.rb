$: << File.expand_path(File.dirname(__FILE__))

require 'protocol/spec08'
require 'protocol/protocol08'

require 'transport/buffer08'
require 'transport/frame08'

require 'qrack/client'
require 'qrack/channel'
require 'qrack/queue'
require 'qrack/subscription'

module Qrack
	
	include Protocol
	include Transport
	
	# Errors
	class BufferOverflowError < StandardError; end
  class InvalidTypeError < StandardError; end

end