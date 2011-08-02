require 'twitter/connection'
require 'twitter/request'
require 'twitter/authentication'

module Twitter
  # @private
  class API
    # @private
    attr_accessor *Configuration::VALID_OPTIONS_KEYS

    # Creates a new API
    def initialize(options={})
      options = Twitter.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    include Connection
    include Request
    include Authentication
  end
end
