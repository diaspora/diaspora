require 'twitter/error'
require 'twitter/configuration'
require 'twitter/api'
require 'twitter/client'
require 'twitter/search'
require 'twitter/base'

module Twitter
  extend Configuration

  # Alias for Twitter::Client.new
  #
  # @return [Twitter::Client]
  def self.new(options={})
    Twitter::Client.new(options)
  end

  # Delegate to Twitter::Client
  def self.method_missing(method, *args, &block)
    return super unless new.respond_to?(method)
    new.send(method, *args, &block)
  end

  def self.respond_to?(method, include_private = false)
    new.respond_to?(method, include_private) || super(method, include_private)
  end
end
