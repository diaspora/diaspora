dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module FSSM
  FileNotFoundError = Class.new(StandardError)
  CallbackError = Class.new(StandardError)

  class << self
    def dbg(msg=nil)
      STDERR.puts(msg)
    end

    def monitor(*args, &block)
      monitor = FSSM::Monitor.new
      FSSM::Support.use_block(args.empty? ? monitor : monitor.path(*args), block)

      monitor.run
    end
  end
end

require 'thread'

require 'fssm/pathname'
require 'fssm/support'
require 'fssm/tree'
require 'fssm/path'
require 'fssm/state/directory'
require 'fssm/state/file'
require 'fssm/monitor'

require "fssm/backends/#{FSSM::Support.backend.downcase}"
FSSM::Backends::Default = FSSM::Backends.const_get(FSSM::Support.backend)
