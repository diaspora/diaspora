module Faraday
  VERSION = "0.6.1"

  class << self
    attr_accessor :default_adapter
    attr_writer   :default_connection

    def new(url = nil, options = {})
      block = block_given? ? Proc.new : nil
      Faraday::Connection.new(url, options, &block)
    end

  private
    def method_missing(name, *args, &block)
      default_connection.send(name, *args, &block)
    end
  end

  self.default_adapter = :net_http

  def self.default_connection
    @default_connection ||= Connection.new
  end

  module AutoloadHelper
    def register_lookup_modules(mods)
      (@lookup_module_index ||= {}).update(mods)
    end

    def lookup_module(key)
      return if !@lookup_module_index
      const_get @lookup_module_index[key] || key
    end

    def autoload_all(prefix, options)
      options.each do |const_name, path|
        autoload const_name, File.join(prefix, path)
      end
    end

    # Loads each autoloaded constant.  If thread safety is a concern, wrap
    # this in a Mutex.
    def load_autoloaded_constants
      constants.each do |const|
        const_get(const) if autoload?(const)
      end
    end

    def all_loaded_constants
      constants.map { |c| const_get(c) }.
        select { |a| a.respond_to?(:loaded?) && a.loaded? }
    end
  end

  extend AutoloadHelper

  autoload_all 'faraday',
    :Middleware      => 'middleware',
    :Builder         => 'builder',
    :Request         => 'request',
    :Response        => 'response',
    :CompositeReadIO => 'upload_io',
    :UploadIO        => 'upload_io',
    :Parts           => 'upload_io'
end

require 'faraday/utils'
require 'faraday/connection'
require 'faraday/adapter'
require 'faraday/error'

# not pulling in active-support JUST for this method.
class Object
  # Yields <code>x</code> to the block, and then returns <code>x</code>.
  # The primary purpose of this method is to "tap into" a method chain,
  # in order to perform operations on intermediate results within the chain.
  #
  #   (1..10).tap { |x| puts "original: #{x.inspect}" }.to_a.
  #     tap    { |x| puts "array: #{x.inspect}" }.
  #     select { |x| x%2 == 0 }.
  #     tap    { |x| puts "evens: #{x.inspect}" }.
  #     map    { |x| x*x }.
  #     tap    { |x| puts "squares: #{x.inspect}" }
  def tap
    yield self
    self
  end unless Object.respond_to?(:tap)
end
